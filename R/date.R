checkRange <- function(value, valueName, min, max)
{
    if (value < min || value > max)
    {
        stop(paste('Make sure the',valueName,'parameter is between', min, 'and', max))
    }
}

padNumber <- function(value, targetLength)
{
    while (nchar(value) < targetLength)
    {
        value <- paste0('0', value)
    }
    return(value)
}

#' @export
createDate <- function(day, month, year, hour, minute, second)
{
    checkRange(day, 'day', 1, 31)
    checkRange(month, 'month', 1, 12)
    checkRange(year, 'year', 1000, 9999)

    checkRange(hour, 'hour', 0, 23)
    checkRange(minute, 'minute', 0, 59)
    checkRange(second, 'second', 0, 59)

    day <- padNumber(day, 2)
    month <- padNumber(month, 2)
    hour <- padNumber(hour, 2)
    minute <- padNumber(minute, 2)
    second <- padNumber(second, 2)

    date <-paste0(year, '-', month, '-', day)
    time <- paste0(hour, ':', minute, ':', second)
    result <- list()
    result$string <- paste(date, time)
    result$date <- as.POSIXlt(result$string, tz = "", format='%Y-%m-%d %H:%M:%S')
    return(result)
}
