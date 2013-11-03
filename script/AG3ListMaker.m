y = load('wordListNoAbsCon');
testSessLength = 1092;
testTotalLength = 1092;
numLists = 8;
numSess = 1;
numItems = 1092;

NStudy = numItems/2;
NTones = 3;
toneSet = {1 2 3};

NSalient = 16;
NPadWords = 184;
NCoefs = 10;
NTerminalPads = 13;
salSet = {0 1 2};

for i = 1:numLists;
    thisShuffleIdx = randperm(testTotalLength);
    wordList_all = y.wordListNoAbsCon(thisShuffleIdx,1);
    
    oldNew_all = [];
    for j = 1:numSess
        oldNew = ceil(randperm(testSessLength)/(numItems/2));
        oldNew(oldNew>2)=0;
        
        wordList = cell(size(oldNew));
        wordList(oldNew>0) = wordList_all(1+(j-1)*numItems:(j)*numItems);
        wordList(oldNew==0) = {'+'};
         
        testList = [wordList' num2cell(oldNew')];
        save (sprintf('1092_words_Test_List_Salience_%g_%g', i,j), 'testList' );
        
        % now make the 2nd half of lists, this time switching which is old and which
        % new.
        testList = [wordList' num2cell(mod(3-oldNew',3)) ];
        save (sprintf('1092_words_Test_List_Salience_%g_%g', i+numLists, j), 'testList' );
        
        oldNew_all = [oldNew_all oldNew];
        
    end
    oldNew_all(oldNew_all==0) = [];
    
    wordListStudy = wordList_all(oldNew_all==1);
    
    %% making an index of salient stims
    padLength_h = (exprnd(1,1,(NSalient+1)));
    padLength_h2 = round(padLength_h * (NPadWords / sum(padLength_h)));
    deltaL = NPadWords - sum(padLength_h2);
    [~,ix] = max(padLength_h2);
    padLength_h2(ix) = padLength_h2(ix) + deltaL;
    
    sal = [zeros(1,NTerminalPads) zeros(1,padLength_h2(1))];
    for c = 1:NSalient
        sal = [sal, zeros(1,NCoefs), 1, zeros(1,padLength_h2(c+1)), zeros(1,NCoefs)];
    end
    sal = [sal zeros(1,NTerminalPads)];
    
    salModality = Shuffle([ones(1,NSalient/2), 2*ones(1,NSalient/2)]);
    sal(sal==1) = salModality;
    
    salientStudy = salSet(sal+1);
    %%
    for t=1:length(wordListStudy)
        thisShuffle = Shuffle(1:3);
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
    toneListStudy(sal==2) = {4};
    
    p = randperm(length(wordListStudy));
    wordListStudy = wordListStudy(p);

    studyList = [wordListStudy toneListStudy' salientStudy'];
    
    save (sprintf('546_words_Study_List_Salience_%g', i), 'studyList');
    
    % now make the 2nd half of lists, switching old and new.
    wordListStudy = wordList_all(oldNew_all==2);
    wordListStudy = wordListStudy(p);
    studyList = [wordListStudy toneListStudy' salientStudy'];
    save (sprintf('546_words_Study_List_Salience_%g', i+numLists), 'studyList');
end