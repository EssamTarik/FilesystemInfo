:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_error)).
:- use_module(library(http/http_parameters)).

stringEquals([], []).
stringEquals([H|T], [H|Tt]):-stringEquals(T, Tt).

bash_command(Command, Output) :-
        process_create(path(bash),
                ['-c', Command],
                [stdout(pipe(Out))]),
        read_string(Out, _, Output),
        close(Out).
	
whoareyou(X):-
	bash_command('whoami', X).

split_my_text(String, SplittedList):- split_string(String,' ', ' ', SplittedList).

whoOwns(FileName, Output):-
	FirstPart = "ls -l ",
	LastPart =  "| awk '{ print $3 }'",
	atom_concat(FirstPart, FileName, CommandStr),
	atom_concat(CommandStr, LastPart, FinalCommandStr),
	bash_command(FinalCommandStr, Output).

getWhenWasModified(FileName, Output):-
	FirstPart = "stat ",
	LastPart =  " | grep modify -i | tail -1 | awk ' { print $2 \" \" $3}'",
	atom_concat(FirstPart, FileName, CommandStr),
	atom_concat(CommandStr, LastPart, FinalCommandStr),
	bash_command(FinalCommandStr, Output).


getHowManyFiles(Directory, Output):-
	FirstPart = "ls ",
	LastPart =  "| wc -w",
	atom_concat(FirstPart, Directory, CommandStr),
	atom_concat(CommandStr, LastPart, FinalCommandStr),
	bash_command(FinalCommandStr, Output).



howManyFiles(["in"|[T]], X):-getHowManyFiles(T, X).
howMany(["files"|T], X):-howManyFiles(T, X).
how(["many"|T], X):-howMany(T, X).

whenWas([H|["modified"]], X):-getWhenWasModified(H,X).
when(["was"|T], X):-whenWas(T, X).

doesOwn(User,FileName,X):-
	atom_concat(User, '\n', UserString),
	atom_codes(UserString, UserCodes),
	whoOwns(FileName, RealOwner),
	atom_codes(RealOwner, RealOwnerCodes),
	stringEquals(UserCodes, RealOwnerCodes), X="yes".

doesOwn(User,FileName,"No").

does([H|["own"|[T]]], X):-doesOwn(H, T, X).

who(["owns"|[T]], X):-whoOwns(T, X).
fact(["who"|T], X):- who(T, X).
fact(["how"|T], X):- how(T, X).
fact(["when"|T], X):- when(T, X).
fact(["does"|T], X):- does(T, X).


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
response('who are you ?', X):-whoareyou(X).
response(String, X):-split_my_text(String, List), fact(List, X).
response(_, 'The question is unclear').
