.gen_server <- function(einfach_data_path, bearer_token_path) {
    function(input, output, session) {
        res <- shiny::reactiveValues(tempdata = tibble::tibble(), ndata = 0)
        output$status <- shiny::renderUI({
            paste0("Data directory: ", einfach_data_path, " / Number of tweets: ", res$ndata)
        })
        shiny::observeEvent(input$confirm, {
            shiny::showNotification("fetching...", duration = input$ntweets / 100)
            start_date <- paste0(as.character(input$daterange[1]), "T00:00:00Z")
            end_date <- paste0(as.character(input$daterange[2]), "T23:59:59Z")        
            academictwitteR::get_all_tweets(query = input$query, start_tweets = start_date, end_tweets = end_date, data_path = einfach_data_path, n = input$ntweets, bind_tweets = FALSE, bearer_token = get_bearer(bearer_token_path), verbose = FALSE)
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

#' Manage your bearer token
#'
#' These two functions manage your bearer token. It is in general not safe to 1) hardcode your bearer token in your R script or 2) have your bearer token in your command history. \code{set_bearer} saves your bearer token as an RDS file. \code{get_bearer} returns your bearer token, if it has been preset.
#' @param bearer_token string, your bearer token
#' @param path string, path to store your bearer token. Default to .academictwitteR_token at your user directory
#' @return nothing. Your bearer token is stored
#' @export
set_bearer <- function(bearer_token = NULL, path = "~/.academictwitteR_token") {
    full_path <- base::path.expand(path)
    if (is.null(bearer_token)) {
        cat("Please paste your bearer token here: ")
        if (is.null(getOption("academictwitteR.connection"))) {
            options("academictwitteR.connection" = stdin())
        }
        bearer_token <- readLines(con = getOption("academictwitteR.connection"), n = 1)
    }
    if (!file.exists(full_path)) {
        file.create(full_path)
    }
    base::Sys.chmod(full_path, "0600")
    writeLines(bearer_token, full_path)
    invisible(full_path)
}

#' @export
#' @rdname set_bearer
get_bearer <- function(path = "~/.academictwitteR_token") {
    full_path <- base::path.expand(path)
    if (base::file.exists(full_path)) {
        return(readLines(full_path))
    }
    stop("Please set up your bearer token with set_bearer() or supply your bearer token in every call.", call. = FALSE)
}


#' GUI frontend for collecting tweets
#'
#' This function launches a GUI frontend for collecting tweets using the Twitter Academic Research Product Track v2 API endpoint. Please use \code{set_bearer} to setup your bearer token first.
#' @param data_path path for storing your data; default to a temporatory directory
#' @param bearer_token_path path to your bearer token. Please setup using \code{set_bearer}
#' @return Nothing
#' @export
einfach <- function(data_path = NULL, bearer_token_path = "~/.academictwitteR_token") {
    if (is.null(data_path)) {
        data_path <- fs::path_temp(paste0(c(sample(letters, 12, replace = TRUE), "/"), collapse = ""))
    }
    shiny::runGadget(shiny::shinyApp(.UI_SEARCH, .gen_server(einfach_data_path = data_path, bearer_token_path = bearer_token_path)))
}
