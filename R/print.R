#' @export
print.XPtr <- function(x, ...) {
  attrs <- attributes(x)
  cat("'", attrs[["type"]], " ", attrs[["fname"]],
      "(", paste(attrs[["args"]], collapse=", "), ")' ", sep="")
  attributes(x) <- NULL
  print(x)
  attributes(x) <- attrs
  invisible(x)
}
