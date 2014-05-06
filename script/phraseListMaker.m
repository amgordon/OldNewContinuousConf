function [] = phraseListMaker(thePath)

NPhrases = 300;
NPhrasesPerCond = 150;
NLists = 16;
cd(fullfile(thePath.sounds))

dF = dir('./f*.wav');
dM = dir('./m*.wav');

fList = {dF.name}';
mList = {dM.name}';

phraseIdx = 1:NPhrases;

cd(thePath.list);

allPhrases_h = load('allPhrases.mat');
allPhrases = allPhrases_h.allPhrases.phrases;

oldPhraseIdx = find(allPhrases_h.allPhrases.oldnew==1);
newPhraseIdx = find(allPhrases_h.allPhrases.oldnew==2);

for i=1:NLists
    %% Study
    
    [item_h, ix] = Shuffle(oldPhraseIdx);
    shuffledPhrases = allPhrases(ix);
    
    item.f = item_h(1:2:end);
    item.m = item_h(2:2:end);
   
    phrase.f = shuffledPhrases(1:2:end);
    phrase.m = shuffledPhrases(2:2:end);
    
    newPhrases = (allPhrases(newPhraseIdx));
    newItems = newPhraseIdx;
    
    for j=1:length(item.m)
        afile.f{j,1} = ['f_' prepend(item.f(j),3) '.wav'];
        afile.m{j,1} = ['m_' prepend(item.m(j),3) '.wav'];
    end
    
    studyList.afile = afile;
    studyList.item = item;
    studyList.phrase = phrase;
    
    save (sprintf('300_phrases_Study_List_Dichot_%g', i), 'studyList');
    
    %% Test
    newItemsShf = Shuffle(newPhraseIdx);    
    testItems = [item.f; item.m; newItemsShf];
    
    ONCond = [ones(size(item.f)); ones(size(item.m)); 2*ones(size(newItemsShf))];
    
    genderCond = [ones(size(item.f)); 2*ones(size(item.m)); zeros(size(newItemsShf))];
    
    shfIdx = Shuffle(1:length(testItems));
    
    testList.item = testItems(shfIdx);
    testList.ONcond = ONCond(shfIdx);
    testList.gender = genderCond(shfIdx);
    testList.phrase = allPhrases(shfIdx);
    
    save (sprintf('450_phrases_Test_List_Dichot_%g', i), 'testList');
end

end