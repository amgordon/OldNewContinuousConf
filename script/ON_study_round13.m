
function theData = ON_study_round13(thePath,listName,sName, sNum, S,EncBlock, startTrial)

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

theData.item = list.studyList.item;
theData.soundFiles = list.studyList.afile;

listLength = length(theData.item.m);

scrsz = get(0,'ScreenSize');

% Diagram of trial

initStimTime = .5; % stim time before sound
stimTime = 1.85;  % total stim time
blankTime = .15;
behLeadinTime = 1;
soundTime = 2;
m_f_offset_time = 1;
trialTime = 2;

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

cd (thePath.stim);

% %preload sounds
for L=1:length(theData.soundFiles.m)
    
    % load male words
    wavfilenameCue.m = fullfile(thePath.sounds, theData.soundFiles.m{L});
    [yCue.m, cue.freq.m{L}] = wavread(wavfilenameCue.m);
    cue.wavedata.m{L} = yCue.m(:,1)';
    cue.nrchannels.m{L} = size(cue.wavedata.m,1); % Number of rows == number of channels.
    
    % load female words
    wavfilenameCue.f = fullfile(thePath.sounds, theData.soundFiles.f{L});
    [yCue.f, cue.freq.f{L}] = wavread(wavfilenameCue.f);
    cue.wavedata.f{L} = yCue.f(:,1)';
    cue.nrchannels.f{L} = size(cue.wavedata.f,1); % Number of rows == number of channels.
end



hands = {'Left','Right'};

if S.scanner == 2
    fingers = {'q', 'p'};
elseif S.scanner ==1;
    fingers = {'1!', '5%'};
end

hsn = S.encHandNum;
% for the first block, display instructions
if EncBlock == 1

    ins_txt{1} =  sprintf('In this phase, you will perform two tasks simultaneously.  First, you will pay attention to each picture as you will be asked questions about these pictures in later phases.  Second, you will also hear a tone on each trial.  Each time you hear a tone, please make the appropriate response associated with that tone.  \n \n Please allot equal effort to each of these two tasks.');

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
   
       %% Female Voice
       S.pahandle.f = PsychPortAudio('Open', [], [], 0, cue.freq.f{Trial}, 2);
       soundStartTime = GetSecs;
       thisSound.f = .25*cue.wavedata.f{Trial};
       soundEndTime = soundStartTime+soundTime;
       PsychPortAudio('FillBuffer', S.pahandle.f, [zeros(size(thisSound.f)); thisSound.f]);
       PsychPortAudio('Start', S.pahandle.f, 1, 0, 0, soundEndTime);
              
       %% Male Voice
       S.pahandle.m = PsychPortAudio('Open', [], [], 0, cue.freq.m{Trial}, 2);
       soundStartTime = GetSecs;
       thisSound.m = cue.wavedata.m{Trial};
       soundEndTime = soundStartTime+soundTime;
       PsychPortAudio('FillBuffer', S.pahandle.m, [thisSound.m; zeros(size(thisSound.m))]);
       AG3recordKeys(ons_start,m_f_offset_time,S.boxNum);
       PsychPortAudio('Start', S.pahandle.m, 1, 0, 0, soundEndTime);
       
       AG3recordKeys(ons_start,trialTime,S.boxNum);
       
       PsychPortAudio('Close', S.pahandle.m);
       save(fullfile(S.subData, matName), 'theData', 'S')
end


fprintf(['/nExpected time: ' num2str(goTime)]);
fprintf(['/nActual time: ' num2str(GetSecs-startTime)]);


cmd = ['save ' fullfile(S.subData, matName)];
eval(cmd);


Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');

% ------------------------------------------------
Priority(0);
