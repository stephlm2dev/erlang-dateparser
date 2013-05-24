-module (date_parser).
-author("Schmidely Stephane").
-vsn(1.0).
-export ([analyser/2]).
-export([start/2, stop/1]).
-behaviour (application).
-include("../include/date_parser.hrl").

-ifdef(TEST).
	get_time() -> {{2013, 5, 14}, {0,0,0}}. % pour les tests unitaires
-else.
	get_time() -> calendar:local_time(). 	% pour le programme général
-endif.

% @Brief Split the string and analyse each part of the elements
% @Param query string
% @Return a tuple {Year, Month, Day}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTION PRINCIPALE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start(_StartType, _StartArgs) -> ok.
stop(_State)-> ok.

analyser(QueryString, Analyzed) when is_list(QueryString) ->
	List_date = list_to_tuple(string:tokens(QueryString, " ")),
	case tuple_size(List_date) of
		1 ->	% avant-hier
			{Jour_saisie} = List_date,
			parse({string:to_lower(Jour_saisie), Analyzed});
		2 -> 	% samedi prochain
			{Jour_saisie, Periode} = List_date,
			parse({string:to_lower(Jour_saisie), string:to_lower(Periode), Analyzed});
		3 -> 	% dans 2 jours // 12 Mai 2012 
			{Mot, Entier, Type} = List_date,
			try list_to_integer(Mot) of
				_ -> 
					try list_to_integer(Type) of
						_ -> parse({list_to_integer(Mot), string:to_lower(Entier), 
									list_to_integer(Type), Analyzed})
					catch
						error:badarg -> 
							{error,not_a_year}
					end
			catch
				error:badarg ->
					parse({string:to_lower(Mot), string:to_lower(Entier), string:to_lower(Type), Analyzed})
			end;
		5 -> 	% il y a 2 mois
			{Mot1, Mot2, Mot3, Entier, Type} = List_date,
			Mot = string:concat(Mot1, string:concat(Mot2, Mot3)),
			parse({string:to_lower(Mot), string:to_lower(Entier), string:to_lower(Type), Analyzed});
		_ -> 
			{error, not_matching}
	end;

analyser(_,_) -> 
	{error, not_string}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%							FONCTIONS PARSE 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% AVANT-HIER, HIER, AUJOURD'HUI, DEMAIN, APRES-DEMAIN
parse({"avant-hier", Analyzed}) ->
	Now_seconds = calendar:datetime_to_gregorian_seconds(get_time()),
	Total = Now_seconds - 3600*24*2 ,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	lists:append(Analyzed, [{date,{Annee, Mois, Jour}}]);

parse({"hier", Analyzed}) ->
	Now_seconds = calendar:datetime_to_gregorian_seconds(get_time()),
	Total = Now_seconds - 3600*24,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);
		
parse({"aujourd'hui", Analyzed}) ->
	lists:append(Analyzed, [{date, date()}]);

parse({"demain", Analyzed}) ->
	Now_seconds = calendar:datetime_to_gregorian_seconds(get_time()),
	Total = Now_seconds + 3600*24,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);

parse({"apres-demain", Analyzed}) ->
	Now_seconds = calendar:datetime_to_gregorian_seconds(get_time()),
	Total = Now_seconds + 3600*24*2,
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
	lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);

parse({Jour_saisie, Analyzed}) when is_list(Jour_saisie) -> 
	Numero_jour = is_in_Tuple(?Liste_jours, Jour_saisie),
	if  Numero_jour =/= 0 -> % si le jour existe
			Local_time   = {{Year, Month, Day}, {_,_,_}} = get_time(),
			Now_seconds  = calendar:datetime_to_gregorian_seconds(Local_time),
			Jour_courant = calendar:day_of_the_week(Year, Month, Day),
			Total_jours = Numero_jour - Jour_courant, 
			Total_seconds = Now_seconds + (Total_jours * 24 * 3600),
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
			lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);
		true -> {error, unknown_day}
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WEEK-END DERNIERE
parse({"week-end", "dernier", Analyzed}) -> 
	parse({"samedi", "dernier", Analyzed});

