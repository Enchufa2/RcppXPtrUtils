
<!-- README.md is generated from README.Rmd. Please edit that file -->
RcppXPtrUtils: XPtr Add-ons for 'Rcpp'
======================================

[![Build Status](http://travis-ci.org/Enchufa2/RcppXPtrUtils.svg?branch=master)](https://travis-ci.org/Enchufa2/RcppXPtrUtils) [![Coverage Status](http://codecov.io/gh/Enchufa2/RcppXPtrUtils/branch/master/graph/badge.svg)](https://codecov.io/gh/Enchufa2/RcppXPtrUtils) [![CRAN\_Status\_Badge](http://www.r-pkg.org/badges/version/RcppXPtrUtils)](https://cran.r-project.org/package=RcppXPtrUtils) [![Downloads](http://cranlogs.r-pkg.org/badges/RcppXPtrUtils)](https://cran.r-project.org/package=RcppXPtrUtils)

The **RcppXPtrUtils** package provides the means to compile user-provided C++ functions using 'Rcpp::cppFunction' and to return an XPtr that can be passed to other C++ components.

Installation
------------

The installation from GitHub requires the [devtools](https://github.com/hadley/devtools) package.

``` r
# install.packages("devtools")
devtools::install_github("Enchufa2/RcppXPtrUtils")
```

Use case
--------

Let's suppose we have a package with a core written in C++, connected to an R API with `Rcpp`. It accepts a user-provided R function to perform some processing:

``` c
#include <Rcpp.h>
using namespace Rcpp;

template <typename T>
NumericVector core_processing(T func, int n, double l) {
  double accum = 0;
  for (int i=0; i<1e3; i++)
    accum += sum(as<NumericVector>(func(n, l)));
  return NumericVector(1, accum);
}

// [[Rcpp::export]]
NumericVector execute_r(Function func, int n, double l) {
  return core_processing<Function>(func, n, l);
}
```

But calling R from C++ is slow, so we can think about improving the performance by accepting a compiled function. In order to do this, the core can be easily extended to accept an `XPtr` to a compiled function:

``` c
typedef SEXP (*funcPtr)(int, double);

// [[Rcpp::export]]
NumericVector execute_cpp(SEXP func_, int n, double l) {
  funcPtr func = *XPtr<funcPtr>(func_);
  return core_processing<funcPtr>(func, n, l);
}
```

To easily leverage this feature, the `RcppXPtrUtils` package provides `cppXPtr()`, which compiles a user-provided C++ function using `Rcpp::cppFunction()` and returns an `XPtr`:

``` r
# compile the code above
# Rcpp::sourceCpp(code='...')

library(RcppXPtrUtils)
library(microbenchmark)

func_r <- function(n, l) rexp(n, l)
func_cpp <- cppXPtr("SEXP foo(int n, double l) { return rexp(n, l); }")

microbenchmark(
  execute_r(func_r, 3, 1),
  execute_cpp(func_cpp, 3, 1)
)
#> Unit: microseconds
#>                         expr       min         lq       mean    median
#>      execute_r(func_r, 3, 1) 14071.998 15138.7775 16321.1108 15882.891
#>  execute_cpp(func_cpp, 3, 1)   170.721   187.2275   241.4493   197.023
#>         uq       max neval cld
#>  17202.599 22393.535   100   b
#>    237.804  1907.006   100  a
```

The object returned by `cppXPtr()` is just an `externalptr` wrapped into an object of class `XPtr`, which stores the signature of the function. If you are a package author, you probably want to ensure that user-provided C++ functions comply with the internal signatures in order to avoid runtime errors. This can be done with the `checkXPtr()` function:

``` r
func_cpp
#> 'SEXP foo(int n, double l)' <pointer: 0x55f480625960>
checkXPtr(func_cpp, "SEXP", c("int", "double")) # returns silently
checkXPtr(func_cpp, "int", c("int", "double"))
#> Error in checkXPtr(func_cpp, "int", c("int", "double")): 
#>   Bad signature:
#>     Wrong return type 'SEXP'. Should be: 'int'
checkXPtr(func_cpp, "SEXP", c("int"))
#> Error in checkXPtr(func_cpp, "SEXP", c("int")): 
#>   Bad signature:
#>     Wrong number of arguments. Should be: 1
checkXPtr(func_cpp, "SEXP", c("double", "int"))
#> Error in checkXPtr(func_cpp, "SEXP", c("double", "int")): 
#>   Bad signature:
#>     Wrong argument type 'int'. Should be: 'double
#>     Wrong argument type 'double'. Should be: 'int
```
