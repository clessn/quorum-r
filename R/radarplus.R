#' @export
createRadarplusAuth <- function(username, password)
{
    return(httr::authenticate(username, password))
}

#' @export
radarplusLogin <- function()
{
    username <- readline(prompt='Username: ')
    password <- readline(prompt='Password: ')
    return(httr::authenticate(username, password))
}

#' @export
createRadarplusQuery <- function(ssouce=NULL, tags=NULL, begin_date=NULL, end_date=NULL,
                        text_contains=NULL, title_contains=NULL, author_contains=NULL)
{
    query = list()
    if (!is.null(ssouce))
    {
        query$source = ssouce
    }
    if (!is.null(tags))
    {
        tags <- paste(tags, collapse=',')
        query$tags = tags
    }
    if (!is.null(begin_date))
    {
        query$begin_date = begin_date$string
    }
    if (!is.null(end_date))
    {
        query$end_date = end_date$string
    }
    if (!is.null(text_contains))
    {
        text_contains <- paste(text_contains, collapse=',')
        query$text_contains = text_contains
    }
    if (!is.null(title_contains))
    {
        title_contains <- paste(title_contains, collapse=',')
        query$title_contains = title_contains
    }
    if (!is.null(author_contains))
    {
        author_contains <- paste(author_contains, collapse=',')
        query$author_contains = author_contains
    }
    return(query)
}

#' @export
loadRadarplusData <- function(query, auth, url='https://radarplus.clessn.com/article_list')
{
    cat('Loading data\n')
    start_time <- Sys.time()
    request <- httr::GET(url=url, config=auth, query=query)
    if (request$status_code != 200)
    {
        stop(paste('request failed with a code', request$status_code))
    }
    content <- httr::content(request)
    item_count <- content$count
    next_page <- content$'next'
    items <- content$results
    data <- suppressWarnings(data.table::rbindlist(items))
    cat(paste('found',item_count,'articles\n'))
    current_count <- nrow(data)
    while (current_count != item_count)
    {
        result <- loadPage(auth, next_page, data)
        data <- result$data
        next_page <- result$next_page
        current_count = nrow(data)
        cat(paste0('\r',current_count, '/', item_count, '...', percent(current_count/item_count), '        '))
    }

    data <- cbind(data, as.POSIXct(data$earliest_headline, format='%Y-%m-%dT%H:%M:%S'))
    data <- cbind(data, as.POSIXct(data$latest_headline, format='%Y-%m-%dT%H:%M:%S'))

    colnames(data)[length(colnames(data))-1] <- 'begin_date'
    colnames(data)[length(colnames(data))] <- 'end_date'
    data$earliest_headline <- NULL
    data$latest_headline <- NULL
    data$slug <- NULL

    for (col in colnames(data))
    {
        if (typeof(data[[col]]) == 'character')
        {
            Encoding(data[[col]]) <- "UTF-8"
        }
    }

    end_time <- Sys.time()
    cat('\nsuccess with a ')
    print(end_time - start_time)
    return(data)
}

loadPage <- function(auth, url, data=NULL)
{
    request <- httr::GET(url=url, config=auth)
    if (request$status_code != 200)
    {
        stop(paste('request failed with a code', request$status_code))
    }
    content <- httr::content(request)
    items <- content$results
    next_page <- content$'next'

    result <- suppressWarnings(data.table::rbindlist(items))
    if (is.null(data))
    {
        data <- result
    }
    else
    {
        data <- rbind(data, result)
    }
    return(list(data=data, next_page=next_page))

}
