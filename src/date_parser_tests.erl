-module (date_parser_tests).
-include_lib("eunit/include/eunit.hrl").
-author("Schmidely Stephane").
-vsn(1.0).
-import (date_parser, [analyser/1]).
%-export ([parse_test/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							TESTS UNITAIRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parse_test() -> 
	[
		{"Avant-hier",		 ?assert({2013,5,12}  =:= date_parser:analyser("avant-hier"))}, 
		{"Hier",	  		 ?assert({2013,5,13}  =:= date_parser:analyser("hier"))},
		{"Aujourd'hui",		 ?assert(date()       =:= date_parser:analyser("aujourd'hui"))},
		{"Demain",			 ?assert({2013,5,15}  =:= date_parser:analyser("demain"))},
		{"Apres-demain",	 ?assert({2013,5,16}  =:= date_parser:analyser("apres-demain"))},
		{"LuNdi",			 ?assert({2013,5,13}  =:= date_parser:analyser("LuNdi"))},
		{"Mardi",			 ?assert({2013,5,14}  =:= date_parser:analyser("mardi"))},
		{"MERCREDI",		 ?assert({2013,5,15}  =:= date_parser:analyser("MERCREDI"))},
		{"jeudi",			 ?assert({2013,5,16}  =:= date_parser:analyser("jeudi"))},
		{"VeNDrEdI",		 ?assert({2013,5,17}  =:= date_parser:analyser("VeNDrEdI"))},
		{"samedi", 			 ?assert({2013,5,18}  =:= date_parser:analyser("samedi"))},
		{"dimanchE", 		 ?assert({2013,5,19}  =:= date_parser:analyser("dimanchE"))},
		{"week-end dernier", ?assert({2013,5,11}  =:= date_parser:analyser("week-end dernier"))},
		{"semaine derniere", ?assert({2013,5,6}   =:= date_parser:analyser("semaine derniere"))},
		{"l'annee derniere", ?assert({2012,1,1}   =:= date_parser:analyser("l'annee derniere"))},
		{"lundi dernier", 	 ?assert({2013,5,13}  =:= date_parser:analyser("lundi dernier"))},
		{"mardi dernier", 	 ?assert({2013,5,7}   =:= date_parser:analyser("mardi dernier"))},
		{"mercredi dernier", ?assert({2013,5,8}   =:= date_parser:analyser("mercredi dernier"))},
		{"jeudi dernier", 	 ?assert({2013,5,9}   =:= date_parser:analyser("jeudi dernier"))},
		{"vendredi dernier", ?assert({2013,5,10}  =:= date_parser:analyser("vendredi dernier"))},
		{"samedi dernier", 	 ?assert({2013,5,11}  =:= date_parser:analyser("samedi dernier"))},
		{"dimanche dernier", ?assert({2013,5,12}  =:= date_parser:analyser("dimanche dernier"))},
		{"week-end prochain",?assert({2013,5,18}  =:= date_parser:analyser("week-end prochain"))},
		{"semaine prochaine",?assert({2013,5,20}  =:= date_parser:analyser("semaine prochaine"))},
		{"l'annee prochaine",?assert({2014,1,1}   =:= date_parser:analyser("l'annee prochaine"))},
		{"lundi prochain", 	 ?assert({2013,5,20}  =:= date_parser:analyser("lundi prochain"))},
		{"mardi prochain", 	 ?assert({2013,5,21}  =:= date_parser:analyser("mardi prochain"))},
		{"mercredi prochain",?assert({2013,5,15}  =:= date_parser:analyser("mercredi prochain"))},
		{"jeudi prochain", 	 ?assert({2013,5,16}  =:= date_parser:analyser("jeudi prochain"))},
		{"vendredi prochain",?assert({2013,5,17}  =:= date_parser:analyser("vendredi prochain"))},
		{"samedi prochain",  ?assert({2013,5,18}  =:= date_parser:analyser("samedi prochain"))},
		{"dimanche prochain",?assert({2013,5,19}  =:= date_parser:analyser("dimanche prochain"))},
		{"le 21 Juin",		 ?assert({2013,6,21}  =:= date_parser:analyser("le 21 Juin"))},
		{"dans 123 JouRs",	 ?assert({2013,9,14}  =:= date_parser:analyser("dans 123 JouRs"))},
		{"dans 2 mois",		 ?assert({2013,7,14}  =:= date_parser:analyser("dans 2 mois"))},
		{"dans 2 ans", 		 ?assert({2015,5,14}  =:= date_parser:analyser("dans 2 ans"))},
		{"il y a 99 joUrs",  ?assert({2013,2,4}   =:= date_parser:analyser("il y a 99 joUrs"))},
		{"il y a 2 mOIs", 	 ?assert({2013,3,14}  =:= date_parser:analyser("il y a 2 mOIs"))},
		{"il y a 2 ans", 	 ?assert({2011,5,14}  =:= date_parser:analyser("il y a 2 ans"))},
		{"20 Janvier 2012",	 ?assert({2012,1,20}  =:= date_parser:analyser("20 Janvier 2012"))},
		{"31 DecEmBre 2014", ?assert({2014,12,31} =:= date_parser:analyser("31 DecEmBre 2014"))}
	].