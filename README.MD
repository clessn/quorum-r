# QUORUM: PACKAGE R

## Tasks
- [ ] Int√©grer l'API de build-a-voter
- [x] Int√©grer l'API de radar+
- [ ] Int√©grer l'API de civimetre+
- [x] Int√©grer l'API de agora+

## Documentation
```r
# ==============================
##### Installer le package #####
install.packages('devtools')
devtools::install_github('clessn/quorum-r')



# ======================================
##### RÈcuperer les donnÈes Radar+ #####

# Se connecter au systËme. Dans la console, on vous demandera votre username et mot de passe
auth <- quorum::radarplusLogin()

# on crÈe une requÍte avec les paramËtres des articles qu'on veut
begin_date <- quorum::createDate(1,7,2020, 00,00,00)
end_date <- quorum::createDate(31,12,2020, 00,00,00)

query <- quorum::createRadarplusQuery(
    begin_date=begin_date, # les articles dont la fin de la une est aprËs cette date
    end_date=end_date,     # les articles dont la fin de la une est avant cette date
    title_contains=c('covid', 'legault'),   # dont le titre contient covid ET legault (case ignorÈe)
    text_contains=c('covid', 'quÈbec'),     # dont le titre contient covid ET quÈbec (case ignorÈe)
    tags=c('quorum', 'french'),             # dont la source possËde les tags quorum ET french
    type='text'                             # choix: slug (info minime), text (texte seulement) ou html (html seulement)
)

# On tÈlÈcharge les donnÈes dans un data.table "result"
result <- quorum::loadRadarplusData(query, auth)

# pour ajouter un texte traduit ‡ un article
quorum::setRadarplusArticleTranslatedText(mon_slug, auth, mon_text)




# ======================================
##### RÈcuperer les donnÈes Agora+ #####

# MÍme login que radarplus pour l'instant
auth <- quorum::agoraplusLogin()

# on crÈe une requÍte avec le tag agoraplus. on peut changer type='html' pour 'text' si on veut directement le texte extrait
query <- quorum::createAgoraplusQuery(tags=c('agoraplus'), type='html') # pour plus de contrÙle, on peut gÈnÈrer une query avec createRadarplusQuery ‡ la place
result <- quorum::loadAgoraplusData(query, auth)

```
