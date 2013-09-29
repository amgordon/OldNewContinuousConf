
function theData = ON_studyPrac2_round7(thePath,listName,sName, sNum, S,EncBlock, startTrial)

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


theData.tone = [list.studyList{:,1}];

listLength = length(theData.tone);

scrsz = get(0,'ScreenSize');

% Diagram of trial

stimTime = 1.85;  % the word
blankTime = 1.05;
behLeadinTime = 4;
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

toneSet = {'tone1.wav' 'tone2.wav' 'tone3.wav' 'tone4.wav'};
% %preload sounds
for L=1:length(toneSet)
    wavfilenameCue = fullfile(thePath.stim, toneSet{L});
    [yCue, cue.freq{L}] = wavread(wavfilenameCue);
    cue.wavedata{L} = yCue(:,1)';
    cue.nrchannels{L} = size(cue.wavedata,1); % Number of rows == number of channels.
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

    ins_txt{1} =  sprintf('In this phase of the study, you will hear a tone on each trial.  Now that you have learned which key response goes with each tone, your job is to press the appropriate key associated with each tone.  You will be informed whether your response is correct or incorrect for each trial.');

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
       
       
       % Cue Sound
       S.pahandle = PsychPortAudio('Open', [], [], 0, cue.freq{theData.tone(Trial)}, cue.nrchannels{theData.tone(Trial)});
       soundStartTime = GetSecs;
       goTime = soundTime;
       thisSound = cue.wavedata{theData.tone(Trial)};
       soundEndTime = soundStartTime+soundTime;
       PsychPortAudio('FillBuffer', S.pahandle, thisSound);
       PsychPortAudio('Start', S.pahandle, 1, 0, 1, soundEndTime);
       
       % Stim
       desiredTime = (Trial)*stimTime + (Trial-1)*blankTime;
       curTime = GetSecs - baselineTime;
       goTime = desiredTime - curTime - 1/120;
       
       stim = S.respLetters{theData.tone(Trial)};
       
       Screen(S.Window,'Flip');
       [keys1 RT1] = AG3recordKeys(ons_start,goTime,S.boxNum);
       theData.stimResp{Trial} = keys1;
       theData.stimRT{Trial} = RT1;
      

       % ITI
       goTime = goTime + blankTime;
      
       if strcmp(keys1(1), stim)
           DrawFormattedText(S.Window,'correct','center','center',S.textColor);
       else
           DrawFormattedText(S.Window,'incorrect','center','center',S.textColor);
       end
       Screen(S.Window,'Flip');
       AG3recordKeys(ons_start,goTime,S.boxNum);  % not collecting keys, just a delay
       
       
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
