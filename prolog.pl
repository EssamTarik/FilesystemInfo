:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/http_parameters)).

server(Port) :-
        http_server(http_dispatch, [port(Port)]).
        
headers:-
        format('Access-Control-Allow-Origin: *~n'),
        format('Content-type: application/json; charset=utf-8~n~n').
        
:- http_handler(/, request_response, []).
request_response(Request) :-
        headers,
        http_parameters(Request, [ query(Q, []) ]),
        response(Q, R),
        format('~p', [R]).


% === dataset ===
response('مرحبا', 'السلام عليكم').
response(_, 'مش فاهم').