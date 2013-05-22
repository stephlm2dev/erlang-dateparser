-module (date_parser_tests).
-include_lib("eunit/include/eunit.hrl").
-author("Schmidely Stephane").
-vsn(1.0).
-import (date_parser, [analyser/2]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							TESTS UNITAIRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parse_test() -> 
	[
		{"Avant-hier",		 ?assert([{lieu,{1,1}},{date,{2013,5,12}}]  =:= date_parser:analyser("Avant-hier", [{lieu, {1,1}}]))}, 
		{"Hier",	  		 ?assert([{lieu,{1,1}},{date,{2013,5,13}}]  =:= date_parser:analyser("Hier", [{lieu, {1,1}}]))},
		{"Aujourd'hui",		 ?assert([{lieu,{1,1}},{date,date()}]       =:= date_parser:analyser("Aujourd'hui", [{lieu, {1,1}}]))},
		{"Demain",			 ?assert([{lieu,{1,1}},{date,{2013,5,15}}]  =:= date_parser:analyser("Demain", [{lieu, {1,1}}]))},
		{"Apres-demain",	 ?assert([{lieu,{1,1}},{date,{2013,5,16}}]  =:= date_parser:analyser("Apres-demain", [{lieu, {1,1}}]))},
		{"LuNdi",			 ?assert([{lieu,{1,1}},{date,{2013,5,13}}]  =:= date_parser:analyser("LuNdi", [{lieu, {1,1}}]))},
		{"Mardi",			 ?assert([{lieu,{1,1}},{date,{2013,5,14}}]  =:= date_parser:analyser("mardi", [{lieu, {1,1}}]))},
		{"MERCREDI",		 ?assert([{lieu,{1,1}},{date,{2013,5,15}}]  =:= date_parser:analyser("MERCREDI", [{lieu, {1,1}}]))},
		{"jeudi",			 ?assert([{lieu,{1,1}},{date,{2013,5,16}}]  =:= date_parser:analyser("jeudi", [{lieu, {1,1}}]))},
		{"VeNDrEdI",		 ?assert([{lieu,{1,1}},{date,{2013,5,17}}]  =:= date_parser:analyser("VeNDrEdI", [{lieu, {1,1}}]))},
		{"samedi", 			 ?assert([{lieu,{1,1}},{date,{2013,5,18}}]  =:= date_parser:analyser("samedi", [{lieu, {1,1}}]))},
		{"dimanchE", 		 ?assert([{lieu,{1,1}},{date,{2013,5,19}}]  =:= date_parser:analyser("dimanchE", [{lieu, {1,1}}]))},
		{"week-end dernier", ?assert([{lieu,{1,1}},{date,{2013,5,11}}]  =:= date_parser:analyser("week-end dernier", [{lieu, {1,1}}]))},
		{"semaine derniere", ?assert([{lieu,{1,1}},{date,{2013,5,6}}]   =:= date_parser:analyser("semaine derniere", [{lieu, {1,1}}]))},
		{"l'annee derniere", ?assert([{lieu,{1,1}},{date,{2012,1,1}}]   =:= date_parser:analyser("l'annee derniere", [{lieu, {1,1}}]))},
		{"lundi dernier", 	 ?assert([{lieu,{1,1}},{date,{2013,5,13}}]  =:= date_parser:analyser("lundi dernier", [{lieu, {1,1}}]))},
		{"mardi dernier", 	 ?assert([{lieu,{1,1}},{date,{2013,5,7}}]   =:= date_parser:analyser("mardi dernier", [{lieu, {1,1}}]))},
		{"mercredi dernier", ?assert([{lieu,{1,1}},{date,{2013,5,8}}]   =:= date_parser:analyser("mercredi dernier", [{lieu, {1,1}}]))},
		{"jeudi dernier", 	 ?assert([{lieu,{1,1}},{date,{2013,5,9}}]   =:= date_parser:analyser("jeudi dernier", [{lieu, {1,1}}]))},
		{"vendredi dernier", ?assert([{lieu,{1,1}},{date,{2013,5,10}}]  =:= date_parser:analyser("vendredi dernier", [{lieu, {1,1}}]))},
		{"samedi dernier", 	 ?assert([{lieu,{1,1}},{date,{2013,5,11}}]  =:= date_parser:analyser("samedi dernier", [{lieu, {1,1}}]))},
		{"dimanche dernier", ?assert([{lieu,{1,1}},{date,{2013,5,12}}]  =:= date_parser:analyser("dimanche dernier", [{lieu, {1,1}}]))},
		{"week-end prochain",?assert([{lieu,{1,1}},{date,{2013,5,18}}]  =:= date_parser:analyser("week-end prochain", [{lieu, {1,1}}]))},
		{"semaine prochaine",?assert([{lieu,{1,1}},{date,{2013,5,20}}]  =:= date_parser:analyser("semaine prochaine", [{lieu, {1,1}}]))},
		{"l'annee prochaine",?assert([{lieu,{1,1}},{date,{2014,1,1}}]   =:= date_parser:analyser("l'annee prochaine", [{lieu, {1,1}}]))},
		{"lundi prochain", 	 ?assert([{lieu,{1,1}},{date,{2013,5,20}}]  =:= date_parser:analyser("lundi prochain", [{lieu, {1,1}}]))},
		{"mardi prochain", 	 ?assert([{lieu,{1,1}},{date,{2013,5,21}}]  =:= date_parser:analyser("mardi prochain", [{lieu, {1,1}}]))},
		{"mercredi prochain",?assert([{lieu,{1,1}},{date,{2013,5,15}}]  =:= date_parser:analyser("mercredi prochain", [{lieu, {1,1}}]))},
		{"jeudi prochain", 	 ?assert([{lieu,{1,1}},{date,{2013,5,16}}]  =:= date_parser:analyser("jeudi prochain", [{lieu, {1,1}}]))},
		{"vendredi prochain",?assert([{lieu,{1,1}},{date,{2013,5,17}}]  =:= date_parser:analyser("vendredi prochain", [{lieu, {1,1}}]))},
		{"samedi prochain",  ?assert([{lieu,{1,1}},{date,{2013,5,18}}]  =:= date_parser:analyser("samedi prochain", [{lieu, {1,1}}]))},
		{"dimanche prochain",?assert([{lieu,{1,1}},{date,{2013,5,19}}]  =:= date_parser:analyser("dimanche prochain", [{lieu, {1,1}}]))},
		{"le 21 Juin",		 ?assert([{lieu,{1,1}},{date,{2013,6,21}}]  =:= date_parser:analyser("le 21 Juin", [{lieu, {1,1}}]))},
		{"dans 123 JouRs",	 ?assert([{lieu,{1,1}},{date,{2013,9,14}}]  =:= date_parser:analyser("dans 123 JouRs", [{lieu, {1,1}}]))},
		{"dans 2 mois",		 ?assert([{lieu,{1,1}},{date,{2013,7,14}}]  =:= date_parser:analyser("dans 2 mois", [{lieu, {1,1}}]))},
		{"dans 2 ans", 		 ?assert([{lieu,{1,1}},{date,{2015,5,14}}]  =:= date_parser:analyser("dans 2 ans", [{lieu, {1,1}}]))},
		{"il y a 99 joUrs",  ?assert([{lieu,{1,1}},{date,{2013,2,4}}]   =:= date_parser:analyser("il y a 99 joUrs", [{lieu, {1,1}}]))},
		{"il y a 2 mOIs", 	 ?assert([{lieu,{1,1}},{date,{2013,3,14}}]  =:= date_parser:analyser("il y a 2 mOIs", [{lieu, {1,1}}]))},
		{"il y a 2 ans", 	 ?assert([{lieu,{1,1}},{date,{2011,5,14}}]  =:= date_parser:analyser("il y a 2 ans", [{lieu, {1,1}}]))},
		{"20 Janvier 2012",	 ?assert([{lieu,{1,1}},{date,{2012,1,20}}]  =:= date_parser:analyser("20 Janvier 2012", [{lieu, {1,1}}]))},
		{"31 DecEmBre 2014", ?assert([{lieu,{1,1}},{date,{2014,12,31}}] =:= date_parser:analyser("31 DecEmBre 2014", [{lieu, {1,1}}]))}
	].