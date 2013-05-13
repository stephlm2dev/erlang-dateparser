-module (date_parser).
-author("Schmidely Stephane").
-vsn(1.0).
%-compile([debug_info, export_all]).
-import (string, [tokens/2, concat/2, to_lower/1]).
-export ([analyser/1]).

-define(is_num(X),   (X >= $0 andalso X =< $9)).
-define(is_year(X),  (is_integer(X) andalso X > 31)).
-define(is_day(X),   (is_integer(X) andalso X =< 31)).
-define(is_month(X), (is_integer(X) andalso X =< 12)).
-define(is_string(X),(is_list(X))).
-define(GREGORIAN_SECONDS_1970, 62167219200).

% Split the string and analyse each part of the elements

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTION PRINCIPALE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

analyser(Date) when ?is_string(Date) ->
	List_date = list_to_tuple(tokens(Date, " ")),
	case tuple_size(List_date) of
		1 ->	% avant-hier
			{Jour_saisie} = List_date,
			parse(string:to_lower(Jour_saisie));
		2 -> 	% samedi prochain
			{Jour_saisie, Periode} = List_date,
			parse({string:to_lower(Jour_saisie), string:to_lower(Periode)});
		3 -> 	% dans 2 jours // 12 Mai 2012 
			{Mot, Entier, Type} = List_date,
			parse({string:to_lower(Mot), string:to_lower(Entier), string:to_lower(Type)});
		5 -> 	% il y a 2 mois
			{Mot1, Mot2, Mot3, Entier, Type} = List_date,
			Mot = string:concat(Mot1, string:concat(Mot2, Mot3)),
			parse({string:to_lower(Mot), string:to_lower(Entier), string:to_lower(Type)});
		_ -> 
			"Oops! Something went wrong, please try again"
	end;

analyser(_) -> 
	"Oops! Something went wrong, please try again".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTIONS PARSE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AVANT-HIER, HIER, AUJOURD'HUI, DEMAIN, APRES-DEMAIN
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
		
parse("aujourd'hui") ->
	date();

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% JOUR PROCHAIN
parse({Jour_saisie, "prochain"}) ->
	Liste_jours = {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi",
				   "dimanche"},
	Numero_jour = is_in_Tuple(Liste_jours, Jour_saisie),
	if  Numero_jour =/= 0 -> % si le jour existe
			Local_time   = {{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
			Now_seconds  = calendar:datetime_to_gregorian_seconds(Local_time),
			Jour_courant = calendar:day_of_the_week(Year, Month, Day),
			if Numero_jour > Jour_courant -> 
				Total_jours = Numero_jour - Jour_courant;
				true -> Total_jours = (7 rem Jour_courant) + Numero_jour
			end,
			Total_seconds = Now_seconds + (Total_jours * 24 * 3600),
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
			{Annee, Mois, Jour};
		true -> "Oops! Something went wrong, please try again"
	end;

% JOUR DERNIER
parse({Jour_saisie, "dernier"}) ->
	Liste_jours = {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi",
				   "dimanche"},
	Numero_jour = is_in_Tuple(Liste_jours, Jour_saisie),
	if  Numero_jour =/= 0 -> % si le jour existe
			Local_time   = {{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
			Now_seconds  = calendar:datetime_to_gregorian_seconds(Local_time),
			Jour_courant = calendar:day_of_the_week(Year, Month, Day),
			if Numero_jour < Jour_courant -> 
				Total_jours = Jour_courant - Numero_jour;
				true -> Total_jours = (7 rem Numero_jour) + Jour_courant
			end,
			Total_seconds = Now_seconds - (Total_jours * 24 * 3600),
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
			{Annee, Mois, Jour};
		true -> "Oops! Something went wrong, please try again"
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LE X MOIS
parse({"le", Entier, Type }) ->
	{{Year,_, Day}, {_,_,_}} = calendar:local_time(),
	Liste_mois = {"janvier","fevrier","mars","avril","mai","juin","juillet",
				  "aout","septembre","octobre","novembre","decembre"},
	Numero_mois = is_in_Tuple(Liste_mois, Type),
	if (Numero_mois == 0) -> "Oops! Something went wrong, please try again";
		true -> setelement(3, {Year, Numero_mois, Day}, list_to_integer(Entier))
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DANS X JOUR(S) 
parse({"dans", Entier, Type}) when (Type =:= "jours" orelse Type =:= "jour") ->
	% andalso is_integer(list_to_integer(Entier)) 
	Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Total = 3600*24* list_to_integer(Entier) + Now_seconds,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	{Annee, Mois, Jour};

% DANS X MOIS
parse({"dans", Entier, "mois"})  -> 
	% is_integer(list_to_integer(Entier))
	{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
	Duree = list_to_integer(Entier),	% TRY _ CATCH
	Total = Duree + Month, 
	if  Total > 12 -> {Year + (Total div 12), Total rem 12, Day};
		true -> {Year, Duree + Month, Day}
	end;

% DANS X AN(S)
parse({"dans", Entier, Type}) when (Type =:= "ans" orelse Type =:= "an") ->
	% andalso is_integer(list_to_integer(Entier)) 
	{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
	{Year + list_to_integer(Entier), Month, Day};


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IL Y A X JOUR(S)
parse({"ilya", Entier, Type}) when (Type =:= "jours" orelse Type =:= "jour") ->
	% andalso is_integer(list_to_integer(Entier)) 
	Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Total = Now_seconds - 3600 * 24 * list_to_integer(Entier),
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	{Annee, Mois, Jour};

% IL Y A X MOIS
parse({"ilya", Entier, "mois"})  -> 
	% is_integer(list_to_integer(Entier))
	{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
	Duree = list_to_integer(Entier),
	Total_Annee = Duree + Month, 
	Total_Mois = positif(Month - Duree), 
	if
		Total_Mois =:= 12 -> {Year - (Total_Annee div 12) -1, 12, Day};
		Duree > Month -> {Year - (Total_Annee div 12), Total_Mois rem 12, Day};
		true -> {Year, Month - Duree, Day}
	end;

% IL Y A X AN(S)
parse({"ilya", Entier, Type}) when (Type =:= "ans" orelse Type =:= "an") ->
	% andalso is_integer(list_to_integer(Entier)) 
	{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
	{Year - list_to_integer(Entier) , Month, Day};

parse(_) -> 
	"Oops! Something went wrong, please try again".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTIONS ANNEXES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% verifie si l'element est présent dans le tuple et le cas échéant 
% renvoie sa position
is_in_Tuple(Tuple, Word) -> is_in_Tuple(Tuple, Word, 0).

is_in_Tuple(Tuple, Word, N) when N < 13 ->
	if 
		(element(N,Tuple) =:= Word) -> N;
		true -> is_in_Tuple(Tuple, Word, N+1)
	end;

is_in_Tuple(_,_, 13) -> 0.

% converti une valeur négative en positive
positif(Value) when Value =< 0 -> 
	if 
		(Value > 0) -> Value;
		true -> positif(Value + 12)
	end;

positif(Value) -> Value.