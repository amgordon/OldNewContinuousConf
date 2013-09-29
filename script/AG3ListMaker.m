y = load('wordListNoAbsCon');
testSessLength = 1092;
testTotalLength = 1092;
numLists = 8;
numSess = 1;
numItems = 1092;

NStudy = numItems/2;
NTones = 4;
toneSet = {1 2 3 4};

for i = 1:numLists;
    thisShuffleIdx = randperm(testTotalLength);
    wordList_all = y.wordListNoAbsCon(thisShuffleIdx,1);
    %absCon_all = y.wordList1092(thisShuffleIdx,2);
    
    oldNew_all = [];
    for j = 1:numSess
        oldNew = ceil(randperm(testSessLength)/(numItems/2));
        oldNew(oldNew>2)=0;
        
        wordList = cell(size(oldNew));
        %absCon = cell(size(oldNew));
        wordList(oldNew>0) = wordList_all(1+(j-1)*numItems:(j)*numItems);
        wordList(oldNew==0) = {'+'};
        %absCon(oldNew>0) = absCon_all(1+(j-1)*numItems:(j)*numItems);
        %absCon(oldNew==0) = {0};
             
        %testList = [wordList' absCon' num2cell(oldNew')];
        testList = [wordList' num2cell(oldNew')];
        save (sprintf('1092_words_Test_List_NoAC_%g_%g', i,j), 'testList' );
        
        % now make the 2nd half of lists, this time switching which is old and which
        % new.
        %testList = [wordList' absCon' num2cell(mod(3-oldNew',3)) ];
        testList = [wordList' num2cell(mod(3-oldNew',3)) ];
        save (sprintf('1092_words_Test_List_NoAC_%g_%g', i+numLists, j), 'testList' );
        
        oldNew_all = [oldNew_all oldNew];
        
    end
    oldNew_all(oldNew_all==0) = [];
    
    wordListStudy = wordList_all(oldNew_all==1);
    %absConStudy = absCon_all(oldNew_all==1);
    for t=1:length(wordListStudy)
        thisShuffle = Shuffle(1:4);
        if t>1
            if toneIdxStudy(t-1) == thisShuffle(1)
                toneIdxStudy(t) = thisShuffle(2);
            else
                toneIdxStudy(t) = thisShuffle(1);
            end
        elseif t==1
            toneIdxStudy(t) = thisShuffle(1);
        end
    end
    toneListStudy = toneSet(toneIdxStudy);
    
    p = randperm(length(wordListStudy));
    wordListStudy = wordListStudy(p);
    %absConStudy = absConStudy(p);
    
    %studyList = [wordListStudy absConStudy];
    studyList = [wordListStudy toneListStudy'];
    
    save (sprintf('546_words_Study_List_NoAC_%g', i), 'studyList');
    
    % now make the 2nd half of lists, switching old and new.
    wordListStudy = wordList_all(oldNew_all==2);
    %absConStudy = absCon_all(oldNew_all==2);
    wordListStudy = wordListStudy(p);
    %absConStudy = absConStudy(p);
    %studyList = [wordListStudy absConStudy];
    studyList = [wordListStudy toneListStudy'];
    save (sprintf('546_words_Study_List_NoAC_%g', i+numLists), 'studyList');
end