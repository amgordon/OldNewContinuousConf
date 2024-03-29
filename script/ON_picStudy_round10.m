
function theData = ON_picStudy_round10(thePath,listName,sName, sNum, S,EncBlock, startTrial)

% theData = AG3encode(thePath,listName,sName,S,startTrial);
% This function accepts a list, then loads the images and runs the expt
% Run AG3.m first, otherwise thePath will be undefined.
% This function is controlled by BH1run
%
% To run this function solo:
% set S.on = 0
% startTrial = 1
% testSub = 'AG'
% theData = AG3retrieve(thePath,'Acc1_encode_7_1.mat','testSub',0,startTrial);

% Read in the list
cd(thePath.list);


list = load(listName);

theData.item = list.studyList(:,1);
theData.targetOns = vertcat(list.studyList{:,2});
theData.targetX = vertcat(list.studyList{:,3});
theData.targetY = vertcat(list.studyList{:,4});

listLength = length(theData.item);

scrsz = get(0,'ScreenSize');

% Diagram of trial

stimTime = 3;  % the word
picTime = .25;
blankTime = .75;
behLeadinTime = 4;
targetTime = .25;
postStimBlankTime = .75 - 2/3;
soundTime = 1;

Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');
cd(thePath.stim);


% preallocate:
trialcount = 0;
for preall = startTrial:listLength
        theData.onset(preall) = 0;
        theData.dur(preall) =  0;
        theData.judgeResp{preall} = 'noanswer';
        theData.judgeRT{preall} = 0;
        theData.stimResp{preall} = 'noanswer';
        theData.stimRT{preall} = 0;
        theData.presentedTask{preall} = 'noanswer';
        theData.confActual{preall} = 'noanswer';
end

hands = {'Left','Right'};

if S.scanner == 2
    fingers = {'q', 'p'};
elseif S.scanner ==1;
    fingers = {'1!', '5%'};
end

hsn = S.encHandNum;

cd (thePath.stim);
for n=1:listLength
    picName = theData.item{n};
    pic = imread(picName);
    picPtrs(n) = Screen('MakeTexture', S.Window, pic);   
    
    pctLoaded = round(100*(n/listLength));
    pctMsg = sprintf('pictures %g percent loaded', pctLoaded);
    DrawFormattedText(S.Window,pctMsg,'center','center',S.textColor);
    Screen(S.Window, 'Flip');
end

toneSet = {'tone3.wav'};

% %preload sounds
wavfilenameCue = fullfile(thePath.stim, toneSet{1});
[yCue, cue.freq] = wavread(wavfilenameCue);
cue.wavedata = yCue(:,1)';
cue.nrchannels = size(cue.wavedata,1); % Number of rows == number of channels.

flashingPtr = n+1;
pic(:) = S.flashingRectColor;
picPtrs(flashingPtr) = Screen('MakeTexture', S.Window, pic);

% for the first block, display instructions
if EncBlock == 1

    ins_txt{1} =  sprintf('In this phase, you will see a series of pictures presented on the screen.  At some point during the presentation of each picture, you will hear a tone. \n \n You will have two jobs.  First, pay attention to each scene, as you will be asked about the scenes in a later round.  Second, as soon as you hear the tone, please press the space bar as quickly as you can. \n \n Please allot equal effort to each of these two tasks.');

    DrawFormattedText(S.Window, ins_txt{1},'center','center',255, 75);
    Screen('Flip',S.Window);

    AG3getKey('g',S.kbNum);

end

% get ready screen
message = 'Press g to begin!';
[hPos, vPos] = AG3centerText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
Screen(S.Window,'Flip');

% give the output file a unique name
cd(thePath.data);

matName = ['Acc1_encode_sub' num2str(sNum), '_date_' sName 'out.mat'];

checkEmpty = isempty(dir (matName));
suffix = 1;

while checkEmpty ~=1
    suffix = suffix+1;
    matName = ['Acc1_encode_' num2str(sNum), '_' sName 'out(' num2str(suffix) ').mat'];
    checkEmpty = isempty(dir (matName));
end

% Present test trials
goTime = 0;

%  initiate experiment and begin recording time...
% start timing/trigger

if S.scanner==1
    % *** TRIGGER ***
    while 1
        AG3getKey('g',S.kbNum);
        [status, startTime] = AG3startScan; % startTime corresponds to getSecs in startScan
        fprintf('Status = %d\n',status);
        if status == 0  % successful trigger otherwise try again
            break
        else
            Screen(S.Window,'DrawTexture',blank);
            message = 'Trigger failed, "g" to retry';
            DrawFormattedText(S.Window,message,'center','center',S.textColor);
            Screen(S.Window,'Flip');
        end
    end
else
    AG3getKey('g',S.kbNum);
    startTime = GetSecs;
end

Priority(MaxPriority(S.Window));

% Fixation
if S.scanner == 1
    goTime = goTime + scanLeadinTime;
elseif S.scanner ==2;
    goTime = goTime + behLeadinTime;
end
Screen(S.Window,'Flip');
AG3recordKeys(startTime,goTime,S.kbNum);  % not collecting keys, just a delay
baselineTime = GetSecs;


for Trial = 1:listLength
       trialcount = trialcount + 1;
       
       ons_start = GetSecs;
       
       theData.onset(Trial) = GetSecs - startTime; %precise onset of trial presentation
              
       % Stim
       goTime = picTime;%theData.targetOns(Trial);
       Screen('DrawTexture', S.Window, picPtrs(Trial));
       Screen(S.Window,'Flip');
       theData.stimTime(Trial) = GetSecs;
       AG3recordKeys(ons_start,goTime,S.boxNum);
       
       % Pre-target blank time
       theData.preTargTime(Trial) = GetSecs;
       goTime = goTime+theData.targetOns(Trial);
       AG3recordKeys(ons_start,goTime,S.boxNum);
       
       % Target
       % Cue Sound
       S.pahandle = PsychPortAudio('Open', [], [], 0, cue.freq, cue.nrchannels);
       soundStartTime = GetSecs;
       thisSound = cue.wavedata;
       soundEndTime = soundStartTime+soundTime;
       PsychPortAudio('FillBuffer', S.pahandle, thisSound);
       PsychPortAudio('Start', S.pahandle, 1, 0, 1, soundEndTime);
       theData.targTime(Trial) = GetSecs;
       
       goTime = goTime + soundTime;
       [keys1 RT1] = AG3recordKeys(ons_start,goTime,S.boxNum);
       
       theData.stimResp{Trial} = keys1;
       theData.stimRT{Trial} = RT1;
       
       % Post-target Time
       desiredTime = (Trial)*stimTime;
       curTime = GetSecs - baselineTime;
       goTime = goTime + desiredTime - curTime - 1/120;       
       [keys2 RT2] = AG3recordKeys(ons_start,goTime,S.boxNum);
       %Screen(S.Window,'Flip'); 
      
       PsychPortAudio('Close', S.pahandle);
       
       theData.judgeResp{Trial} = keys2;
       theData.judgeRT{Trial} = RT2;
       theData.dur(Trial) = GetSecs - ons_start;  %records precise trial duration
       
       cmd = ['save ' matName];
       eval(cmd);
       fprintf('%d\n',Trial);
end

fprintf(['/nExpected time: ' num2str(goTime)]);
fprintf(['/nActual time: ' num2str(GetSecs-startTime)]);


cmd = ['save ' matName];
eval(cmd);


Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');

% ------------------------------------------------
Priority(0);
