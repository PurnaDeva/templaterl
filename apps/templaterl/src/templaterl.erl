-module(templaterl).

-export([
	init/3,
	handle/2,
	terminate/3,
	dict_from_file/1
	]).

init(_Transport, Req, []) ->
	{ok, Req, undefined}.

terminate(_Reason, _Req, _State) ->
	ok.

handle(Req, State) ->
	{Method, Req2} = cowboy_req:method(Req),
	{Dict, _}= cowboy_req:qs_vals(Req),
	{Filename, _} = cowboy_req:qs_val(<<"template">>, Req, <<"./default.xml">>),
	Template = bbmustache:parse_file(filename:join([filename:absname(""), filename:absname(filename:basename(Filename), "./templates/")])),
	Body = bbmustache:compile(Template, Dict, [{key_type, binary}]),
	{ok, Req4} = response(Method, Body, Req2),
	{ok, Req4, State}.

response(<<"GET">>, Body, Req) ->
	cowboy_req:reply(200,
		[{<<"content-encoding">>, <<"utf-8">>}, {<<"content-type">>, <<"application/xml">>}], Body, Req);
response(_, _, Req) ->
	%% Method not allowed.
	cowboy_req:reply(405, Req).

trim_whitespace(Input) ->
   re:replace(Input, "(^\\s+)|(\\s+$)", "", [global,{return,list}]).

dict_from_file(Filename) ->
	case file:open(Filename, [read]) of
		{ok, FP} ->
			dict_from_file_(FP, dict:new());
		{error,_} ->
			'invalid_filename'
	end.

dict_from_file_(FP, Dict) ->
	case file:read_line(FP) of
		{ok, LN} ->
			case string:tokens(LN, ",") of
				[K,V|_] ->
					KK = trim_whitespace(K),
					VV = trim_whitespace(V),
					Dict2 = dict:store(KK, VV, Dict);
				_ ->
					Dict2 = Dict
			end,
			dict_from_file_(FP, Dict2);
		_ ->
			file:close(FP),
			Dict
	end.