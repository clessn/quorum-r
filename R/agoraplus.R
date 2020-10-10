#' @export
createAgoraplusAuth <- function(username, password)
{
  return(httr::authenticate(username, password))
}

#' @export
agoraplusLogin <- function()
{
  username <- readline(prompt='Username: ')
  password <- readline(prompt='Password: ')
  return(httr::authenticate(username, password))
}

#' @export
createAgoraplusQuery <- function(source=NULL, tags=NULL, type='html')
{
  query = list()
  if (!is.null(source))
  {
    query$source = source
  }
  if (!is.null(tags))
  {
    tags <- paste(tags, collapse=',')
    query$tags = tags
  }
  query$type <- type
  return(query)
}

#' @export
loadAgoraplusData <- function(query, auth, url='https://radarplus.clessn.com/articles')
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

#' @export
createAgoraplusTransformedData <- function(auth, slug, data, url='https://radarplus.clessn.com/agora/')
{
    body <- list()
    body$slug <- slug
    body$content <- rjson::toJSON(data)
    request <- httr::POST(url=url, config=auth, body=body)
    if (request$status_code != 201)
    {
        stop(paste('request failed with a code', request$status_code))
    }
    else
    {
        print('success')
    }
}

#' @export
getAgoraplusTransformedData <- function(auth, slug, url='https://radarplus.clessn.com/agora/')
{
    request <- httr::GET(url=paste0(url, slug, '/'), config=auth)
    if (request$status_code == 404)
    {
        print('object not found')
        return(NULL)
    }

    if (request$status_code != 200)
    {
        stop(paste('request failed with a code', request$status_code))
    }
    print('success')

    obj <- httr::content(request)
    data <- data.table::data.table()


    content <- as.list(rjson::fromJSON(obj$content))
    content <- c(obj, content)
    for (name in names(content))
    {
        data[1, name] <- content[name]
    }

    return(data)
}

updateAgoraplusTransformedData <- function(auth, slug, data, url='https://radarplus.clessn.com/agora/')
{
    body <- list()
    body$content <- rjson::toJSON(data)
    request <- httr::PATCH(url=paste0(url, slug, '/'), config=auth, body=body)
    if (request$status_code != 200)
    {
        stop(paste('request failed with a code', request$status_code))
    }
    else
    {
        print('success')
    }
}

deleteAgoraplusTransformedData <- function(auth, slug, url='https://radarplus.clessn.com/agora/')
{
    request <- httr::DELETE(url=paste0(url, slug, '/'), config=auth)
    if (request$status_code != 204)
    {
        stop(paste('request failed with a code', request$status_code))
    }
    else
    {
        print('success')
    }
}

#' @export
listAgoraplusTransformedData <- function(auth, url='https://radarplus.clessn.com/agora/')
{
    cat('Loading data\n')
    start_time <- Sys.time()
    request <- httr::GET(url=url, config=auth)
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
    if (item_count == 0)
    {
        return(NULL)
    }
    current_count <- nrow(data)
    while (current_count != item_count)
    {
        result <- loadPage(auth, url=next_page, data)
        data <- result$data
        content <- rjson::fromJSON(result$data$content)
        next_page <- result$next_page
        current_count = nrow(data)
        cat(paste0('\r',current_count, '/', item_count, '...', percent(current_count/item_count), '        '))
    }

    for (row in 1:nrow(data))
    {
        content <- as.list(rjson::fromJSON(data[row, 'content']))
        for (name in names(content))
        {
            data[row, name] <- content[name]
        }
    }

    data <- cbind(data, as.POSIXct(data$created, format='%Y-%m-%dT%H:%M:%S'))
    colnames(data)[length(colnames(data))] <- 'created'
    data$created <- NULL

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
