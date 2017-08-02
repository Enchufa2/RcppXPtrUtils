#' Define an XPtr with a C++ Implementation
#'
#' Dynamically define an XPtr with C++ source code. Compiles and links a shared
#' library with bindings to the C++ function using \code{\link{cppFunction}},
#' then returns an XPtr that points to the function and can be used to be
#' plugged into another C++ backend.
#'
#' @inheritParams Rcpp::cppFunction
#' @return An XPtr that points to the compiled function.
#'
#' @seealso \code{\link{cppFunction}}, \code{\link{enforceXPtr}}
#' @export
cppXPtr <- function(code,
                    depends = character(),
                    plugins = character(),
                    includes = character(),
                    rebuild = FALSE,
                    cacheDir = getOption("rcpp.cache.dir", tempdir()),
                    showOutput = verbose,
                    verbose = getOption("verbose"))
{
  stopifnot(isFunction(code))

  # append a getter
  code <- sanitize_amp(code)
  code <- paste(c(
    "SEXP getXPtr();",
    code,
    "SEXP getXPtr() {",
    paste("  typedef", .type(code), "(*funcPtr)(", .args(code), ";"),
    paste("  return XPtr<funcPtr>(new funcPtr(&", .fname(code), "));"),
    "}"), collapse="\n")

  # source cpp into a controlled environment
  env <- new.env()
  Rcpp::cppFunction(code, depends, plugins, includes, env,
                    rebuild, cacheDir, showOutput, verbose)

  # return XPtr
  env$getXPtr()
}
