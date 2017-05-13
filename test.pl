who(["owns"|[T]]):-write(T).
fact(["who"|T]):-who(T).
get_file_name(String):-split_my_text(String, List),fact(List).
split_my_text(String, SplittedList):- split_string(String,' ', ' ', SplittedList).
