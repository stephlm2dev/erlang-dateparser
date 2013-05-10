-module (date_parser).
-author("Schmidely Stephane").
-vsn(0.1).
%-compile([debug_info, export_all]).
-import (string, [tokens/2, concat/2]).
-export ([analyser/1]).

-define(is_num(X),   (X >= $0 andalso X =< $9)).
-define(is_year(X),  (is_integer(X) andalso X > 31)).
-define(is_day(X),   (is_integer(X) andalso X =< 31)).
-define(is_month(X), (is_integer(X) andalso X =< 12)).
-define(is_string(X),(is_list(X))).
-define(GREGORIAN_SECONDS_1970, 62167219200).

-type year()    :: non_neg_integer().
-type month()   :: 1..12.							  % .. indicates an interval
-type day() 	:: 1..31.
-type daynum()  :: 1..7.
-type hour()	:: 0..23.
-type minute()  :: 0..59.
-type second()  :: 0..59.

-type date()	 :: {day(),month(),year()}. 		  % ie day/month/year
-type time()	 :: {hour(),minute(),second()}.		  % ie hour H minute min second seconds
-type datetime() :: {date(),time()}.				  % ie day/month/year hour H minute min second seconds

% Split the string and analyse each part of the elements

% date() => {2013,4,30}
% time() => {15,22,21}

functions1() -> date().
functions2() -> time().

analyser(Date) when ?is_string(Date) ->
	List_date = list_to_tuple(tokens(Date, " ")),
	case tuple_size(List_date) of
		1 ->	% avant-hier
			parse(List_date);
		2 -> 	% samedi prochain
			parse({Jour_saisie, Periode} = List_date);
		3 -> 	% dans 2 jours 
			parse({Mot, Entier, Type} = List_date);
		5 -> 	% il y a 2 mois
			parse({_, _, _, Duree, Type} = List_date);
		_ -> 
			"Oops! Something went wrong, please try again"
	end;

analyser(_) -> 
	"Oops! Something went wrong, please try again".

parse([Year, Month, Day]) ->
	{Day, Month, Year};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AVANT-HIER, HIER, AUJOURD'HUI, APRES-DEMAIN
parse("avant-hier") ->
	Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Total = Now_seconds - 3600*24*2 ,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	{Annee, Mois, Jour};

parse("hier") ->
	Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Total = Now_seconds - 3600*24,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	{Annee, Mois, Jour};
		
parse("aujourd'hui") ->	% probleme a regler avec l'apostrophe
	{Annee, Mois, Jour} = date();

parse("demain") ->
	Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Total = Now_seconds + 3600*24,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	{Annee, Mois, Jour};

parse("apres-demain") ->	% voir comment résoudre le probleme des accents
	Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Total = Now_seconds + 3600*24*2,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	{Annee, Mois, Jour};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

parse({Jour_saisie, Periode}) ->
	% convertir en minuscule Jour_saisie
	Liste_jours = {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi", "dimanche"},
	Numero_jour = is_in_Tuple(Liste_jours, Jour_saisie),
	if  Numero_jour =/= 0 -> % si le jour existe
		Local_time   = {{Year, Month, Day}, {Hour, Minute, Second}} = calendar:local_time(),
		Now_seconds  = calendar:datetime_to_gregorian_seconds(Local_time),
		Jour_courant = calendar:day_of_the_week(Year, Month, Day),
		case Periode of
			"prochain" ->
				if Numero_jour > Jour_courant -> 
					Total_jours = Numero_jour - Jour_courant;
					true -> Total_jours = (7 rem Jour_courant) + Numero_jour
				end,
				Total_seconds = Now_seconds + (Total_jours * 24 * 3600),
				{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
				{Annee, Mois, Jour};
			"dernier" ->
				if Numero_jour < Jour_courant -> 
					Total_jours = Jour_courant - Numero_jour;
					true -> Total_jours = (7 rem Numero_jour) + Jour_courant
				end,
				Total_seconds = Now_seconds - (Total_jours * 24 * 3600),
				{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
				{Annee, Mois, Jour};
			_ -> 
				"Oops! Something went wrong, please try again"
		end;
		true -> "Oops! Something went wrong, please try again"
	end;

% DANS X TEMPS / LE X MOIS
parse(Periode) when ?is_string(Periode) ->
	{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
	[Mot, Entier, Type] = tokens(Periode, " "),
	Duree = list_to_integer(Entier),
	Liste_mois = {"Janvier","Fevrier","Mars","Avril","Mai","Juin","Juillet",
				 "Aout","Septembre","Octobre","Novembre","Decembre"},
	% when (?is_day(X) orelse ?is_month(X))
	case Mot of
		"dans" when (Type =:= "jours" orelse Type =:= "jour") andalso is_integer(Duree) ->	
			Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
			Total = 3600*24*Duree + Now_seconds,
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
			{Annee, Mois, Jour};

		"dans" when ( Type =:= "mois") -> 	%andalso ?is_month(Duree) %%%%%%% A CHANGER
			Total = Duree + Month, 
			if  Total > 12 -> {Year + (Total div 12), Total rem 12, Day};
				true -> {Year, Duree + Month, Day}
			end;

		"dans" when (Type =:= "ans" orelse Type =:= "an") -> 	%andalso is_integer(Duree)
			{Year + Duree, Month, Day};

		"le" when ?is_day(Duree) -> % andalso si present dans le tuple
			Numero_mois = is_in_Tuple(Liste_mois, Type),
			{Annee, Mois, Jour} = setelement(3, {Year, Numero_mois, Day}, Duree);
		_ -> "Oops! Something went wrong, please try again"
	end;

parse(_) -> 
	"Oops! Something went wrong, please try again".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% verifie si l'element est présent dans le tuple et le cas échéant renvoie sa position
is_in_Tuple(Tuple, Word) -> is_in_Tuple(Tuple, Word, 0).

is_in_Tuple(Tuple, Word, N) when N < 13 ->
	if 
		(element(N,Tuple) =:= Word) -> N;
		true -> is_in_Tuple(Tuple, Word, N+1)
	end;

is_in_Tuple(Tuple, Word, 13) -> 0.

% converti une valeur négative en positive
positif(Value) when Value =< 0 -> 
	if 
		(Value > 0) -> Value;
		true -> positif(Value + 12)
	end;

positif(Value) -> Value.

% converti en minuscule
% minuscule()

%%%%
%	"il y a" when (Type =:= "jours" orelse Type =:= "jour") andalso is_integer(Duree) ->	
%		Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
%		Total = Now_seconds - 3600*24*Duree,
%		calendar:gregorian_seconds_to_datetime(Total);
%
%	"il y a" when ( Type =:= "mois") -> 	%andalso ?is_month(Duree)
%		Total_Annee = Duree + Month, 
%			Total_Mois = positif(Month - Duree), 
%			if
%				Total_Mois =:= 12 -> {Year - (Total_Annee div 12) -1, 12, Day};
%				Duree > Month -> {Year - (Total_Annee div 12), Total_Mois rem 12, Day};
%		   		true -> {Year, Month - Duree, Day}
%		   	end;
%
%	"il y a" when (Type =:= "ans" orelse Type =:= "an") -> 	%andalso is_integer(Duree)
%		{Year - Duree, Month, Day};

