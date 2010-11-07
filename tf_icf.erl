-module(tf_icf).
-compile(export_all).

main() ->
    CorpusFreq = dict:new(),
    process_lines_of_file(standard_io, 1, CorpusFreq).

process_lines_of_file(Io, LineNum, CorpusFreq) ->
    case io:get_line(Io,'') of
	eof ->  
	    done;
	Line -> 
	    CorpusFreq2 = process_document(chomp(Line), LineNum, CorpusFreq),
	    process_lines_of_file(Io, LineNum+1, CorpusFreq2)
    end.

process_document(Document, DocumentNum, CorpusFreq) ->
    Tokens = re:split(Document, " ", [{return,list}]),
    DocFreq = update_token_counts(Tokens, dict:new()),
    UniqueTokens = dict:fetch_keys(DocFreq),
    CorpusFreq2 = update_token_counts(UniqueTokens, CorpusFreq),

    calculate_weights(DocumentNum, UniqueTokens, DocFreq, CorpusFreq2),    

    CorpusFreq2.

chomp(S) ->
    string:strip(string:strip(S,both,$\n),both).

update_token_counts(Tokens, Dict) ->
    lists:foldl( fun(T, D) -> dict:update_counter(T,1,D) end, Dict, Tokens ).

calculate_weights(DocumentNum, Tokens, DocFreq, CorpusFreq) ->
    lists:foreach(
      fun(T) ->
	      DocFreqEntry = dict:fetch(T, DocFreq),
	      TokenWeight = math:log( 1 + DocFreqEntry ),
	      
	      CorpusFreqEntry = dict:fetch(T, CorpusFreq),
	      CorpusWeight = math:log( (DocumentNum+1) / (CorpusFreqEntry+1) ),
	      
	      Weight = TokenWeight * CorpusWeight,	      
	      io:format("~B\t~s\t~f\n",[DocumentNum,T,Weight])

	      end,
      Tokens
     ).