% SEMAINE DERNIERE
parse({"semaine", "derniere", Analyzed}) -> 
	Local_time    = {{Year, Month, Day}, {_,_,_}} = get_time(),
	Now_seconds   = calendar:datetime_to_gregorian_seconds(Local_time),
	Jour_courant  = calendar:day_of_the_week(Year, Month, Day),
	Fin_semaine   = 7 + (Jour_courant - 1) ,
	Total_seconds = Now_seconds - (Fin_semaine * 24 * 3600),
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
	lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);

% L'ANNEE DERNIERE
parse({"l'annee", "derniere", Analyzed}) -> 
	{{Year,_,_}, {_,_,_}} = get_time(),
	lists:append(Analyzed, [{date, {Year - 1, 1, 1}}]);

% JOUR DERNIER
parse({Jour_saisie, "dernier", Analyzed}) ->
	Numero_jour = is_in_Tuple(?Liste_jours, Jour_saisie),
	if  Numero_jour =/= 0 -> % si le jour existe
			Local_time   = {{Year, Month, Day}, {_,_,_}} = get_time(),
			Now_seconds  = calendar:datetime_to_gregorian_seconds(Local_time),
			Jour_courant = calendar:day_of_the_week(Year, Month, Day),
			if Numero_jour < Jour_courant -> 
				Total_jours = Jour_courant - Numero_jour;
				true -> Total_jours = (7 - Numero_jour) + Jour_courant
			end,
			Total_seconds = Now_seconds - (Total_jours * 24 * 3600),
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
			lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);
		true -> {error, unknown_day}
	end;

% WEEK-END PROCHAIN
parse({"week-end", "prochain", Analyzed}) -> 
	parse({"samedi", "prochain", Analyzed});

% SEMAINE PROCHAINE
parse({"semaine", "prochaine", Analyzed}) -> 
	Local_time    = {{Year, Month, Day}, {_,_,_}} = get_time(),
	Now_seconds   = calendar:datetime_to_gregorian_seconds(Local_time),
	Jour_courant  = calendar:day_of_the_week(Year, Month, Day),
	Fin_semaine   = (7 - Jour_courant) + 1,
	Total_seconds = Now_seconds + (Fin_semaine * 24 * 3600),
	{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
	lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);

% L'ANNEE PROCHAINE
parse({"l'annee", "prochaine", Analyzed}) -> 
	{{Year,_,_}, {_,_,_}} = get_time(),
	lists:append(Analyzed, [{date, {Year + 1, 1, 1}}]);

% JOUR PROCHAIN
parse({Jour_saisie, "prochain", Analyzed}) ->
	Numero_jour = is_in_Tuple(?Liste_jours, Jour_saisie),
	if  Numero_jour =/= 0 -> % si le jour existe
			Local_time   = {{Year, Month, Day}, {_,_,_}} = get_time(),
			Now_seconds  = calendar:datetime_to_gregorian_seconds(Local_time),
			Jour_courant = calendar:day_of_the_week(Year, Month, Day),
			if Numero_jour > Jour_courant -> 
				Total_jours = Numero_jour - Jour_courant;
				true -> Total_jours = (7 - Jour_courant) + Numero_jour
			end,
			Total_seconds = Now_seconds + (Total_jours * 24 * 3600),
			{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total_seconds),
			lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);
		true -> {error, unknown_day}
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% LE X MOIS
parse({"le", Entier, Type, Analyzed}) ->
	Numero_mois = is_in_Tuple(?Liste_mois, Type),
	if (Numero_mois == 0) -> {error, unknown_month};
		true -> 
			try list_to_integer(Entier) of
				_ -> 
					Duree = list_to_integer(Entier),
					{{Year,_, Day}, {_,_,_}} = get_time(),
					LastDay_month = calendar:last_day_of_the_month(Year, Numero_mois),
					if (Duree < LastDay_month + 1) -> 
						lists:append(Analyzed, [{date, setelement(3, {Year, Numero_mois, Day}, Duree)}]);
						true -> {error, invalid_day}
					end
			catch
				error:badarg -> {error, not_day}
			end
	end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DANS X JOUR(S) 
