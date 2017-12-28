library(shiny)
library(shinythemes)
library(data.table)
library(magrittr)
library(shinycssloaders)
library(shinydashboard)
library(shinyjs)
library(DT)

# Text Functions #####
fun_missings <- function(DT) {
  # calculate results
  namen <- names(DT)[sapply(DT, class) %in% c("character", "numeric", "integer", "factor")]
  DT2 <- DT[, .(Variable = namen, 
                `Empty Cells` = sapply(.SD, function(x) sum(x == "", na.rm = TRUE))), .SDcols = namen]
  
  resultaat <- DT[, .(Variable = names(DT), 
                      Rows = .N, 
                      Missing = sapply(.SD, function(x) sum(is.na(x))),
                      Zeroes = sapply(.SD, function(x) sum(x == 0, na.rm = T)),
                      `Infinite Values` = sapply(.SD, function(x) sum(is.infinite(x))),
                      `Distinct Values` = sapply(.SD, function(x) length(unique(x))),
                      Type = sapply(.SD, function(x) class(x)[[1]]))][, ':=' (`Perc. Missing` = round(Missing / Rows, 2),
                                                                              `Perc. Zero` = round(Zeroes / Rows, 2),
                                                                              `Perc. Infinite` = round(`Infinite Values` / Rows, 2))]
  
  # merge
  huh <- merge(resultaat, DT2, by = "Variable", all.x = TRUE, sort = FALSE)
  huh[is.na(`Empty Cells`), `Empty Cells` := 0][, `Perc. Empty` := `Empty Cells` / Rows]
  
  setcolorder(huh, c("Variable", "Rows", "Missing", "Perc. Missing", "Zeroes", "Perc. Zero", "Empty Cells", "Perc. Empty", 
                     "Infinite Values", "Perc. Infinite", "Distinct Values", "Type"))
  return(huh)
}

fun_numeric_summary <- function(DT) {
  # select numerical variables
  DT <- DT[, .SD, .SDcols = sapply(DT, is.numeric)]
  
  if (ncol(DT) == 0) { # tfw no numeric variables
    DT <- data.table(Variable = character(), 
                     Minimum = numeric(), 
                     `First quartile` = numeric(), 
                     Median = numeric(), 
                     Mean = numeric(), 
                     `Third quartile` = numeric(), 
                     Maximum = numeric(), stringsAsFactors = FALSE)
    
    return(DT)
  } else {
    DT2 <- DT[, lapply(.SD, quantile, na.rm = TRUE)]
    DT2[, A := c("Minimum", "First quartile", "Median", "Third quartile", "Maximum")]
    
    DT2 <- dcast(melt(DT2, id.var = "A", variable.factor = FALSE), variable ~ A)
    DT3 <- melt(DT[, lapply(.SD, mean, na.rm = TRUE)], measure.vars = names(DT), variable.factor = FALSE)
    
    DT2 <- merge(DT2, DT3, by = "variable", sort = FALSE)
    setnames(DT2, c("variable", "value"), c("Variable", "Mean"))
    DT2[, lapply(.SD, round, 2), .SDcols = c("Minimum", "First quartile", "Median", "Mean", "Third quartile", "Maximum")]
    setcolorder(DT2, c("Variable", "Minimum", "First quartile", "Median", "Mean", "Third quartile", "Maximum"))
    
    return(DT2)
  }
}

# Plot functions #####
fun_plot_missings <- function(DT) {
  vars <- names(DT)
  
  if (any(duplicated(colnames(DT)))) {
    setnames(DT, make.names(names(DT), unique = TRUE))
    warning("Dataset contains duplicated column names.")
  }
  vars <- copy(names(DT)) # if you don't use copy() id_xyz automagically get added to vars after that variable is created
  
  # convert cells to either the class() or NA
  DT[, (vars) := lapply(.SD, function(x) ifelse(!is.na(x), paste(class(x), collapse = '\\n'), NA))]
  DT[, id_xyz := .I]
  
  # melt data.table (gives warning that not all measure vars are of the same type)
  slag <- suppressWarnings(melt(DT, id.vars = "id_xyz", measure.vars = vars) )
  
  # rename values in legend
  vars2 <- unique(slag$value)
  slag$value <- dplyr::case_when(
    slag$value == "character"         ~ "Character",
    slag$value == "factor"            ~ "Factor",
    slag$value == "ordered\\nfactor"  ~ "Ordered Factor",
    slag$value == "POSIXct\\nPOSIXt"  ~ "Datetime",
    slag$value == "integer"           ~ "Integer",
    slag$value == "numeric"           ~ "Numeric",
    slag$value == "logical"           ~ "Logical",
    TRUE                              ~ slag$value
  )
  
  # plot raster
  p <- ggplot2::ggplot(data = slag, ggplot2::aes(x = variable, y = id_xyz, text = value)) +
    ggplot2::geom_raster(ggplot2::aes(fill = value)) +
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "", y = "Rows") +
    ggplot2::guides(fill = ggplot2::guide_legend(title = "Variable Type")) +
    ggplot2::theme( legend.position = "top") +
    ggplot2::coord_flip() 
  
  return(p)
}

fun_plot_distributions <- function(DT) {
  # select only numeric variables
  DT <- DT[, .SD, .SDcols = sapply(DT, is.numeric)]
  
  # if there are no numeric columns stop
  if (ncol(DT) == 0) {
    return(NULL)
  } else {
    # melt data
    DT <- melt(DT, measure.vars = names(DT))
    
    # plot facets
    p <- ggplot2::ggplot(data = DT) +
      ggplot2::facet_wrap(~ variable, scales = 'free') +
      ggplot2::geom_histogram(ggplot2::aes(value)) +
      ggplot2::geom_density( ggplot2::aes(value)) +
      ggplot2::theme_minimal()
    
    return(p)
  }
}

fun_plot_correlation <- function(DT) {
  DT <- DT[, .SD, .SDcols = sapply(DT, is.numeric)]
  
  correlation <- cor(DT, use = "complete.obs")
  correlation[lower.tri(correlation)] <- NA
  correlation <- melt(correlation, na.rm = T)
  
  p <- ggplot2::ggplot(correlation, ggplot2::aes(Var2, Var1, fill = value)) +
    ggplot2::geom_raster() +
    ggplot2::scale_fill_gradient2(low = "steelblue", mid = "grey90", high = "darkred", midpoint = 0, limit = c(-1,1), space = "Lab",
                                  name = "Correlation") +
    ggplot2::geom_text(ggplot2::aes(Var2, Var1, label = round(value, 2)), color = "black", size = 4) + 
    ggplot2::theme_minimal() +
    ggplot2::labs(x = "", y = "") +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, vjust = 1, size = 12, hjust = 1))
  
  return(p)
}
