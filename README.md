
<!-- README.md is generated from README.Rmd. Please edit that file -->

# RcppXPtrUtils: XPtr Add-Ons for ‘Rcpp’

[![Build
Status](https://github.com/Enchufa2/RcppXPtrUtils/actions/workflows/build.yml/badge.svg)](https://github.com/Enchufa2/RcppXPtrUtils/actions/workflows/build.yml)
[![Coverage
Status](https://codecov.io/gh/Enchufa2/RcppXPtrUtils/branch/master/graph/badge.svg)](https://codecov.io/gh/Enchufa2/RcppXPtrUtils)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/RcppXPtrUtils)](https://cran.r-project.org/package=RcppXPtrUtils)
[![Downloads](https://cranlogs.r-pkg.org/badges/RcppXPtrUtils)](https://cran.r-project.org/package=RcppXPtrUtils)

The **RcppXPtrUtils** package provides the means to compile
user-supplied C++ functions with ‘Rcpp’ and retrieve an XPtr that can be
passed to other C++ components.

## Installation

Install the release version from CRAN:

``` r
install.packages("RcppXPtrUtils")
```

The installation from GitHub requires the
[devtools](https://github.com/hadley/devtools) package.

``` r
# install.packages("devtools")
devtools::install_github("Enchufa2/RcppXPtrUtils")
```

## Use case

Let’s suppose we have a package with a core written in C++, connected to
an R API with `Rcpp`. It accepts a user-supplied R function to perform
some processing:

``` cpp
#include <Rcpp.h>
using namespace Rcpp;

template <typename T>
NumericVector core_processing(T func, double l) {
  double accum = 0;
  for (int i=0; i<1e3; i++)
    accum += sum(as<NumericVector>(func(3, l)));
  return NumericVector(1, accum);
}

// [[Rcpp::export]]
NumericVector execute_r(Function func, double l) {
  return core_processing<Function>(func, l);
}
```

But calling R from C++ is slow, so we can think about improving the
performance by accepting a compiled function. In order to do this, the
core can be easily extended to accept an `XPtr` to a compiled function:

``` cpp
typedef SEXP (*funcPtr)(int, double);

// [[Rcpp::export]]
NumericVector execute_cpp(SEXP func_, double l) {
  funcPtr func = *XPtr<funcPtr>(func_);
  return core_processing<funcPtr>(func, l);
}
```

To easily leverage this feature, the `RcppXPtrUtils` package provides
`cppXPtr()`, which compiles a user-supplied C++ function using
`Rcpp::cppFunction()` and returns an `XPtr`:

``` r
# compile the code above
# Rcpp::sourceCpp(code='...')

library(RcppXPtrUtils)

func_r <- function(n, l) rexp(n, l)
func_cpp <- cppXPtr("SEXP foo(int n, double l) { return rexp(n, l); }")

microbenchmark::microbenchmark(
  execute_r(func_r, 1.5),
  execute_cpp(func_cpp, 1.5)
)
#> Unit: microseconds
#>                        expr      min        lq       mean    median        uq
#>      execute_r(func_r, 1.5) 14371.06 16081.805 17159.7910 16887.638 18066.667
#>  execute_cpp(func_cpp, 1.5)   206.18   218.306   281.4874   232.214   268.673
#>        max neval cld
#>  22969.213   100   b
#>   2432.279   100  a
```

The object returned by `cppXPtr()` is just an `externalptr` wrapped into
an object of class `XPtr`, which stores the signature of the function.
If you are a package author, you probably want to re-export `cppXPtr()`
and ensure that user-supplied C++ functions comply with the internal
signatures in order to avoid runtime errors. This can be done with the
`checkXPtr()` function:

``` r
func_cpp
#> 'SEXP foo(int n, double l)' <pointer: 0x5636b1e8a840>
checkXPtr(func_cpp, "SEXP", c("int", "double")) # returns silently
checkXPtr(func_cpp, "int", c("int", "double"))
#> Error in checkXPtr(func_cpp, "int", c("int", "double")): Bad XPtr signature:
#>   Wrong return type 'int', should be 'SEXP'.
checkXPtr(func_cpp, "SEXP", c("int"))
#> Error in checkXPtr(func_cpp, "SEXP", c("int")): Bad XPtr signature:
#>   Wrong number of arguments, should be 2'.
checkXPtr(func_cpp, "SEXP", c("double", "int"))
#> Error in checkXPtr(func_cpp, "SEXP", c("double", "int")): Bad XPtr signature:
#>   Wrong argument type 'double', should be 'int'.
#>   Wrong argument type 'int', should be 'double'.
```
