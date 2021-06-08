test_that("set_bearer correctly reimported from academictwitteR", {
    x <- tempfile()
    set_bearer("xxxx", x)
    y <- readLines(x)
    expect_equal("xxxx", y)
    unlink(x)
})
