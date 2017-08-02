#' Enforce a C++ Signature
#'
#' Wrap a \code{\link{cppXPtr}} call for a given signature (i.e., arguments
#' and return type). If the user-provided C++ function does not match the
#' signature, the wrapper throws an informative error.
#'
#' @param type the return type.
#' @param args a list of argument types.
#' @return A \code{\link{cppXPtr}} wrapper with signature enforcing.
#'
#' @seealso \code{\link{cppXPtr}}
#' @export
enforceXPtr <- function(type, args = character()) {
  function(code, ...) {
    check_sig(type, args, code)
    cppXPtr(code, ...)
  }
}

check_sig <- function(type, args, code) {
  .type. <- .type(code)
  .args. <- sapply(.args(code, split=TRUE), .type, USE.NAMES=FALSE)
  msg <- character()

  if (type != .type.)
    msg <- paste(c(
      msg, paste0("    Wrong return type '", .type., "'. Should be: '", type, "'")
    ), collapse = "\n")

  if (length(args) != length(.args.))
    msg <- paste(c(
      msg, paste0("    Wrong number of arguments. Should be: ", length(args))
    ), collapse = "\n")
  else {
    for (i in which(!(args == .args.)))
      msg <- paste(c(
        msg, paste0("    Wrong argument type '", .args.[[i]], "'. Should be: '", args[[i]])
      ), collapse = "\n")
  }

  if (length(msg))
    stop(paste(c("\n  Bad signature:", msg), collapse = "\n"))
}
