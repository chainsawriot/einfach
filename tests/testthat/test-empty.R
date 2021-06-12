test_that(".has_data functions properly", {
    skip_on_cran()
    expect_true(einfach:::.has_data("../testdata/ica21/"))
    newdir <- einfach:::.gen_random_dir()
    expect_false(einfach:::.has_data(newdir))
    fs::dir_create(newdir)
    expect_false(einfach:::.has_data(newdir))
    ##write some rubbish
    x <- c("rubbish")
    writeLines(x, tempfile(tmpdir = newdir))
    expect_true(length(fs::dir_ls(newdir)) == 1)
    expect_false(einfach:::.has_data(newdir))
    unlink(newdir, recursive = TRUE)
})
