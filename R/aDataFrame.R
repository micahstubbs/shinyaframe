#' @include utils.R
#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
aDataFrame <- function(df, width = NULL, height = NULL, elementId = NULL) {

  # forward data using x
  x <- lapply(names(df), function(y) {

    list(name = y,
         type = class(df[[y]])[1],
         data = df[[y]])
  })

  # create widget
  htmlwidgets::createWidget(
    name = 'aDataFrame',
    x,
    width = width,
    height = height,
    package = 'shinyaframe',
    elementId = elementId
  )
}

#' Shiny bindings for aDataFrame
#'
#' Output and render functions for using aDataFrame within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a aDataFrame
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name aDataFrame-shiny
#'
#' @export
aDataFrameOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'aDataFrame', width, height, package = 'shinyaframe')
}

#' @rdname aDataFrame-shiny
#' @export
renderADataFrame <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, aDataFrameOutput, env, quoted = TRUE)
}

#' @export
aDataFrame_html <- aEntity_html
