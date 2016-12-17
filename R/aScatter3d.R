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
  # todo: add z scale
  # inefficient hack: rebuild the plot with z in place of x
  buildz <- ggplot_build(ggobj + ggplot2::aes_(x = ggobj$mapping$z))
  scales$z.range <- buildz$layout$panel_ranges[[1]]$x.range
  scales$z.labels <- buildz$layout$panel_ranges[[1]]$x.labels
  scales$z.major <-  buildz$layout$panel_ranges[[1]]$x.major
  # todo: make target scale mutable
  toscale <- c(-0.25, 0.25)
  # scale to the aframe plot area
  build_dat$x <- round(
    scales::rescale(build_dat$x, from = scales$x.range, to = toscale),
    4)
  build_dat$y <- round(
    scales::rescale(build_dat$y, from = scales$y.range, to = toscale),
    4)
  build_dat$z <- round(
    scales::rescale(buildz$data[[1]]$x, from = scales$z.range, to = toscale),
    4)
  build_dat$geometry <- make_geometry(build_dat$shape,
                                      round(build_dat$size / 150, 4))
  build_dat$material <- paste0("color: ", build_dat$colour)
  build_dat <- build_dat[ , c("x", "y", "z", "geometry", "material")]

  # forward plot data using x
  x = list(
    points = apply(build_dat, 1, as.list),
    xname = ggobj$labels$x,
    xlabels = scales$x.labels,
    xbreaks = scales::rescale(scales$x.major, from = c(0, 1), to = toscale),
    yname = ggobj$labels$y,
    ylabels = scales$y.labels,
    ybreaks = scales::rescale(scales$y.major, from = c(0, 1), to = toscale),
    zname = ggobj$labels$z,
    zlabels = scales$z.labels,
    zbreaks = scales::rescale(scales$z.major, from = c(0, 1), to = toscale)
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
