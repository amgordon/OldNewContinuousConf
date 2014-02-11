function theData = ON_test_round13(thePath,listName,sName, sNum,RetBlock, S)

% This function accepts a list, then loads the images and runs the expt
% Run AG3.m first, otherwise thePath will be undefined.
% This function is controlled by BH1run
%
% To run this function solo:
% theData = AG3retrieve(thePath,listName,'testSub',0);


refreshInterval= Screen('GetFlipInterval', S.Window);

% ListenChar(2); %suppress display of keypresses to command window.

cd(thePath.list);

list = load(listName);

theData.item = list.testList.item;
theData.oldNew = list.testList.ONcond;
theData.gender = list.testList.gender;

listLength = length(theData.item);

scrsz = get(0,'ScreenSize');

% preallocate:
trialcount = 0;
for preall = 1:listLength 
    theData.num(preall) = preall; 
    theData.ons(preall) = 0;
    theData.dur(preall) = 0;  %records precise trial duration
    theData.mouseX(preall) = 0;
    theData.mouseY(preall) = 0;
end

if isfield(S, 'boxType')
    if strcmp (S.boxType, 'handBox')
        fingerOrder = {{'1' '2' '3'} {'4' '5'}};
    elseif strcmp(S.boxType, 'squareBox')
        fingerOrder = {{'8' '9' '4'} {'6' '7'}};
    end
else
    fingerOrder = {{'1' '2' '3'} {'4' '5'}};
end

% Diagram of trial
stimTime = 180*refreshInterval;  % the word and main response time
respEndTime = 30 * refreshInterval;  % for running out of time
fixTime = 10* refreshInterval; % fixation time.  
scanLeadinTime = 12*60*refreshInterval;
modChangeTime = 6*60*refreshInterval;
behLeadinTime = 4*60*refreshInterval;

centerX = S.myRect(3)/2;
centerY = S.myRect(4)/2 - 12; 

% Screen commands
Screen(S.Window,'FillRect', S.screenColor);
Screen(S.Window,'Flip');

cd(thePath.stim);

confScale = {'OLD' 'NEW'};
hands = {'Left','Right'};

if S.scanner==2
    fingers = {'q' 'p'};
elseif S.scanner==1
    fingers = {'1!', '5%'};
end


% for the first block, display instructions
if RetBlock == 1
    ins_txt{1} = sprintf('During this phase of the study, you will view a series of words and will be asked to report your confidence concerning whether each word is "Old" (you encountered it in the first phase) or "New" (you did not encounter it in the first phase).  \n \n You can make your confidence judgment by clicking on the scale arc (see example below).  The greater your confidence that an item is old, the farther towards the edge of the bar labeled OLD you should click.  Similarly, the greater your confidence that a word is new, the farther towards the edge of the bar labeled NEW should you click.  \n \n Please distribute your responses across the entire scale bar.');
    
    Screen('TextSize', S.Window, 30);
    DrawFormattedText(S.Window, ins_txt{1},'center',100,255, 75);
    
    ShowCursor('CrossHair', S.screenNumber);
    
    ResponseRect = [scrsz(3)/2 - 250, scrsz(4)/2+50, scrsz(3)/2 + 250,  scrsz(4)/2+550];
    MaskingRect = [scrsz(3)/2 - 260, scrsz(4)/2+300, scrsz(3)/2 + 260,  scrsz(4)/2+550];
    Screen('FrameOval', S.Window, S.responseBarColor, ResponseRect, 10);
    Screen('FillRect', S.Window,  S.screenColor, MaskingRect); %mask the bottom of the response circle
   
    ShowCursor('CrossHair', S.screenNumber);
    SetMouse(scrsz(3)/2, (scrsz(4)/2 + 100), S.Window);
    DrawFormattedText(S.Window,confScale{S.confScaleNum},scrsz(3)/2 - 280, scrsz(4)/2+320,S.textColor);
    DrawFormattedText(S.Window,confScale{3-S.confScaleNum},scrsz(3)/2 + 215, scrsz(4)/2+320,S.textColor);
    
    Screen('Flip',S.Window);
    AG3getKey('g',S.kbNum);
end

    
% Test stims: text cannot be preloaded, so stims will be generated on the
% fly

