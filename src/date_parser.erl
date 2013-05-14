-module (date_parser).
-author("Schmidely Stephane").
-vsn(1.0).
%-compile([debug_info, export_all]).
-import (string, [tokens/2, concat/2, to_lower/1]).
-export ([analyser/1]).

-define(is_num(X),   (X >= $0 andalso X =< $9)).
-define(is_positif(X), (X > 0)).
-define(is_year(X),  (?is_positif(X) andalso X > 31)).
-define(is_day(X),   (?is_positif(X) andalso X =< 31)).
-define(is_month(X), (?is_positif(X) andalso X =< 12)).
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
			try list_to_integer(Mot) of
				_ -> 
					try list_to_integer(Type) of
						_ -> parse({list_to_integer(Mot), string:to_lower(Entier), list_to_integer(Type)})
					catch
						error:badarg -> 
							"Oops! Something went wrong, please try again"
					end
			catch
				error:badarg ->
					parse({string:to_lower(Mot), string:to_lower(Entier), string:to_lower(Type)})
			end;
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

parse("apres-demain") ->
	Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
	Total = Now_seconds + 3600*24*2,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	{Annee, Mois, Jour};

parse(Jour_saisie) when ?is_string(Jour_saisie) -> 
	Liste_jours = {"lundi", "mardi", "mercredi", "jeudi", "vendredi", "samedi",
				   "dimanche"},
	Numero_jour = is_in_Tuple(Liste_jours, Jour_saisie),
	if  Numero_jour =/= 0 -> % si le jour existe
			Local_time   = {{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
			Now_seconds  = calendar:datetime_to_gregorian_seconds(Local_time),
			Jour_courant = calendar:day_of_the_week(Year, Month, Day),
			Total_jours = Numero_jour - Jour_courant, 
			Total_seconds = Now_seconds + (Total_jours * 24 * 3600),
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
			{Annee, Mois, Jour};
		true -> "Oops! Something went wrong, please try again"
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WEEK-END DERNIERE
parse({"week-end", "dernier"}) -> 
	parse({"samedi", "dernier"});

% SEMAINE DERNIERE
parse({"semaine", "derniere"}) -> 
	Local_time    = {{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
	Now_seconds   = calendar:datetime_to_gregorian_seconds(Local_time),
	Jour_courant  = calendar:day_of_the_week(Year, Month, Day),
	Fin_semaine   = 7 + (Jour_courant - 1) ,
	Total_seconds = Now_seconds - (Fin_semaine * 24 * 3600),
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
	{Annee, Mois, Jour};

% L'ANNEE DERNIERE
parse({"l'annee", "derniere"}) -> 
	{{Year,_,_}, {_,_,_}} = calendar:local_time(),
	{Year - 1, 1, 1};

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
				true -> Total_jours = (7 - Numero_jour) + Jour_courant
			end,
			Total_seconds = Now_seconds - (Total_jours * 24 * 3600),
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
			{Annee, Mois, Jour};
		true -> "Oops! Something went wrong, please try again"
	end;

% WEEK-END PROCHAIN
parse({"week-end", "prochain"}) -> 
	parse({"samedi", "prochain"});

% SEMAINE PROCHAINE
parse({"semaine", "prochaine"}) -> 
	Local_time    = {{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
	Now_seconds   = calendar:datetime_to_gregorian_seconds(Local_time),
	Jour_courant  = calendar:day_of_the_week(Year, Month, Day),
	Fin_semaine   = (7 - Jour_courant) + 1,
	Total_seconds = Now_seconds + (Fin_semaine * 24 * 3600),
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
	{Annee, Mois, Jour};

% L'ANNEE PROCHAINE
parse({"l'annee", "prochaine"}) -> 
	{{Year,_,_}, {_,_,_}} = calendar:local_time(),
	{Year + 1, 1, 1};

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
				true -> Total_jours = (7 - Jour_courant) + Numero_jour
			end,
			Total_seconds = Now_seconds + (Total_jours * 24 * 3600),
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
			{Annee, Mois, Jour};
		true -> "Oops! Something went wrong, please try again"
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LE X MOIS
parse({"le", Entier, Type}) ->
	Liste_mois = {"janvier","fevrier","mars","avril","mai","juin","juillet",
				  "aout","septembre","octobre","novembre","decembre"},
	Numero_mois = is_in_Tuple(Liste_mois, Type),
	if (Numero_mois == 0) -> "Oops! Something went wrong, please try again";
		true -> 
			try list_to_integer(Entier) of
				_ -> 
					Duree = list_to_integer(Entier),
					{{Year,_, Day}, {_,_,_}} = calendar:local_time(),
					LastDay_month = calendar:last_day_of_the_month(Year, Numero_mois),
					if (Duree < LastDay_month + 1) -> 
						setelement(3, {Year, Numero_mois, Day}, Duree);
						true -> "Oops! Something went wrong, please try again"
					end
			catch
				error:badarg->
					"Oops! Something went wrong, please try again"
			end
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DANS X JOUR(S) 
parse({"dans", Entier, Type}) when (Type =:= "jours" orelse Type =:= "jour") ->
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) -> 
				Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
				Total = 3600*24*Duree + Now_seconds,
				{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
				{Annee, Mois, Jour};
				true -> "Oops! Something went wrong, please try again"
			end
	catch
		error:badarg->
			"Oops! Something went wrong, please try again"
	end;	

% DANS X MOIS
parse({"dans", Entier, "mois"})  -> 
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
				Total = Duree + Month, 
				if  Total > 12 -> {Year + (Total div 12), Total rem 12, Day};
					true -> {Year, Duree + Month, Day}
				end;
				true -> "Oops! Something went wrong, please try again"
			end
	catch
		error:badarg->
			"Oops! Something went wrong, please try again"
	end;

% DANS X AN(S)
parse({"dans", Entier, Type}) when (Type =:= "ans" orelse Type =:= "an") ->
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
				{Year + Duree, Month, Day};
				true -> "Oops! Something went wrong, please try again"
			end
	catch
		error:badarg->
			"Oops! Something went wrong, please try again"
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IL Y A X JOUR(S)
parse({"ilya", Entier, Type}) when (Type =:= "jours" orelse Type =:= "jour") ->
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				Now_seconds = calendar:datetime_to_gregorian_seconds(calendar:local_time()),
				Total = Now_seconds - 3600 * 24 * Duree,
				{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
				{Annee, Mois, Jour};
				true -> "Oops! Something went wrong, please try again"
			end
	catch
		error:badarg->
			"Oops! Something went wrong, please try again"
	end;

% IL Y A X MOIS
parse({"ilya", Entier, "mois"})  -> 
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
				Total_Annee = Duree + Month, 
				Total_Mois = positif(Month - Duree), 
				if
					Total_Mois =:= 12 -> {Year - (Total_Annee div 12) -1, 12, Day};
					Duree > Month -> {Year - (Total_Annee div 12), Total_Mois rem 12, Day};
					true -> {Year, Month - Duree, Day}
				end;
				
				true -> "Oops! Something went wrong, please try again"
			end
	catch
		error:badarg->
			"Oops! Something went wrong, please try again"
	end;

% IL Y A X AN(S)
parse({"ilya", Entier, Type}) when (Type =:= "ans" orelse Type =:= "an") ->
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				{{Year, Month, Day}, {_,_,_}} = calendar:local_time(),
				{Year - Duree, Month, Day};
				true -> "Oops! Something went wrong, please try again"
			end
	catch
		error:badarg->
			"Oops! Something went wrong, please try again"
	end;

parse({Mot, Entier, Type}) when ?is_day(Mot) andalso ?is_year(Type) ->
	Liste_mois = {"janvier","fevrier","mars","avril","mai","juin","juillet",
				  "aout","septembre","octobre","novembre","decembre"},
	Numero_mois = is_in_Tuple(Liste_mois, Entier),
	if (Numero_mois =/= 0) -> 
		LastDay_month = calendar:last_day_of_the_month(Type, Numero_mois),
		if (Mot < LastDay_month + 1) -> 
			{Type, Numero_mois, Mot};
			true -> "Oops! Something went wrong, please try again"
		end;
		true -> "Oops! Something went wrong, please try again"
	end;

parse(_) -> 
	"Oops! Something went wrong, please try again".

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTIONS ANNEXES 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% verifie si l'element est présent dans le tuple et le cas échéant 
% renvoie sa position
is_in_Tuple(Tuple, Word) -> is_in_Tuple(Tuple, Word, 0).

is_in_Tuple(Tuple, Word, N) when N < 13 ->
	if  (element(N,Tuple) =:= Word) -> N;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							BUGS CONNNUS  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Problème encodage -> regex sur les mois ou normalisation en amont