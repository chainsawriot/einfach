.gen_server <- function(einfach_data_path, verbose) {
    function(input, output, session) {
        res <- shiny::reactiveValues(tempdata = tibble::tibble(), ndata = 0)
        res$ndata <- .count_tweets(einfach_data_path)
        output$status <- shiny::renderUI({
            paste0("Data directory: ", einfach_data_path, " / Number of tweets: ", res$ndata)
        })
        shiny::observeEvent(input$confirm, {
            start_date <- paste0(as.character(input$daterange[1]), "T00:00:00Z")
            end_date <- paste0(as.character(input$daterange[2]), "T23:59:59Z")
            if (input$ntweets == 0) {
                n <- Inf
            } else {
                n <- input$ntweets
            }
            shiny::showNotification("fetching...", duration = min(n / 100, 5))
            academictwitteR::get_all_tweets(query = input$query, start_tweets = start_date, end_tweets = end_date, data_path = einfach_data_path, n = n, bind_tweets = FALSE, bearer_token = get_bearer(), verbose = verbose)
            shiny::showNotification("finished.", duration = 2)
            res$ndata <- .count_tweets(einfach_data_path)
            output$status <- shiny::renderUI({
                paste0("Data directory: ", einfach_data_path, " / Number of tweets: ", res$ndata)
            })
            ## actually I want to have a way to quickly query #tweets
            output$status <- shiny::renderUI({
                paste0("Data directory: ", einfach_data_path, " / Number of tweets: ", res$ndata)
            })
            output$btnprev <- shiny::renderUI({
                shiny::actionButton("preview", "Data Preview")
            })
            output$btndump <- shiny::renderUI({
                shiny::tagList(
                           shiny::selectInput("format", "Format:", c("Serialized R Object (RDS)" = "rds", "Comma-seperated data (CSV)" = "csv", "Excel (xlsx)" = "xlsx", "Stata (dta)" = "dta", "SPSS (sav)" = "sav")),
                           shiny::downloadButton("dump", "Dump")
                )
            })
        })
        shiny::observeEvent(input$close, {
            shiny::stopApp()
        })
        shiny::observeEvent(input$preview, {
            res$tempdata <- .lazy_bind_tweets(einfach_data_path)
            output$data_preview <- shiny::renderTable(res$tempdata[, c("author_id", "text", "created_at")])
            shiny::showNotification(paste0("You have ", res$ndata, " tweets, only ", nrow(res$tempdata), " tweets are shown."), duration = 3)
        })
        output$dump <- shiny::downloadHandler(filename = function() {
            paste0("einfach ", input$query, " ", Sys.time(), ".", input$format)
        }, content = function(file) {
            rio::export(academictwitteR::bind_tweets(einfach_data_path, output_format = "tidy"), file)
        }
        )
    }
}

.UI_SEARCH <-
    shiny::fluidPage(
               shiny::titlePanel("Einfach"),
               shiny::h4("Einfach is not Facepager's accurate clone, honestly."),
               shiny::sidebarLayout(
                          shiny::sidebarPanel(
                                     shiny::textInput(inputId = "query", label = "Query: ", value = "#commtwitter"),
                                     shiny::numericInput(inputId = "ntweets", label = "Number of tweets to collect (0: as many as possible)", value = 0, min = 0),
                                     shiny::dateRangeInput(inputId = "daterange", label = "Date range", start = Sys.Date() - 365, end = Sys.Date() - 1),
                                     shiny::actionButton("confirm", "Fetch Data", icon = shiny::icon("cloud-download-alt")),
                                     shiny::actionButton("close", "Close"),
                                     shiny::uiOutput("btnprev"),
                                     shiny::uiOutput("btndump")
                                     ),
                          shiny::mainPanel(
                                     shiny::uiOutput("status"),
                                     shiny::tableOutput("data_preview")
                                 )
                      )
           )

#' Reexport get_bearer from academictwitteR
#'
#' This is a reexport of the function get_bearer from academictwitteR. If you want to know how to setup your access token, see `?academictwitteR::get_bearer`
#' @return your bearer token, if it has been setup.
#' @export
get_bearer <- function() {
    academictwitteR::get_bearer()
}

.gen_random_dir <- function() {
    fs::path_temp(paste0(c(sample(letters, 12, replace = TRUE), "/"), collapse = ""))
}

#' GUI frontend for collecting tweets
#'
#' This function launches a GUI frontend for collecting tweets using the Twitter Academic Research Product Track v2 API endpoint. Please use \code{set_bearer} to setup your bearer token first.
#' @param data_path path for storing your data; default to a temporatory directory
#' @param verbose if `FALSE`, no output
#' @return Nothing
#' @export
einfach <- function(data_path = NULL, verbose = FALSE) {
    if (is.null(data_path)) {
        data_path <- .gen_random_dir()
    }
    shiny::runGadget(shiny::shinyApp(.UI_SEARCH, .gen_server(einfach_data_path = data_path, verbose = verbose)))
}

## check for emptyness / having data
.has_data <- function(data_path) {
    if (!fs::dir_exists(data_path)) {
        return(FALSE)
    }
    length(fs::dir_ls(data_path, regexp = "(data_|users_).+\\.json$")) != 0
}

## do whtat the function name says
.count_tweets <- function(data_path) {
    if (!.has_data(data_path)) {
        return(0)
    }
    data_json_files <- fs::dir_ls(data_path, regexp = "data_.+\\.json$")
    sum(purrr::map_int(data_json_files, ~ length(jsonlite::read_json(.))))
}

## instead of bind all tweets, it binds only one file
.lazy_bind_tweets <- function(data_path) {
    ## return an empty data
    if (!.has_data(data_path)) {
        return(tibble::tibble())
    }
    data_json_files <- fs::dir_ls(data_path, regexp = "data_.+\\.json")
    tibble::as_tibble(jsonlite::read_json(sample(data_json_files, 1), simplifyVector = TRUE))
}
