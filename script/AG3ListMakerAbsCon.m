y = load('wordList1092');
testSessLength = 1092;
testTotalLength = 1092;
studyTotalLength = 546;
numLists = 8;
numSess = 1;
numItems = 1092;
dotLengths = [.5 .7 .9 1.1 1.3 1.5];

for i = 1:numLists;
    thisShuffleIdx = randperm(testTotalLength);
    wordList_all = y.wordList1092(thisShuffleIdx,1);
    absCon_all = y.wordList1092(thisShuffleIdx,2);
    
    dotList_h = (1:length(absCon_all)) - 1e-10;
    dotList_h2 = ceil(dotList_h*(length(dotLengths)/testTotalLength));
    dotList_h3 = Shuffle(dotList_h2);
    for d = 1:length(dotList_h3)
        dotList_all(d) = {dotLengths(dotList_h3(d))};
    end
    
    oldNew_all = [];
    for j = 1:numSess
        oldNew = ceil(randperm(testSessLength)/(numItems/2));
        oldNew(oldNew>2)=0;
        
        wordList = cell(size(oldNew));
        absCon = cell(size(oldNew));
        dotList = cell(size(oldNew));
        
        wordList(oldNew>0) = wordList_all(1+(j-1)*numItems:(j)*numItems);
        wordList(oldNew==0) = {'+'};
        absCon(oldNew>0) = absCon_all(1+(j-1)*numItems:(j)*numItems);
        absCon(oldNew==0) = {0};        
        dotList(oldNew>0) = dotList_all(1+(j-1)*numItems:(j)*numItems);
        dotList(oldNew==0) = {0};  
        
        %testList = [wordList' absCon' num2cell(oldNew')];
        testList = [wordList' absCon' num2cell(oldNew') dotList'];
        save (sprintf('1092_words_Test_List_%g_%g', i,j), 'testList' );
        
        % now make the 2nd half of lists, this time switching which is old and which
        % new.
        testList = [wordList' absCon' num2cell(mod(3-oldNew',3)) dotList'];
        save (sprintf('1092_words_Test_List_%g_%g', i+numLists, j), 'testList' );
        
        oldNew_all = [oldNew_all oldNew];
        
    end
    oldNew_all(oldNew_all==0) = [];
    
    wordListStudy = wordList_all(oldNew_all==1);
    absConStudy = absCon_all(oldNew_all==1);
    dotListStudy = dotList_all(oldNew_all==1);    
    
    p = randperm(length(wordListStudy));
    wordListStudy = wordListStudy(p);
    absConStudy = absConStudy(p);
    dotListStudy = dotListStudy(p);
    studyList = [wordListStudy absConStudy dotListStudy'];
    save (sprintf('546_words_Study_List_%g', i), 'studyList');
    
    % now make the 2nd half of lists, switching old and new.
    wordListStudy = wordList_all(oldNew_all==2);
    absConStudy = absCon_all(oldNew_all==2);
    dotListStudy = dotList_all(oldNew_all==2);
    
    wordListStudy = wordListStudy(p);
    absConStudy = absConStudy(p);
    dotListStudy = dotListStudy(p);
    
    studyList = [wordListStudy absConStudy dotListStudy'];
    save (sprintf('546_words_Study_List_%g', i+numLists), 'studyList');
end