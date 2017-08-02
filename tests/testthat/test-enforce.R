context("enforce")

test_that("Wrong signatures throw an error", {
  expect_error(enforceXPtr("int")("asdf foo(){}"))
  expect_error(enforceXPtr("int")("int foo(int a){}"))
  expect_error(enforceXPtr("int", c("int"))("int foo(){}"))
  expect_error(enforceXPtr("int", c("int"))("int foo(asdf a){}"))
  expect_error(enforceXPtr("int", c("int"))("int foo(int a, double b){}"))
  expect_error(enforceXPtr("int", c("int", "double"))("int foo(int a, asdf b){}"))
})

test_that("A valid XPtr is returned", {
  Rcpp::cppFunction("
  NumericVector execute_cpp(SEXP func_, int n, double l) {
    typedef SEXP (*funcPtr)(int, double);
    funcPtr func = *XPtr<funcPtr>(func_);
    return func(n, l);
  }", verbose=TRUE)

  ptr <- enforceXPtr("SEXP", c("int", "double"))(
    "SEXP foo(int n, double l) { return NumericVector(n, l); }", verbose=TRUE)

  expect_type(ptr, "externalptr")
  expect_equal(execute_cpp(ptr, 10, 3.3), rep(3.3, 10))
})
