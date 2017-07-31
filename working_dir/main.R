library(RcppXPtrUtils)

Rcpp::sourceCpp("working_dir/core.cpp")

func_r <- function(n, l) rexp(n, l)
func_cpp <- cppXPtr("SEXP foo(int n, double l) { return rexp(n, l); }")

microbenchmark::microbenchmark(
  execute_r(func_r, 3, 1),
  execute_cpp(func_cpp, 3, 1)
)
