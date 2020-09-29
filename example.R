# ==============================
##### Installer le package #####
install.packages('devtools')
devtools::install_github('clessn/quorum-r')



# ======================================
##### Récuperer les données Radar+ #####

# Se connecter au système. Dans la console, on vous demandera votre username et mot de passe
auth <- quorum::radarplusLogin()

# on crée une requête avec les paramètres des articles qu'on veut
begin_date <- quorum::createDate(1,7,2020, 00,00,00)
end_date <- quorum::createDate(31,12,2020, 00,00,00)

query <- quorum::createRadarplusQuery(
    begin_date=begin_date, # les articles dont la fin de la une est après cette date
    end_date=end_date,     # les articles dont la fin de la une est avant cette date
    title_contains=c('covid', 'legault'),   # dont le titre contient covid ET legault (case ignorée)
    text_contains=c('covid', 'québec'),     # dont le titre contient covid ET québec (case ignorée)
    tags=c('quorum', 'french'),             # dont la source possède les tags quorum ET french
    type='text'                             # choix: slug (info minime), text (texte seulement) ou html (html seulement)
)

# On télécharge les données dans un data.table "result"
result <- quorum::loadRadarplusData(query, auth)

# pour ajouter un texte traduit à un article
mon_slug <- result$slug[1]
mon_text <- ''
quorum::setRadarplusArticleTranslatedText(mon_slug, auth, mon_text)




# ======================================
##### Récuperer les données Agora+ #####

# Même login que radarplus pour l'instant
auth <- quorum::agoraplusLogin()

# on crée une requête avec le tag agoraplus. on peut changer type='html' pour 'text' si on veut directement le texte extrait
query <- quorum::createAgoraplusQuery(tags=c('agoraplus'), type='slug') # pour plus de contrôle, on peut générer une query avec createRadarplusQuery à la place
result <- quorum::loadAgoraplusData(query, auth)
