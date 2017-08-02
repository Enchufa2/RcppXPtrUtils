#' Check an \code{XPtr}'s Signature
#'
#' Check the signature (i.e., arguments and return type) of the output of
#' \code{\link{cppXPtr}}, which is an external pointer wrapped in an object of
#' class \code{XPtr}. If the user-provided C++ function does not match the
#' signature, the wrapper throws an informative error.
#'
#' @param ptr an object of class \code{XPtr} compiled with \code{\link{cppXPtr}}.
#' @param type the return type.
#' @param args a list of argument types.
#'
#' @seealso \code{\link{cppXPtr}}
#' @export
checkXPtr <- function(ptr, type, args = character()) {
  stopifnot(inherits(ptr, "XPtr"))

  .type. <- attr(ptr, "type")
  .args. <- sapply(attr(ptr, "args"), .type, USE.NAMES=FALSE)
  msg <- character()

  if (type != .type.)
    msg <- paste(c(
      msg, paste0("    Wrong return type '", .type., "', should be '", type, "'.")
    ), collapse = "\n")

  if (length(args) != length(.args.))
    msg <- paste(c(
      msg, paste0("    Wrong number of arguments, should be ", length(args), ".")
    ), collapse = "\n")
  else {
    for (i in which(!(args == .args.)))
      msg <- paste(c(
        msg, paste0("    Wrong argument type '", .args.[[i]], "', should be '", args[[i]], ".")
      ), collapse = "\n")
  }

  if (length(msg))
    stop(paste(c("\n  Bad signature:", msg), collapse = "\n"))
}
