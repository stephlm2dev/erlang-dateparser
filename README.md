Erlang-dateparser
=================

A date parser made in Erlang

Gère actuellement : 
- il y a X jours/mois/ans
- dans X jours/mois/ans
- le X mois
- JOUR prochain/dernier
- avant-hier, hier, aujourd'hui, demain, après-demain
- semaine prochaine/derniere
- week-end prochain/dernier
- l'annee prochaine/dernière
- JOUR 

# How it works
## Compilation
1> c(date_parser).
## Requête
2> date_parser:analyser("your_search_between_quotes").
## Valeur de retour 
{Annee, Mois, Jour}

## Exemple d'utilisation 

1> c(date_parser).   
2> date_parser:analyser("dans 5 jours").   
{2013, 5, 19}
3> 

