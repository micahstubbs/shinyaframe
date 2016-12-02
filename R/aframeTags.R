#' @export
aframeScene <- function(...) {
  htmltools::tag("a-scene", list(...))
}#' @export

aframeAssets <- function(...) {
  htmltools::tag("a-assets", list(...))
}

#' @export
aframeMixin <- function(...) {
  htmltools::tag("a-mixin", list(...))
}

#' @export
aframeEntity <- function(...) {
  htmltools::tag("a-entity", list(...))
}

#' @export
aframeSphere <- function(...) {
  htmltools::tag("a-sphere", list(...))
}

#' @export
aframeBox <- function(...) {
  htmltools::tag("a-box", list(...))
}

#' @export
atags <- list(
  box = aframeBox,
  sphere = aframeSphere,
  entity = aframeEntity,
  mixin = aframeMixin,
  assets = aframeAssets,
  scene = aframeScene
)
