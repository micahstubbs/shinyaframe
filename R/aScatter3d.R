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
  # verify positional mappings
  all_positionals <- c("x", "y", "z")
  positionals <- ggobj$mapping %>%
    `[`(all_positionals) %>%
    Filter(f = function(x) !is.null(x))
  mapping_switch <- list()
  if (length(positionals) == 0) {
    return(htmlwidgets::createWidget(
        name = 'aScatter3d', 'empty', width = width, height = height,
        package = 'shinyaframe', elementId = elementId
    ))
  }
  if (length(positionals) < 3) {
    # make sure the mappings we do have go to positionals ggplot can use
    mapping_switch <- positionals %>%
      setNames(c("x", "y")[seq_along(.)])
    ggobj <- ggobj + aes_(y = NULL, z = NULL) + mapping_switch
  }
  # set mapped size range to meter scale
  ggobj <- ggobj + scale_size(range = c(0.005, 0.015))
  # categorize shape scale if numeric
  shape_var <- as.character(ggobj$mapping$shape)
  if(length(shape_var)) {
    # create new variable to avoid modifying other scales if this variable
    # is mapped to multiple aesthetics
    ggobj$data$shape_mod <- ggobj$data[[shape_var]]
    ggobj <- ggobj + aes(shape = shape_mod)
    if(is.numeric(ggobj$data$shape_mod)) {
      ggobj$data$shape_mod <- Hmisc::cut2(ggobj$data$shape_mod,
                                          g = 6, digits = 2)
      # drop inclusive/exclusive indicators because they are ugly
      levels(ggobj$data$shape_mod) %>%
        gsub("^[\\(\\[]|(\\)|\\])$", "", .) %>%
        gsub(",", " to ", .) ->
        levels(ggobj$data$shape_mod)
    }
    # convert any other shape variable types (e.g. character) to factor
    ggobj$data$shape_mod <- as.factor(ggobj$data$shape_mod)
    # manually scale shape because ggplot's auto shape scale will
    # reject scaling when more than 6 levels
    ggobj <- ggobj + scale_shape_manual(
      values = seq_along(levels(ggobj$data$shape_mod))
    )
  }
  build <- ggplot2::ggplot_build(ggobj)
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
    scales$y.labels <- yscale$labels
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
  if(is.null(build_dat$size) || is.null(ggobj$mapping$size)) {
    build_dat$size <- plot_defaults$size
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
  # forward plot data to javascript using msg object
  msg = list(
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
  # extract legend info
  for(scale in build$plot$scales$non_position_scales()$scales) {
    mapping <- scale$aesthetics[1]
    breaks <- scale$get_breaks()
    valid_breaks <- !is.na(breaks)
    msg[[mapping]] <- list(
      name = ggobj$labels[[mapping]],
      breaks = scale$map(breaks[valid_breaks]),
      labels =  scale$get_labels()[valid_breaks]
    )
    if(mapping == "shape") {
      msg[[mapping]]$breaks <- aframe_geom_scale(msg[[mapping]]$breaks)
      # correct for altering of shape variable earlier
      msg[[mapping]]$name <- shape_var
    }
  }
  # reverse any mapping switcheroos done on incomplete mappings
  if (length(mapping_switch)) {
    rename_key <- names(positionals) %>%
      # reorder positionals here to have z-dotplots stack on y instead of x
      c(setdiff(all_positionals[c(2, 1, 3)], names(positionals))) %>%
      setNames(all_positionals)
    names(build_dat)[match(names(rename_key), names(build_dat))] <- rename_key
    names(msg)[match(names(rename_key), names(msg))] <- rename_key
  }
  msg$points <- apply(build_dat, 1, as.list)

  # create widget
  htmlwidgets::createWidget(
    name = 'aScatter3d',
    msg,
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
aScatter3dOutput <- function(outputId, width = '100%', height = '100%', ...){
  html <- htmltools::tagList(atags$entity(
    id = outputId,
    class = "aScatter3d html-widget html-widget-output",
    `plot-area` = "",
    ...
  ))
  dependencies <- getDependency('aScatter3d', 'shinyaframe')
  htmltools::attachDependencies(html, dependencies)
}

#' @rdname aScatter3d-shiny
#' @export
renderAScatter3d <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, aScatter3dOutput, env, quoted = TRUE)
}

#' @export
aScatter3d_html <- aEntity_html
