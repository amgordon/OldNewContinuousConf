function [] = audioListMaker(thePath)

NWords = 350;
NWordsPerCond = 175;
NLists = 16;
cd(fullfile(thePath.stim, 'dichoticStims'))

dF = dir('./female/*.wav');
dM = dir('./male/*.wav');

allWords = load('wordList700.mat');
allWords = allWords.wordList700;




fList = {dF.name}';
mList = {dM.name}';

for i=1:length(mList)
    if strcmp(mList{i}(3:end), fList{i}(3:end))
       sameWord(i) = true; 
    else
       sameWord(i) = false;
    end
    words{i} = upper(mList{i}(3:(end-4)));
end

testWords = setdiff(allWords,words);

cd(thePath.list);
for i=1:NLists
    %% Study
    conds_h = [ones(1,NWords/2), 2*ones(1,NWords/2)];
    cond = Shuffle(conds_h);
    
    mListShf = Shuffle(mList);
    fListShf = Shuffle(fList);
    
    afile = cell(size(cond));
    afile(cond==1) = fListShf(cond==1);
    afile(cond==2) = mListShf(cond==2);
    
    for j=1:length(afile)
        item{j} = upper(afile{j}(3:(end-4)));
    end
    
    studyList.afile = afile;
    studyList.item = item;
    studyList.cond = cond;
    
    save (sprintf('350_words_Study_List_Dichot_%g', i), 'studyList');
    
    %% Test
    testWordsShf = Shuffle(testWords);    
    testItems = [item, testWordsShf(1:NWordsPerCond)];
    
    ONCond = [ones(size(item)) 2*ones(1,NWordsPerCond)];
    
    genderCond = [cond, zeros(1,NWordsPerCond)];
    
    shfIdx = Shuffle(1:length(testItems));
    
    testList.item = testItems(shfIdx);
    testList.ONcond = ONCond(shfIdx);
    testList.gender = genderCond(shfIdx);
    
    save (sprintf('525_words_Test_List_Dichot_%g', i), 'testList');
end

end