message = 'Press g to begin!';
[hPos, vPos] = AG3centerText(S.Window,S.screenNumber,message);
Screen(S.Window,'DrawText',message, hPos, vPos, S.textColor);
Screen(S.Window,'Flip');

% save output file
cd(S.subData);

matName = ['Acc1_retrieve_' num2str(sNum), '_' sName 'out(1).mat'];

checkEmpty = isempty(dir (matName));
suffix = 1;

while checkEmpty ~=1
    suffix = suffix+1;
    matName = ['Acc1_retrieve_' num2str(sNum), '_' sName 'out(' num2str(suffix) ').mat'];
    checkEmpty = isempty(dir (matName));
end

diary ([matName '_diary']);


% Present test trials
goTime = 0;

if S.scanner==1
    % *** TRIGGER ***
    while 1
        AG3getKey('g',S.kbNum);
        [status, startTime] = AG3startScan; % startTime corresponds to getSecs in startScan
        fprintf('Status = %d\n',status);
        if status == 0  % successful trigger otherwise try again
            break
        else
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

% present initial  fixation
if S.scanner == 1
    goTime = goTime + scanLeadinTime;
elseif S.scanner ==2;
    goTime = goTime + behLeadinTime;
end

DrawFormattedText(S.Window,'+','center','center',S.textColor);
Screen(S.Window,'Flip');
qkeys(startTime,goTime,S.boxNum);


for Trial = 1:listLength

    ons_start = GetSecs;        
    theData.onset(Trial) = GetSecs - startTime; %precise onset of trial presentation
    
    % Fixation
    goTime = fixTime;
    [keys RT] = qkeys(ons_start,goTime,S.boxNum); 
    
    % Stim
    goTime = goTime + stimTime;
    message = theData.item{Trial};
    
    % Note: fix these to get rid of magic numbers 
    ResponseRect = [scrsz(3)/2 - 250, scrsz(4)/2-150, scrsz(3)/2 + 250,  scrsz(4)/2+350];
    MaskingRect = [scrsz(3)/2 - 260, scrsz(4)/2+100, scrsz(3)/2 + 260,  scrsz(4)/2+350];
    Screen('FrameOval', S.Window, S.responseBarColor, ResponseRect, 10);
    Screen('FillRect', S.Window,  S.screenColor, MaskingRect); %mask the bottom of the response circle
   
    DrawFormattedText(S.Window,message, 'center', scrsz(4)/2+150, S.textColor);
    ShowCursor('CrossHair', S.screenNumber);
    SetMouse(scrsz(3)/2, (scrsz(4)/2 + 100), S.Window);
    DrawFormattedText(S.Window,confScale{S.confScaleNum},scrsz(3)/2 - 280, scrsz(4)/2+120,S.textColor);
    DrawFormattedText(S.Window,confScale{3-S.confScaleNum},scrsz(3)/2 + 215, scrsz(4)/2+120,S.textColor);
    
    responseRad = 250;
    
    Screen(S.Window,'Flip');
    while 1
        [resp, mouseX, mouseY] = GetClicks(S.Window);
        rad = sqrt((mouseX-scrsz(3)/2)^2 + (mouseY-(scrsz(4)/2+100))^2);
        if (~isempty(resp) && abs(rad-responseRad)<10) % if the mouse was clicked on the bar.
        %if (~isempty(resp))
            HideCursor;
            respTime = GetSecs;
            break
        end
        WaitSecs(.005)
    end
    
    
    % record
    theData.num(Trial) = Trial; 
    theData.ons(Trial) = GetSecs;
    theData.dur(Trial) = GetSecs - ons_start;  %records precise trial duration
    theData.mouseX(Trial) = mouseX;
    theData.mouseY(Trial) = mouseY;
    cmd = ['save ' fullfile(S.subData,matName)];
    eval(cmd);
    
end


DrawFormattedText(S.Window,'Saving...','center','center', [100 100 100]);

cmd = ['save ' fullfile(S.subData,matName)];
eval(cmd);

Screen(S.Window,'FillRect', S.screenColor);	% Blank Screen
Screen(S.Window,'Flip');

ListenChar(1); % tell the command line to listen to key responses again.
Priority(0);

