##### DONNÉES RADARPLUS

install.packages('devtools')
devtools::install_github('clessn/quorum-r')

begin_date <- quorum::createDate(1,7,2020, 00,00,00)
end_date <- quorum::createDate(31,8,2020, 00,00,00)

auth <- quorum::radarplusLogin()
query <- quorum::createRadarplusQuery(begin_date=begin_date, end_date=end_date,
                             title_contains=c('covid'),
                             text_contains=c('covid'),
                             tags=c('quorum', 'french'))

result <- quorum::loadRadarplusData(query, auth)



##### DONNÉES AGORAPLUS

install.packages('devtools')
devtools::install_github('clessn/quorum-r')
auth <- quorum::agoraplusLogin()
query <- quorum::createAgoraplusQuery(tags=c('agoraplus'))
result <- quorum::loadAgoraplusData(query, auth)
