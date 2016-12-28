`%||%` <- function(x, y) if (is.null(x)) y else x

aframe_geom_scale <- function(x) {
  x <- as.integer(factor(x))
  geoms <- c("sphere", "box", "cone", "octahedron", "tetrahedron", "cylinder",
             "torus", "torusKnot", "dodecahedron")
  geoms[ (x - 1) %% length(geoms) + 1]
}


make_geometry <- function(g, s) {
  prim <- paste0("primitive: ", g, "; ")
  sv <- data.frame(sphere = paste0("radius: ", s, "; "),
             box = paste0("width: ", s * 2, "; height: ", s * 2,
                          "; depth: ", s * 2, "; "),
             cone = paste0("height: ", s * 2, "; radiusBottom: ", s,
                           "; radiusTop: 0.001; "),
             octahedron = paste0("radius: ", s, "; "),
             torus = paste0("radius: ", s * 0.75,
                            "; radiusTubular: ", s * 0.15, "; "),
             tetrahedron = paste0("radius: ", s, "; "),
             dodecahedron = paste0("radius: ", s, "; "),
             cylinder = paste0("radius: ", s, "; height: ", s * 2, "; "),
             torusKnot = paste0("radius: ", s * 0.6,
                                "; radiusTubular: ", s * 0.15, "; "),
             stringsAsFactors = FALSE
  )
  if (length(s) == 1 || length(g) == 1) {
    return(paste0(prim, as.character(sv[ , g])))
  }
  paste0(prim, sv[matrix(c(seq_along(s), match(g, names(sv))), ncol = 2)])
}


plot_defaults <- list(
  size = 0.01,
  shape = "sphere",
  size_min = 0.005,
  size_max = 0.015
)

aEntity_html <- function(id, style, class, ...) {
  atags$entity(id = id, style = style, class = class, ...)
}
