`%||%` <- function(x, y) if (is.null(x)) y else x

make_geometry <- function(g, s) {
  prim <- paste0("primitive: ", g, "; ")
  sv <- data.frame(sphere = paste0("radius: ", s, "; "),
             box = paste0("width: ", s, "; height: ", s,
                          "; depth: ", s, "; "),
             cone = paste0("height: ", s, "; radiusBottom: ", s,
                           "; radiusTop: 0.001; "),
             dodecahedron = paste0("radius: ", s, "; "),
             torus = paste0("radius: ", s,
                            "; radiusTubular: ", as.numeric(s) / 5, "; "),
             stringsAsFactors = FALSE
  )
  if (length(s) == 1 || length(g) == 1) {
    return(paste0(prim, as.character(sv[ , g])))
  }
  paste0(prim, sv[matrix(c(seq_along(s), match(g, names(sv))), ncol = 2)])
}