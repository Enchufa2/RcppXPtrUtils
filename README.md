
<!-- README.md is generated from README.Rmd. Please edit that file -->
RcppXPtrUtils: XPtr Add-ons for 'Rcpp'
======================================

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
#>                         expr       min         lq      mean    median
#>      execute_r(func_r, 3, 1) 20641.592 21857.8275 23171.524 22578.654
#>  execute_cpp(func_cpp, 3, 1)   198.842   215.6035   260.385   224.835
#>          uq       max neval
#>  23569.3390 32433.286   100
#>    249.1155  1790.604   100
```
