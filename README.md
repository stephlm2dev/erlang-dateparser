Erlang-dateparser
=================

A date parser made in Erlang

Gère actuellement : 
- il y a X jours/semaines/mois/ans
- dans X jours/semaines/mois/ans
- le X mois
- JOUR prochain/dernier
- avant-hier, hier, aujourd'hui, demain, après-demain
- semaine prochaine/derniere
- week-end prochain/dernier
- l'annee prochaine/dernière
- JOUR 
- JOUR MOIS ANNEE

## How it works
### Compilation
1> c(date_parser).
### Requête
2> date_parser:analyser("your_search_between_quotes", LIST).
### Valeur de retour 
[list_analyzed,{date,{Annee, Mois, Jour}}]
