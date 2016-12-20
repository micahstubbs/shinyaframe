#' @include utils.R
#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#' @importFrom magrittr %>%
#'
#' @export
aScatter3d <- function(ggobj, width = NULL, height = NULL, elementId = NULL) {
  # ggobj comes through as null when there are no valid mappings
  #   TODO: clear the plot in this case
  if (is.null(ggobj)) return()
  if (!is(ggobj, "gg")) stop("aScatter3d requires a ggplot object")
  # verify positional mappings
  positionals <- ggobj$mapping %>%
    as.character() %>%
    `[`(c("x", "y", "z")) %>%
    na.omit()
  if (length(positionals) == 0) return()
  if (length(positionals) < 3) {
    # make sure the mappings we do have go to positionals ggplot can use
    old_mapping <- ggobj$mapping
    mapping_switch <- positionals %>%
      setNames(c("x", "y")[seq_along(.)]) %>%
      as.list() %>%
      do.call(what = ggplot2::aes_string)
    ggobj <- ggobj + aes_(y = NULL, z = NULL) + mapping_switch
  }
  build <- ggplot_build(ggobj)
  # scaled data
  build_dat <- build$data[[1]]
  # limits, breaks, and labels
  scales <- build$layout$panel_ranges[[1]]
  ################## todo: make target scale mutable
  toscale <- c(-0.25, 0.25)
  # correct for dotplots
  if (is.null(ggobj$mapping[['y']])) {
    build_dat$y <- build_dat$y + build_dat$stackpos
    plotmax <- diff(toscale) / plot_defaults$size / 2
    if (max(build_dat$y) < plotmax) {
      # if stacks don't fill the full area, expand the scale to keep the dots
      # close together
      yrange <- c(-0.05, plotmax)
    } else {
      # otherwise scale to fit all the dots
      yrange <- range(build_dat$y)
      yrange <- yrange + diff(yrange) * 0.05 * c(-1, 1)
    }
    yscale <- scale_y_continuous()
    yscale$train(yrange)
    yscale <- yscale$break_info()
    scales$y.major <- yscale$major
    scales$y.labels = yscale$labels
    scales$y.range <- yscale$range
    ggobj$labels$y <- "Count"
  }
  if(is.null(build_dat$z)) {
    # center if no z mapping
    zdat <- 0.5
    scales$z.range <- c(0,1)
    scales$z.labels <- ""
    scales$z.major <- 0.5
    ggobj$labels$z <- ""
  } else {
    # todo: add z scale
    # inefficient hack: rebuild the plot with z in place of x
    buildz <- ggplot_build(ggobj + ggplot2::aes_(x = ggobj$mapping$z))
    zdat <- buildz$data[[1]]$x
    scales$z.range <- buildz$layout$panel_ranges[[1]]$x.range
    scales$z.labels <- buildz$layout$panel_ranges[[1]]$x.labels
    scales$z.major <-  buildz$layout$panel_ranges[[1]]$x.major
  }

  # fill in any missing aesthetics with defaults (needed for geom_dotplot)
  if(is.null(build_dat$shape)) build_dat$shape <- plot_defaults$shape
  if(is.null(build_dat$size)) {
    build_dat$size <- plot_defaults$size
  } else {
    # convert to meter scale
    build_dat$size <- round(build_dat$size / 150, 4)
  }

  # scale to the aframe plot area
  build_dat$x <- round(
    scales::rescale(build_dat$x, from = scales$x.range, to = toscale),
    4)
  build_dat$y <- round(
    scales::rescale(build_dat$y, from = scales$y.range, to = toscale),
    4)
  build_dat$z <- round(
    scales::rescale(zdat, from = scales$z.range, to = toscale),
    4)
  build_dat$geometry <- make_geometry(build_dat$shape, build_dat$size)
  build_dat$material <- paste0("color: ", build_dat$colour)
  build_dat <- build_dat[ , c("x", "y", "z", "geometry", "material")]

  # forward plot data using x
  x = list(
    points = apply(build_dat, 1, as.list),
    x = list(
      name = ggobj$labels$x,
      labels = scales$x.labels,
      breaks = scales::rescale(scales$x.major, from = c(0, 1), to = toscale)
    ),
    y = list(
      name = ggobj$labels$y,
      labels = scales$y.labels,
      breaks = scales::rescale(scales$y.major, from = c(0, 1), to = toscale)
    ),
    z = list(
      name = ggobj$labels$z,
      labels = scales$z.labels,
      breaks = scales::rescale(scales$z.major, from = c(0, 1), to = toscale)
    )
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
