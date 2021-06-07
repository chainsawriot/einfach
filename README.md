
<!-- README.md is generated from README.Rmd. Please edit that file -->

# einfach

<!-- badges: start -->

<!-- badges: end -->

The goal of einfach is to make collecting tweets through the Academic
Research Product Track V2 API as simple as possible. This package is
inspired by [Facepager](https://github.com/strohne/Facepager) (Jünger &
Keyling, 2019). But the author of this package doesn’t have the talent
to clone it accurately, and thus **e**infach **i**s **n**ot
**F**acepager’s **a**ccurate **c**lone, **h**onestly.

## Installation

You can install the development version of einfach from Github with:

``` r
devtools::install_github("chainsawriot/einfach")
```

## Usage

1.  You need to have access to the Academic Research Product Track V2
    API. Please refer to the [academictwitteR’s
    vignette](https://cran.r-project.org/web/packages/academictwitteR/vignettes/academictwitteR-auth.html)
    for more information.

2.  Please setup your bearer token using the function `set_bearer()`.
    You will be prompted for your bearer token. The token will be stored
    as a hidden file in your home directory by default.

3.  Launch einfach

<!-- end list -->

``` r
require(einfach)
einfach()
```

4.  Use the GUI and enjoy\!

<img src="man/figures/einfach.gif" align="center" height="400" />

### The dumped data

At the moment, this package will only dump the tweet data.

The dumped data is a tibble and look like so:

``` r
require(tibble)
#> Loading required package: tibble
example
#> # A tibble: 288 x 15
#>    source  id     entities$mentio… $hashtags $annotations $urls possibly_sensit…
#>    <chr>   <chr>  <list>           <list>    <list>       <lis> <lgl>           
#>  1 Twitte… 14001… <df [1 × 3]>     <df [1 ×… <named list… <nam… FALSE           
#>  2 Twitte… 14001… <df [1 × 3]>     <named l… <df [2 × 5]> <nam… FALSE           
#>  3 Twitte… 13997… <df [1 × 3]>     <named l… <df [2 × 5]> <nam… FALSE           
#>  4 Twitte… 13997… <named list [0]> <df [1 ×… <df [2 × 5]> <df … FALSE           
#>  5 Twitte… 13997… <named list [0]> <df [1 ×… <df [1 × 5]> <df … FALSE           
#>  6 Twitte… 13993… <df [1 × 3]>     <named l… <named list… <nam… FALSE           
#>  7 Twitte… 13993… <df [1 × 3]>     <named l… <named list… <nam… FALSE           
#>  8 Twitte… 13992… <named list [0]> <df [3 ×… <df [1 × 5]> <nam… FALSE           
#>  9 Twitte… 13990… <df [1 × 3]>     <df [1 ×… <named list… <nam… FALSE           
#> 10 Twitte… 13990… <df [1 × 3]>     <df [1 ×… <named list… <nam… FALSE           
#> # … with 278 more rows, and 11 more variables: context_annotations <list>,
#> #   conversation_id <chr>, created_at <chr>, public_metrics <df[,4]>,
#> #   text <chr>, lang <chr>, referenced_tweets <list>, author_id <chr>,
#> #   attachments <df[,1]>, geo <df[,1]>, in_reply_to_user_id <chr>
```

## Contributing

Contributions in the form of feedback, comments, code, and bug report
are welcome.

  - Fork the source code, modify, and issue a [pull
    request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork).
  - Issues, bug reports: [File a Github
    issue](https://github.com/chainsawriot/einfach).
  - Github is not your thing? Contact Chung-hong Chan by e-mail, post,
    or other methods listed on this
    [page](https://www.mzes.uni-mannheim.de/d7/en/profiles/chung-hong-chan).

## Code of Conduct

Please note that the einfach project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

-----
