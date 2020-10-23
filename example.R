# ==============================
##### Installer le package #####
install.packages('devtools')
devtools::install_github('clessn/quorum-r')



# ======================================
##### R�cuperer les donn�es Radar+ #####

# Se connecter au syst�me. Dans la console, on vous demandera votre username et mot de passe
auth <- quorum::radarplusLogin()

# on cr�e une requ�te avec les param�tres des articles qu'on veut
begin_date <- quorum::createDate(1, 7, 2020, 00, 00, 00)
end_date <- quorum::createDate(31, 12, 2020, 00, 00, 00)

query <- quorum::createRadarplusQuery(
    begin_date = begin_date, # les articles dont la fin de la une est apr�s cette date
    end_date = end_date, # les articles dont la fin de la une est avant cette date
    title_contains = c('covid', 'legault'), # dont le titre contient covid ET legault (case ignor�e)
    text_contains = c('covid', 'qu�bec'), # dont le titre contient covid ET qu�bec (case ignor�e)
    tags = c('quorum', 'french'), # dont la source poss�de les tags quorum ET french
    type = 'text' # choix: slug (info minime), text (texte seulement) ou html (html seulement)
)

# On t�l�charge les donn�es dans un data.table "result"
result <- quorum::loadRadarplusData(query, auth)

# pour ajouter un texte traduit � un article
mon_slug <- result$slug[1]
mon_text <- ''
quorum::setRadarplusArticleTranslatedText(mon_slug, auth, mon_text)




# ======================================
##### R�cuperer les donn�es Agora+ #####

# M�me login que radarplus pour l'instant
auth <- quorum::agoraplusLogin()

# on cr�e une requ�te avec le tag agoraplus. on peut changer type='html' pour 'text' si on veut directement le texte extrait
query <- quorum::createAgoraplusQuery(tags = c('agoraplus'), type = 'slug') # pour plus de contr�le, on peut g�n�rer une query avec createRadarplusQuery � la place
result <- quorum::loadAgoraplusData(query, auth)



# ======================================
##### Publier, modifier et lister les donn�es transform�es Agora+ #####

# M�me login que radarplus pour l'instant
auth <- quorum::agoraplusLogin()

# Cr�er un nouvel objet
data <- list()
data$ma_donnee_A <- "potato"
data$ma_donnee_B <- "tomato"
quorum::createAgoraplusTransformedData(auth, 'mon_slug_de_donnee', data)
result <- quorum::listAgoraplusTransformedData(auth)
print(result[1])

# Modifier un objet
data <- list()
data$ma_donnee_A <- 23
data$ma_donnee_B <- "banana"
quorum::updateAgoraplusTransformedData(auth, 'mon_slug_de_donnee', data)
result <- quorum::listAgoraplusTransformedData(auth)
print(result[1])

# Supprimer un objet
quorum::deleteAgoraplusTransformedData(auth, 'mon_slug_de_donnee')
result <- quorum::listAgoraplusTransformedData(auth)
print(result)

# Valider si un objet existe
result <- quorum::getAgoraplusTransformedData(auth, 'mon_slug_de_donnee2')
result <- quorum::getAgoraplusTransformedData(auth, 'test')
