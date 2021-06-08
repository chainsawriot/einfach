.gen_server <- function(einfach_data_path) {
    function(input, output, session) {
        res <- shiny::reactiveValues(tempdata = tibble::tibble(), ndata = 0)
        output$status <- shiny::renderUI({
            paste0("Data directory: ", einfach_data_path, " / Number of tweets: ", res$ndata)
        })
        shiny::observeEvent(input$confirm, {
            shiny::showNotification("fetching...", duration = input$ntweets / 100)
            start_date <- paste0(as.character(input$daterange[1]), "T00:00:00Z")
            end_date <- paste0(as.character(input$daterange[2]), "T23:59:59Z")        
            academictwitteR::get_all_tweets(query = input$query, start_tweets = start_date, end_tweets = end_date, data_path = einfach_data_path, n = input$ntweets, bind_tweets = FALSE, bearer_token = get_bearer(), verbose = FALSE)
            shiny::showNotification("finished.", duration = 2)
            ## actually I want to have a way to quickly query #tweets
            res$tempdata <- tibble::as_tibble(academictwitteR::bind_tweet_jsons(einfach_data_path))
            res$ndata <- nrow(res$tempdata)
            output$status <- shiny::renderUI({
                paste0("Data directory: ", einfach_data_path, " / Number of tweets: ", res$ndata)
            })
            output$btnprev <- shiny::renderUI({
                shiny::actionButton("preview", "Data Preview")
            })
            output$btndump <- shiny::renderUI({
                shiny::downloadButton("dump", "Dump as RDS")
            })
        })
        shiny::observeEvent(input$close, {
            shiny::stopApp()
        })
        shiny::observeEvent(input$preview, {
            output$data_preview <- shiny::renderTable(res$tempdata[, c("author_id", "text", "created_at")])
        })
        output$dump <- shiny::downloadHandler(filename = function() {
            paste0("einfach ", input$query, " ", Sys.time(), ".RDS")
        }, content = function(file) {
            saveRDS(res$tempdata , file)
        }
        )
    }
}

.UI_SEARCH <-
    shiny::fluidPage(
               shiny::titlePanel("Einfach"),
               shiny::h4("Einfach is not Facepaper's accurate clone, honestly."),
               shiny::sidebarLayout(
                          shiny::sidebarPanel(
                                     shiny::textInput(inputId = "query", label = "query: ", value = "#commtwitter"),
                                     shiny::numericInput(inputId = "ntweets", label = "Number of tweets to collect", value = 450),
                                     shiny::dateRangeInput(inputId = "daterange", label = "Date range", start = Sys.Date() - 7, end = Sys.Date() - 1),
                                     shiny::actionButton("confirm", "Fetch Data", icon = shiny::icon("cloud-download-alt")),
                                     shiny::actionButton("close", "Close"),
                                     shiny::uiOutput("btnprev"),
                                     shiny::uiOutput("btndump")
                                     ),
                          shiny::mainPanel(
                                     shiny::h2("Status:"),
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
#' @param bearer_token_path path to your bearer token. Please setup using \code{set_bearer}
#' @return Nothing
#' @export
einfach <- function(data_path = NULL) {
    if (is.null(data_path)) {
        data_path <- .gen_random_dir()
    }
    shiny::runGadget(shiny::shinyApp(.UI_SEARCH, .gen_server(einfach_data_path = data_path)))
}
