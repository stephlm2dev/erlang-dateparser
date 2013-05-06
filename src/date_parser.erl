-module (date_parser).
-author("Schmidely Stéphane").
-vsn(0.1).
-compile([debug_info, export_all]).
-import (string, [tokens/2]).
%-export().

-define(is_num(X),   (X >= $0 andalso X =< $9)).
-define(is_year(X),  (is_integer(X) andalso X > 31)).
-define(is_day(X),   (is_integer(X) andalso X =< 31)).
-define(is_month(X), (is_integer(X) andalso X =< 12)).
-define(is_string(X),(is_list(X))).
-define(GREGORIAN_SECONDS_1970, 62167219200).

-type year()    :: non_neg_integer().
-type month()   :: 1..12.		% .. indicates an interval
-type day() 	:: 1..31.
-type daynum()  :: 1..7.
-type hour()	:: 0..23.
-type minute()  :: 0..59.
-type second()  :: 0..59.

-type date()	 :: {day(),month(),year()}. 		 % ie day/month/year
-type time()	 :: {hour(),minute(),second()}.		 % ie hour H minute min second seconds
-type datetime() :: {date(),time()}.				 % ie day/month/year hour H minute min second seconds
-type now()		 :: {integer(),integer(),integer()}.

% Split the string and analyse each part of the elements

% date() => {2013,4,30}
% time() => {15,22,21}

functions1() -> date().
functions2() -> time().

parse([Year, Month, Day]) ->
	{Day, Month, Year};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% HIER, AUJOURD'HUI, DEMAIN
parse(hier) ->
	Current_date = date(),
	{Year, Month, Day} = setelement(3, Current_date, element(3,Current_date) - 1),
	{Day, Month, Year};
		
parse(aujourdhui) ->	% probleme a regler avec l'apostrophe
	{Year, Month, Day} = date(),
	{Day, Month, Year};

parse(demain) ->
	Current_date = date(),
	{Year, Month, Day} = setelement(3, Current_date, element(3,Current_date) + 1),
	{Day, Month, Year};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DANS X TEMPS / LE X MOIS
parse(Periode) when ?is_string(Periode) ->
	{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
	[Mot, Entier, Type] = tokens(Periode, " "),
	Duree = list_to_integer(Entier),
	Month = ["Janvier","Février","Mars","Avril","Mai","Juin","Juillet",
			 "Août","Septembre","Octobre","Novembre","Décembre"],
	% when (?is_day(X) orelse ?is_month(X))
	case Mot of
		"dans" when ((Type =:= "jours" orelse Type =:= "jour")) ->	%andalso ?is_day(Duree)
			Total = 3600*24*Duree + ?GREGORIAN_SECONDS_1970 + 1367591300,	%faire modification temps en secondes!
			calendar:gregorian_seconds_to_datetime(Total);

		"dans" when ( Type =:= "mois") -> 	%andalso ?is_month(Duree)
			if Duree + Month > 12 -> {Day, (Duree + Month) rem 12, Year};
			   true -> {Day, Duree + Month, Year}
			end;

		"dans" when ((Type =:= "ans" orelse Type =:= "an")) -> 	%andalso is_integer(Duree)
			{Day, Month, Year + Duree};

		"le"  -> "move";	%when (is_integer(Duree))
		_ -> "Mauvaise phrase"
	end;

parse(_) -> 
	erreur.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
