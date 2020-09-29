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