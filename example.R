library(quorum)

auth <- quorum::login()

begin_date <- quorum::createDate(1,7,2020, 00,00,00)
end_date <- quorum::createDate(31,8,2020, 00,00,00)

query <- quorum::createQuery(begin_date=begin_date, end_date=end_date,
                             title_contains=c('covid'),
                             text_contains=c('covid'),
                             tags=c('quorum', 'french'))

result <- quorum::loadData(query, auth)
