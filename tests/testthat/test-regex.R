context("regex")

complex_function <- "\n const \n std::vector<std::string>& \n _foo \n ( \n const
\n std::vector<std::string>& \n a_a \n , \n int \n b \n ) \n { \n }"

test_that("basic function checks work as expected", {
  expect_false(isFunction("asdf asdf()"))
  expect_false(isFunction("asdf {}"))
  expect_false(isFunction("asdf asdf ( {}"))
  expect_false(isFunction("asdf asdf ) {}"))
  expect_true(isFunction("asdf asdf ( ) {}"))
  expect_true(isFunction(complex_function))
})

test_that("the ampersand is sanitized", {
  expect_equal(sanitize_amp("asdf& asdf &asdf"), "asdf& asdf& asdf")
  expect_equal(sanitize_amp("asdf &asdf &asdf"), "asdf& asdf& asdf")
})

test_that("function name, arguments and return type are recognized", {
  expect_equal(.fname(complex_function), "_foo")
  expect_equal(.type(complex_function), "const std::vector<std::string>&")
  expect_equal(.args(complex_function), "const\n\n std::vector<std::string>& \n a_a \n , \n int \n b")
  expect_equal(sapply(.args(complex_function, split=TRUE), .type, USE.NAMES=FALSE),
               c("const std::vector<std::string>&", "int"))
})
