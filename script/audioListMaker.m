function [] = audioListMaker(thePath)

NWords = 350;
NWordsPerCond = 175;
NLists = 16;
cd(fullfile(thePath.sounds))

dF = dir('./f*.wav');
dM = dir('./m*.wav');

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
    studyWords{i} = upper(mList{i}(3:(end-4)));
end

newWords = setdiff(allWords,studyWords);

cd(thePath.list);
for i=1:NLists
    %% Study
    
    item_h = Shuffle(studyWords);

    item.f = item_h(2:2:end);
    item.m = item_h(1:2:end);
    
    for j=1:length(item.m)
        afile.f{j} = ['f_' lower(item.f{j}) '.wav'];
        afile.m{j} = ['m_' lower(item.m{j}) '.wav'];
    end
    
    studyList.afile = afile;
    studyList.item = item;
    
    save (sprintf('350_words_Study_List_Dichot_%g', i), 'studyList');
    
    %% Test
    newWordsShf = Shuffle(newWords);    
    testItems = [item.f, item.m, newWordsShf(1:NWordsPerCond)];
    
    ONCond = [ones(size(item.f)), ones(size(item.m)), 2*ones(1,NWordsPerCond)];
    
    genderCond = [ones(size(item.f)), 2*ones(size(item.m)), zeros(1,NWordsPerCond)];
    
    shfIdx = Shuffle(1:length(testItems));
    
    testList.item = testItems(shfIdx);
    testList.ONcond = ONCond(shfIdx);
    testList.gender = genderCond(shfIdx);
    
    save (sprintf('525_words_Test_List_Dichot_%g', i), 'testList');
end

end