#' @include utils.R
#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
aScatter3d <- function(ggobj, width = NULL, height = NULL, elementId = NULL) {
  if(!is(ggobj, "gg")) stop("aScatter3d requires a ggplot object")
  build <- ggplot_build(ggobj)
  # scaled data
  build_dat <- build$data[[1]]
  # limits, breaks, and labels
  scales <- build$layout$panel_ranges[[1]]
  # fill in gaps for third dimension
  scales$z.range = c(min(build_dat$z, na.rm = TRUE) * .95,
                     max(build_dat$z, na.rm = TRUE) * 1.05)
  # scale to the aframe plot area
  x <- scales::rescale(build_dat$x,
                       from = scales$x.range, to = c(-0.25, 0.25))
  y <- scales::rescale(build_dat$y,
                       from = scales$y.range, to = c(-0.25, 0.25))
  z <- scales::rescale(build_dat$z,
                       from = scales$z.range, to = c(-0.25, 0.25));
  # forward plot data using x
  x = list(
    x = x,
    y = y,
    z = z,
    geometry = make_geometry(build_dat$shape,
                             build_dat$size / 150),
    material = paste0("color: ", build_dat$colour)
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
aScatter3d_html <- aEntity_html
