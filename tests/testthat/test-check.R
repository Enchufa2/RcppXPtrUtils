context("check")

Rcpp::cppFunction("
  NumericVector execute_cpp(SEXP func_, int n, double l) {
    typedef SEXP (*funcPtr)(int, double);
    funcPtr func = *XPtr<funcPtr>(func_);
    return func(n, l);
  }", verbose=TRUE)

ptr <- cppXPtr("SEXP foo(int n, double l) { return NumericVector(n, l); }", verbose=TRUE)

test_that("A valid XPtr is returned", {
  expect_type(ptr, "externalptr")
  expect_true(inherits(ptr, "XPtr"))
  expect_equal(names(attributes(ptr)), c("class", "type", "fname", "args"))
  expect_silent(checkXPtr(ptr, "SEXP", c("int", "double")))
  expect_output(print(ptr), "'SEXP foo\\(int n, double l\\)'")
  expect_equal(execute_cpp(ptr, 10, 3.3), rep(3.3, 10))
})

test_that("Wrong signatures throw an error", {
  expect_error(checkXPtr(ptr, "int", c("int", "double")))
  expect_error(checkXPtr(ptr, "SEXP", c("int")))
  expect_error(checkXPtr(ptr, "SEXP", c("double", "int")))
})
