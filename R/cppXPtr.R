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
#' @seealso \code{\link{cppFunction}}
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
  stopifnot(.isFunction(code))

  # get signature
  sig <- strsplit(code, "[[:space:]]*\\{")[[1]][[1]]
  sig <- gsub("&", "& ", sig)
  sig <- strsplit(sig, "[[:space:]]*\\(")[[1]]
  sig.args <- sig[[2]]
  sig <- strsplit(sig[[1]], "[[:space:]]+")[[1]]
  sig.name <- sig[[length(sig)]]
  sig.retv <- paste(sig[seq_len(length(sig)-1)], collapse=" ")

  # append a getter
  code <- paste(c(
    "SEXP getXPtr();",
    code,
    "SEXP getXPtr() {",
    paste("  typedef", sig.retv, "(*funcPtr)(", sig.args, ";"),
    paste("  return XPtr<funcPtr>(new funcPtr(&", sig.name, "));"),
    "}"), collapse="\n")

  # source cpp into a controlled environment
  env <- new.env()
  Rcpp::cppFunction(code, depends, plugins, includes, env,
                    rebuild, cacheDir, showOutput, verbose)

  # return XPtr
  env$getXPtr()
}

# basic checks
.isFunction <- function(code)
  grepl("^[[:alnum:][:space:]_&]*\\([[:alnum:][:space:]_&,]*\\)[[:space:]]*\\{", code)
