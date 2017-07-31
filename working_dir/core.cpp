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

typedef SEXP (*funcPtr)(int, double);

// [[Rcpp::export]]
NumericVector execute_cpp(SEXP func_, int n, double l) {
  funcPtr func = *XPtr<funcPtr>(func_);
  return core_processing<funcPtr>(func, n, l);
}