parse({"dans", Entier, Type, Analyzed}) when (Type =:= "jours" orelse Type =:= "jour") ->
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) -> 
				Now_seconds = calendar:datetime_to_gregorian_seconds(get_time()),
				Total = 3600*24*Duree + Now_seconds,
				{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
				lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);
				true -> {error, not_a_unsigned_int}
			end
	catch
		error:badarg -> {error, not_integer}
	end;

% DANS X MOIS
parse({"dans", Entier, "mois", Analyzed}) -> 
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				{{Year, Month, Day}, {_,_,_}} = get_time(),
				Total = Duree + Month, 
				if  Total > 12 -> lists:append(Analyzed, [{date, {Year + (Total div 12), Total rem 12, Day}}]);
					true -> lists:append(Analyzed, [{date, {Year, Duree + Month, Day}}])
				end;
				true -> {error, not_a_unsigned_int}
			end
	catch
		error:badarg -> {error, not_integer}
	end;	

% DANS X AN(S)
parse({"dans", Entier, Type, Analyzed}) when (Type =:= "ans" orelse Type =:= "an") ->
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				{{Year, Month, Day}, {_,_,_}} = get_time(),
				lists:append(Analyzed, [{date, {Year + Duree, Month, Day}}]);
				true -> {error, not_a_unsigned_int}
			end
	catch
		error:badarg -> {error, not_integer}
	end;	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% IL Y A X JOUR(S)
parse({"ilya", Entier, Type, Analyzed}) when (Type =:= "jours" orelse Type =:= "jour") ->
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				Now_seconds = calendar:datetime_to_gregorian_seconds(get_time()),
				Total = Now_seconds - 3600 * 24 * Duree,
				{{Annee, Mois, Jour}, {_,_,_}} = calendar:gregorian_seconds_to_datetime(Total),
				lists:append(Analyzed, [{date, {Annee, Mois, Jour}}]);
				true -> {error, not_a_unsigned_int}
			end
	catch
		error:badarg -> {error, not_integer}
	end;

% IL Y A X MOIS
parse({"ilya", Entier, "mois", Analyzed})  -> 
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				{{Year, Month, Day}, {_,_,_}} = get_time(),
				Total_Annee = Duree + Month, 
				Total_Mois = positif(Month - Duree), 
				if
					Total_Mois =:= 12 -> lists:append(Analyzed, [{date, {Year - (Total_Annee div 12) -1, 12, Day}}]);
					Duree > Month -> lists:append(Analyzed, [{date, {Year - (Total_Annee div 12), Total_Mois rem 12, Day}}]);
					true -> lists:append(Analyzed, [{date, {Year, Month - Duree, Day}}])
				end;
			true -> {error, not_a_unsigned_int}
			end
	catch
		error:badarg -> {error, not_integer}
	end;

% IL Y A X AN(S)
parse({"ilya", Entier, Type, Analyzed}) when (Type =:= "ans" orelse Type =:= "an") ->
	try list_to_integer(Entier) of
		_ -> 
			Duree = list_to_integer(Entier),
			if (?is_positif(Duree)) ->
				{{Year, Month, Day}, {_,_,_}} = get_time(),
				lists:append(Analyzed, [{date, {Year - Duree, Month, Day}}]);
				true -> {error, not_a_unsigned_int}
			end
	catch
		error:badarg -> {error, not_integer}
	end;

% 2 JUIN 2012 
parse({Mot, Entier, Type, Analyzed}) when ?is_positif(Mot) andalso Mot =< 31 andalso ?is_positif(Type) andalso Type > 31 ->
	Numero_mois = is_in_Tuple(?Liste_mois, Entier),
	if (Numero_mois =/= 0) -> 
		LastDay_month = calendar:last_day_of_the_month(Type, Numero_mois),
		if (Mot < LastDay_month + 1) -> 
			lists:append(Analyzed, [{date, {Type, Numero_mois, Mot}}]);
			true -> {error, invalid_day}
		end;
		true -> {error, unknown_month}
	end;

parse(_) ->
	{error, not_matching}.

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