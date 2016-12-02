#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
aScatter3d <- function(message, width = NULL, height = NULL, elementId = NULL) {

  # forward plot data using x
  x = list(
    coords = paste(message$x, message$y, message$z),
    parentTheme = message$parentTheme,
    geometry = make_geometry(message$geom %||% "sphere",
                             message$size %||% ".01"),
    material = paste0("color: ", message$color %||% "yellow")
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'aScatter3d',
    x,
    width = width,
    height = height,
    package = 'shinyaframe',
    elementId = elementId
  )
}

#' Shiny bindings for aScatter3d
#'
#' Output and render functions for using aScatter3d within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a aScatter3d
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name aScatter3d-shiny
#'
#' @export
aScatter3dOutput <- function(outputId, width = '100%', height = '100%'){
  htmlwidgets::shinyWidgetOutput(outputId, 'aScatter3d',
                                 width, height, package = 'shinyaframe')
}

#' @rdname aScatter3d-shiny
#' @export
renderAScatter3d <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, aScatter3dOutput, env, quoted = TRUE)
}

#' @export
aScatter3d_html <- function(id, style, class, ...) {
  atags$entity(id = id, style = style, class = class, ...)
}
