
function ONRMrunRound12(thePath, sName, sNum, testType, scanner, startBlock)
% function AG3run(thePath)
% e.g. AG3run(thePath, '66Feb66', 5, 4, 0, 1)
%
% Get experiment info
if nargin == 0
    error('Must specify thePath')
end

if nargin<2
    sName = input('Enter date (e.g. ''11Feb09'') ','s');
end

if nargin<3
    sNum = input('Enter subject number: ');
end

if nargin<4
    testType = 0;
    while ~ismember(testType,[1,2,3,4])
        testType = input('Which task?  ON_S[1] ON_T[2] ON_P1[3] ON_P1[4]? ');
    end
end

if nargin<5
    S.scanner = 0;
    while ~ismember(S.scanner,[1:3])
        S.scanner = input('In scanner [1] behavioral [2] or mock scanner [3]? ');
    end
else
    S.scanner = scanner;
end

if nargin<6
    S.startBlock = 0;
    while ~ismember(S.startBlock,[1:6])
        S.startBlock = input('At which block would you like to start?  ');
    end
else
    S.startBlock = startBlock;
end

S.subData = fullfile(thePath.data, [sName '_' num2str(sNum)]);
if ~exist(S.subData)
   mkdir(S.subData); 
end

% Set input device (keyboard or buttonbox)
if S.scanner == 1
    [S.boxNum S.boxType] = AG3getBoxNumber;  % buttonbox
    S.kbNum = AG3getKeyboardNumber; % keyboard
elseif S.scanner == 3 % Mock scanner
    [S.boxNum S.boxType] = AG3getBoxNumber;  % buttonbox
    S.kbNum = AG3getKeyboardNumber; % keyboard
else
    S.boxNum = AG3getKeyboardNumber;  % buttonbox
    S.kbNum = AG3getKeyboardNumber; % keyboard
end

%   Condition numbers
S.confScaleNum = 2-mod(sNum,2); % 1 2 1 2
S.encHandNum = 2 - mod(ceil(sNum/2),2); % 1 1 2 2 1 1 2 2

handsToTonesSet = {[1 2 3] [1 3 2] [2 1 3] [2 3 1] [3 1 2] [3 2 1]};
S.handsToTones = handsToTonesSet{1+mod(sNum-1,6)};

%-------------------------------
HideCursor;

% Screen commands
S.screenNumber = max(Screen('Screens'));
S.screenColor = 0;
S.textColor = 255;
S.flashingRectColor = 100;
S.responseBarColor = [0 0 255];
S.blinkColor  = [0 0 0];
[S.Window, S.myRect] = Screen(S.screenNumber, 'OpenWindow', S.screenColor, [], 32);
Screen('TextSize', S.Window, 30);
Screen('TextStyle', S.Window, 1);
S.on = 1;  % Screen now on
S.scrsz = get(0,'ScreenSize');
S.respLetters = {'J' 'K' 'L'};

%% info for study script
S.DotDetectionRect = [S.scrsz(3)/2 - 10, S.scrsz(4)/2-10, S.scrsz(3)/2 + 10,  S.scrsz(4)/2+10];

%% info for test script
S.ResponseRectIns = [S.scrsz(3)/2 - 250, S.scrsz(4)/2+50, S.scrsz(3)/2 + 250,  S.scrsz(4)/2+550];
S.MaskingRectIns = [S.scrsz(3)/2 - 260, S.scrsz(4)/2+300, S.scrsz(3)/2 + 260,  S.scrsz(4)/2+550];

S.ResponseRect = [S.scrsz(3)/2 - 250, S.scrsz(4)/2-150, S.scrsz(3)/2 + 250,  S.scrsz(4)/2+350];
S.MaskingRect = [S.scrsz(3)/2 - 260, S.scrsz(4)/2+100, S.scrsz(3)/2 + 260,  S.scrsz(4)/2+350];
    
S.responseCenter = [S.scrsz(3)/2 S.scrsz(4)/2 + 100];
S.responseRad = 250;
S.respBarThickness = 10;

S.respTextInsLeft = [S.scrsz(3)/2 - 280, S.scrsz(4)/2+320];
S.respTextInsRight = [S.scrsz(3)/2 + 215, S.scrsz(4)/2+320];

S.respTextLeft = [S.scrsz(3)/2 - 280, S.scrsz(4)/2+120];
S.respTextRight = [S.scrsz(3)/2 + 215, S.scrsz(4)/2+120];
S.respStimY = S.scrsz(4)/2+150;

%%
if testType == 1
    saveName = ['ONRMStudy' sName '_' num2str(sNum) '.mat'];
    
    
    listName = sprintf('450_Study_PicList_wSoundConds_%g.mat', mod(sNum, 16));
    respSelData(1) = ON_study_round12(thePath,listName,sName,sNum,S,1, 1);
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;
    
    while checkEmpty ~=1
    suffix = suffix+1;
    saveName = ['ONRMStudy_' sName '_' num2str(sNum) '(' num2str(suffix) ')' '.mat'];
    checkEmpty = isempty(dir (saveName));
    end

    eval(['save ' fullfile(S.subData, saveName)]);
    % Output file for each block is saved within BH1test; full file saved
    % here

elseif testType == 2
    saveName = ['ONRMTest' sName '_' num2str(sNum) '.mat'];

    listName = ['900_Test_PicList_' num2str(mod(sNum,16)) '_' num2str(1) '.mat'];
    ONTestData(1) = ON_picTest(thePath,listName,sName,sNum,1, S);

    checkEmpty = isempty(dir (saveName));
    suffix = 1;

    while checkEmpty ~=1
        suffix = suffix+1;
        saveName = ['AG3_ONTest_' sName '_' num2str(sNum) '(' num2str(suffix) ')' '.mat'];
        checkEmpty = isempty(dir (saveName));
    end

    eval(['save ' fullfile(S.subData, saveName)]);
    % Output file for each block is saved within BH1test; full file saved
    % here
    
elseif testType == 3
    
    saveName = ['ON_studyPrac1_round12' sName '_' num2str(sNum) '.mat'];
    
    listName = '546_words_Study_List_NoAC_prac1.mat';
    pracData(1) = ON_studyPrac1_round11(thePath,listName,sName,sNum,S,1, 1);
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;
    
    while checkEmpty ~=1
        suffix = suffix+1;
        saveName = ['ONRMStudyPrac' sName '_' num2str(sNum) '(' num2str(suffix) ')' '.mat'];
        checkEmpty = isempty(dir (saveName));
    end

    eval(['save ' fullfile(S.subData, saveName)]);
    % Output file for each block is saved within BH1test; full file saved
    % here
elseif testType == 4
    
    saveName = ['ON_studyPrac2_round12' sName '_' num2str(sNum) '.mat'];
    
    listName = '546_words_Study_List_NoAC_prac2.mat';
    pracData(1) = ON_studyPrac2_round11(thePath,listName,sName,sNum,S,1, 1);
    
    checkEmpty = isempty(dir (saveName));
    suffix = 1;
    
    while checkEmpty ~=1
        suffix = suffix+1;
        saveName = ['ONRMStudyPrac' sName '_' num2str(sNum) '(' num2str(suffix) ')' '.mat'];
        checkEmpty = isempty(dir (saveName));
    end

    eval(['save ' fullfile(S.subData, saveName)]);
    % Output file for each block is saved within BH1test; full file saved
    % here
end

message = 'End of script. Press any key to exit.';
[hPos, vPos] = AG3centerText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, 255);
Screen(S.Window,'Flip');
pause;
Screen('CloseAll');

