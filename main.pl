bash_command(Command, Output) :-
        process_create(path(bash),
                ['-c', Command],
                [stdout(pipe(Out))]),
        read_string(Out, _, Output),
        close(Out).
	
whoareyou(X):-
	bash_command('whoami', X).

whoOwns(FileName, Output):-
	FirstPart = "ls -l ",
	LastPart =  "| awk '{ print $2 }'",
	atom_concat(FirstPart, FileName, CommandStr),
	atom_concat(CommandStr, LastPart, FinalCommandStr),
	bash_command(FinalCommandStr, Output).
