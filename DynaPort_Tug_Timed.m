function varargout = DynaPort_Tug_Timed(varargin)
% DYNAPORT_TUG_TIMED MATLAB code for DynaPort_Tug_Timed.fig
%      DYNAPORT_TUG_TIMED, by itself, creates a new DYNAPORT_TUG_TIMED or raises the existing
%      singleton*.
%
%      H = DYNAPORT_TUG_TIMED returns the handle to a new DYNAPORT_TUG_TIMED or the handle to
%      the existing singleton*.
%
%      DYNAPORT_TUG_TIMED('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYNAPORT_TUG_TIMED.M with the given input arguments.
%
%      DYNAPORT_TUG_TIMED('Property','Value',...) creates a new DYNAPORT_TUG_TIMED or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DynaPort_Tug_Timed_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DynaPort_Tug_Timed_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DynaPort_Tug_Timed

% Last Modified by GUIDE v2.5 12-Jun-2019 11:13:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DynaPort_Tug_Timed_OpeningFcn, ...
                   'gui_OutputFcn',  @DynaPort_Tug_Timed_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before DynaPort_Tug_Timed is made visible.
function DynaPort_Tug_Timed_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DynaPort_Tug_Timed (see VARARGIN)

% Choose default command line output for DynaPort_Tug_Timed
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DynaPort_Tug_Timed wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DynaPort_Tug_Timed_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in addFiles.
function addFiles_Callback(hObject, eventdata, handles)
% hObject    handle to addFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[infilename, inpathname] = uigetfile('*TUG_1.txt;*TUG_2.txt', 'Multiselect', 'on');
prev_str = get(handles.pendingFiles, 'String');

% if prev_str contains only one line of text, it may not be a cell; make it
% a cell
if ~iscell(prev_str)
    temptext = prev_str;
    
    prev_str = cell(1);
    prev_str{1} = temptext;
end

global prev_path;

% may need to create it as cell
if ~exist('prev_path', 'var')
    prev_path = cell(1);
elseif ~iscell(prev_path)
    temptext = prev_path;
    
    prev_path = cell(1);
    prev_path{1} = temptext;
end


% if infilename contains only a single filename, it may not be a cell; make
% it a cell if it contains a single filename
if ~iscell(infilename) && ~isnumeric(infilename)
    temptext = infilename;
    
    infilename = cell(1);
    infilename{1} = temptext;
end

% if a file was selected (ie, user did not press cancel button on get file
% ui) then add file to list. otherwise do nothing.
if iscell(infilename)

    % determine number of genuine files already displayed by checking length of
    % prev_str, keeping in mind that if length = 1, the single line could
    % contain either the default "no file selected" message or a genuine
    % filename
    if length(prev_str) > 1
        curlength = length(prev_str);
    else
        curlength = 0;
    end
    
    for i = 1 : length(infilename)
        prev_str{i+curlength} = infilename{i};
        prev_path{i+curlength} = inpathname;
    end

     % Add composed list to listbox
    set(handles.pendingFiles, 'String', prev_str, 'Value', length(prev_str));
    
    if curlength == 0 %this means "if there was not already a valid file in the list"
        loadNewData(prev_path{1}, prev_str{1});
        calcVars;
    end
    
end


% --- Executes on button press in removeFiles.
function removeFiles_Callback(hObject, eventdata, handles)
% hObject    handle to removeFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prev_str = get(handles.pendingFiles, 'String');
toremove = get(handles.pendingFiles, 'Value');
toremove = sort(toremove, 'descend');

if ~iscell(prev_str)
    temptext = prev_str;
    
    prev_str = cell(1);
    prev_str{1} = temptext;
end

global prev_path;

if ~iscell(prev_path)
    temptext = prev_path;
    
    prev_path = cell(1);
    prev_path{1} = temptext;
end

if length(toremove) == length(prev_path)
    removeall = true;
else
    removeall = false;
end

% %loop in case more than one file selected
for i = length(toremove):-1:1
    
    
    if ( strcmp('.txt', prev_str{i}(length(prev_str{i})-3:length(prev_str{i}))) )
      
        %If first file was removed, need to load new data
        if toremove(i) == 1 && removeall == false 
            prev_str(toremove(i)) = [];
            prev_path(toremove(i)) = [];
            loadNullData();
            loadNewData(prev_path{1}, prev_str{1});
            calcVars;
        %If all files removed    
        elseif toremove(i) == 1 && removeall == true
            prev_str{1} = 'No files selected.';
            clearvars -global prev_path;
            loadNullData();
            drawPlots(0);
        elseif toremove(i) ~= 1
            prev_str(toremove(i)) = [];
            prev_path(toremove(i)) = [];
        end
          
    end
end

if toremove(1) > length(prev_str)
    selection = toremove(1)-1;
else
    selection = toremove(1);
end

set(handles.pendingFiles, 'String', prev_str, 'Value', selection);


% --- Executes on selection change in pendingFiles.
function pendingFiles_Callback(hObject, eventdata, handles)
% hObject    handle to pendingFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pendingFiles contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pendingFiles


% --- Executes during object creation, after setting all properties.
function pendingFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pendingFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function loadNullData()

clear -global signal;
clear -global acc;
clear -global yaw;
clear -global ap;
clear -global pitch;
clear -global yawIX;
clear -global apIX;
clear -global pitchIX;
clear -global walkSeg;
clear -global walk;
clear -global steps;
clear -global DATA;
clear -global editFlag;
clear -global walkFlag;
clear -global remBeg;

global resetUsed;
resetUsed = 0;


%clear text in flagText
h = findobj('Style', 'edit', 'Tag', 'flagText');
set(h,'String', ' ');

%clear text in stsFLG
h = findobj('Style', 'edit', 'Tag', 'stsFLG');
set(h,'String', ' ');

%Clear the toggle boxes for Manual interventions
hP1a = findobj('Style', 'checkbox', 'Tag', 'manP1a');
set(hP1a,'Value',0);

hP1b = findobj('Style', 'checkbox', 'Tag', 'manP1b');
set(hP1b,'Value',0);

hP2a = findobj('Style', 'checkbox', 'Tag', 'manP2a');
set(hP2a,'Value',0);

hP2b = findobj('Style', 'checkbox', 'Tag', 'manP2b');
set(hP2b,'Value',0);

hS1 = findobj('Style', 'checkbox', 'Tag', 'manSix1');
set(hS1,'Value',0);

hS2 = findobj('Style', 'checkbox', 'Tag', 'manSix2');
set(hS2,'Value',0);

hE1 = findobj('Style', 'checkbox', 'Tag', 'manEix1');
set(hE1,'Value',0);

hE2 = findobj('Style', 'checkbox', 'Tag', 'manEix2');
set(hE2,'Value',0);

function loadNewData(path, file)
global time1;
global resetUsed;
if resetUsed ~=1, time1 = datetime('now', 'Format', 'HH:mm:ss.SSS'); end

loadNullData;


filename = [path file];

global remBeg;
global signal;
global acc1;
global acc2;
global apIX;
global yawIX;
global pitchIX;
global sts1;
global editFlag;
global walkFlag;
global walkSeg;
global walk; 
global steps;


%editFlag = [editSTS1 firstStep missWalk editEIX addTurn multAttempt]
editFlag = [0 0 0 0 0 0];
walkFlag = 0;

%apIX = [six1, six2, eix1, eix2]; yawIX = [tst1, tet1, tst2, tet2, yix1, yix2]; pitchIX = [p1a, p1b, p2a, p2b];

g = 32.174;
fs = 100;
remBeg = 3*fs; remEnd = 1.5*fs;

signal = textread(filename);
orient1 = mean(signal(1:remBeg,:));

%Leave 1 second on either side of marker
acc = signal(remBeg:length(signal)-remEnd, :);
acc1 = CorrectAlignment(acc, orient1);
acc1 = real(acc1);
acc1(:,1:3) = acc1(:,1:3)*g;

fc = 3;
[B, A] = butter(4,fc/(fs/2));
acc1 = filtfilt(B,A, acc1);


[ apIX, yawIX, pitchIX, sts1 ] = findTugEvents( acc1 );
six1 = apIX(1); six2 = apIX(2);
p1a = pitchIX(1); p1b = pitchIX(2);


h = findobj('Style', 'edit', 'Tag', 'stsFLG');
if sts1
    set(h,'String', 'Yes');
else
    set(h,'String', 'No');
end

seg = floor((yawIX(4) - yawIX(3))/8);
orWalk = mean(acc(yawIX(3)+seg:yawIX(4)-seg,:));
acc2 = CorrectAlignment(acc, orWalk);
acc2 = real(acc2);
acc2(:,1:3) = acc2(:,1:3)*g;
acc2 = filtfilt(B,A,acc2);


[ apIX, yawIX, pitchIX, ~] = findTugEvents( acc2 );
%Replace First Transitions with calculations from Sit Orientation
apIX(1) = six1; apIX(2) = six2;
pitchIX(1) = p1a; pitchIX(2) = p1b;

ap2 = acc2(:,3);
[ walkSeg, walk, steps ] = findTugSteps( ap2, apIX, yawIX );




function calcVars()

global acc1;
global acc2;
global apIX;
global yawIX;
global pitchIX;
global walkSeg;
global walk;
global DATA;
global editFlag;


[ DATA ] = varTUG( apIX, yawIX, pitchIX, acc1, acc2 );

walkLN = 8*length(walkSeg);

%editFlag = [editSTS1 firstStep missWalk editEIX addTurn multAttempt]
if walkLN < 16, editFlag(3) = 1; end;

[stpReg, strReg, stpSym, nSteps, walkTime, stepTime] = varWalk(acc2, walkSeg, walk);

DATA.stepTimeAvg = mean(stepTime);
DATA.stepTimeSD = std(stepTime);
DATA.stepTimeCV = DATA.stepTimeSD/DATA.stepTimeAvg;
DATA.stepLn = walkLN/nSteps;
DATA.cadence = (nSteps/walkTime)*60;
DATA.speed = walkLN/walkTime;

DATA.stpRegAvg = mean(stpReg);
DATA.strRegAvg = mean(strReg);
DATA.stpSymAvg = mean(stpSym);


drawPlots(1);

function drawPlots(realdataflag)

if realdataflag             %for the case that there's a valid current file
    global acc2;
    global apIX;
    global pitchIX;
    global yawIX;
    global walkSeg;
    global steps;
    
    ap = acc2(:,3);
    yaw = acc2(:,4);
    pitch = acc2(:,5);
    
    timevec = linspace(0.0, (length(acc2) -1 )/100, length(acc2));
    
    tAp = (apIX - 1) ./ 100;
    tPitch = (pitchIX - 1) ./ 100;
    tYaw = (yawIX - 1) ./ 100;
    tTurns = [tYaw(1), tYaw(2); tYaw(3), tYaw(4)];
    tPeaks = [tYaw(5), tYaw(6)];
    tWalkSeg = (walkSeg - 1) ./ 100;
    tSteps = (steps - 1) ./ 100;
    
    %AP Acc Plot
    apLim = [min(ap) , max(ap)];
    hAP = findobj('Type', 'axes', 'Tag', 'apPlot');
    cla(hAP);
    axes(hAP);
    line(timevec, ap, 'Color' , 'k');
    line(tAp, ap(apIX), 'Marker', 'o', 'Color' , 'r', 'LineStyle' , 'none');
    line(tSteps, ap(steps), 'Marker', '*', 'Color' , 'g', 'LineStyle' , 'none');
    
    for ii = 1:size(tTurns,1)
        removeAP(ii) = rectangle('Position' , [tTurns(ii,1), apLim(1), diff(tTurns(ii,:)), diff(apLim)], 'FaceColor', [1 .72 .72], 'EdgeColor', [0 0 0], 'LineStyle', 'none');
        uistack(removeAP(ii), 'bottom');
    end
    for ii = 1:size(walkSeg,1)
        walkLim(ii) = rectangle('Position' , [tWalkSeg(ii,1), apLim(1), tWalkSeg(ii,2) - tWalkSeg(ii,1), diff(apLim)], 'EdgeColor', 'b');
    end
    set(hAP, 'XLim', [0 timevec(end)] );


    %Pitch Acc Plot
    pitchLim = [min(pitch) , max(pitch)];
    hPitch = findobj('Type', 'axes', 'Tag', 'pitchPlot');
    cla(hPitch);
    axes(hPitch);
    line(timevec, pitch, 'Color' , 'k');
    line(tPitch, pitch(pitchIX), 'Marker', 's', 'Color' , 'r', 'LineStyle' , 'none');
    set(hPitch, 'XLim', [0 timevec(end)] );

    
    %Yaw Plot
    yawLim = [min(yaw) , max(yaw)];
    hYaw = findobj('Type', 'axes', 'Tag', 'yawPlot');
    cla(hYaw);
    axes(hYaw);
    line(timevec, yaw, 'Color', 'k');
%     line(tYaw, yaw(yawIX), 'Marker', 'o', 'Color' , 'r', 'LineStyle' , 'none');
    
    line(tYaw(5:6), yaw(yawIX(5:6)), 'Marker', '*', 'Color' , 'r', 'LineStyle' , 'none');
    
    for ii = 1:size(tTurns,1)
        removeYaw(ii) = rectangle('Position' , [tTurns(ii,1), yawLim(1), diff(tTurns(ii,:)), diff(yawLim)], 'FaceColor', [1 .72 .72], 'EdgeColor', [0 0 0], 'LineStyle', 'none');
        uistack(removeYaw(ii), 'bottom');
    end
    set(hYaw, 'XLim', [0 timevec(end)]);

    
else % for the case that it's null data (there is no valid file in the pending file list)
    
    hAP = findobj('Type', 'axes', 'Tag', 'apPlot');
    cla(hAP);
    axes(hAP);
    set(hAP, 'XLim', [0 30]);
    
    hPitch = findobj('Type', 'axes', 'Tag', 'pitchPlot');
    cla(hPitch);
    axes(hPitch);
    set(hPitch, 'XLim', [0 30]);
    
    hYaw = findobj('Type', 'axes', 'Tag', 'yawPlot');
    cla(hYaw);
    axes(hYaw);
    set(hYaw, 'XLim', [0 30]);
    
end


% --- Executes on button press in addTurn.
function addTurn_Callback(hObject, eventdata, handles)
% hObject    handle to addTurn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global acc2;
global apIX;
global yawIX;
global walkSeg;
global walk;
global steps;
global editFlag;

%editFlag = [editSTS1 firstStep missWalk editEIX addTurn multAttempt]
editFlag(5) = 1;

ap = acc2(:,3);
yaw = acc2(:,4);

turns = [yawIX(1), yawIX(2); yawIX(3), yawIX(4)];
peaks = [yawIX(5), yawIX(6)];

[x, ~] = getpts;

%Convert x from time to index
x = round(x .*100 +1);

if any(abs(yaw(x)) < std(yaw))
    errordlg('Point selected is less than a standard deviation from 0');
else
    lim = max(abs(yaw(apIX(1):apIX(1)+150)));
    ind = find(abs(yaw) < lim);
    tAdd = zeros(length(x), 2);

    for ii = 1:length(x)
        limCross = ind - x(ii);
        l = limCross(limCross<0);
        tAdd(ii,1) = l(end) + x(ii);
        r = limCross(limCross>0);
        if isempty(r)
            r = length(yaw);
        else
            r = r(1) + x(ii);
        end
        tAdd(ii,2) = r;
%         [~, xPeak] = max(abs(yaw(tAdd(ii,1):tAdd(ii,2))));
%         x(ii) = xPeak + tAdd(ii,1);
    end
    
    %Find where peak is in relation to already defined turns
    dist = abs(x - sort(reshape(turns,[1,4])));
    [~, tIX] = min(dist);
    
    switch tIX
        case 1
            yawIX(1) = tAdd(1,1);
        case 2
            yawIX(2) = tAdd(1,2);
        case 3
            yawIX(3) = tAdd(1,1);
        case 4
            yawIX(4) = tAdd(1,2);
    end

    
    [ walkSeg, walk, steps ] = findTugSteps( ap, apIX, yawIX );
    
    
    calcVars;
end





function id_Callback(hObject, eventdata, handles)
% hObject    handle to id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of id as text
%        str2double(get(hObject,'String')) returns contents of id as a double


% --- Executes during object creation, after setting all properties.
function id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function flagText_Callback(hObject, eventdata, handles)
% hObject    handle to flagText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of flagText as text
%        str2double(get(hObject,'String')) returns contents of flagText as a double


% --- Executes during object creation, after setting all properties.
function flagText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to flagText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveAnalysis.
function saveAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to saveAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global time1;
time2 = datetime('now', 'Format', 'HH:mm:ss.SSS');

global prev_path;
global remBeg;
global editFlag;
global walkFlag;
global apIX;
global yawIX;
global pitchIX;
global sts1;
global walkSeg;
global DATA;

fs = 100;
flg = get(handles.flagText , 'String');

if length(get(handles.id, 'String')) ~= 3
    errordlg('Specify your 3-digit ID before saving.','modal')
else
    prev_str = get(handles.pendingFiles, 'String');
  
    if ~iscell(prev_str)
        temptext = prev_str;
        
        prev_str = cell(1);
        prev_str{1} = temptext;
    end
    
    % may need to create it as cell
    if ~exist('prev_path', 'var')
        prev_path = cell(1);
    elseif ~iscell(prev_path)
        temptext = prev_path;
        
        prev_path = cell(1);
        prev_path{1} = temptext;
    end
    
    newdir = [prev_path{1} '/TUG_analysis'];
    if exist(newdir, 'dir') ~= 7
        mkdir(newdir);
    end
    
    dir2 = [prev_path{1} '/TUG_time'];
    if exist(dir2, 'dir') ~= 7
        mkdir(dir2);
    end
    f2 = [dir2 '/' prev_str{1}];
    f2 = [f2(1:length(f2)-4), '_time.xlsx'];
    tElapsed = datevec(time2 - time1);
    xlswrite(f2, tElapsed);
    
    filename = [newdir '/' prev_str{1}];
    filename = filename(1:length(filename)-4);
    filename = [filename '_analysis.txt'];
    fpout = fopen(filename, 'w');
    
    fprintf(fpout, 'File: %s\r\n', prev_str{1});
    fprintf(fpout, 'GUI Version 1.1\r\n');
    dtStr = ['Analyzed on: ' datestr(datetime('now')) '\r\n'];
    fprintf(fpout, dtStr);
    idstr = ['Performing analysis: ' get(handles.id, 'String') '\r\n\r\n'];
    fprintf(fpout, idstr);
    
    if length(flg) > 1
        fprintf(fpout, 'Reason for flag: %s\r\n\r\n', flg);
    end
    
    %editFlag = [editSTS1 firstStep missWalk editEIX addTurn multAttempt]
    if editFlag(1)==1, fprintf(fpout, 'STS1 Transition edited manually \r\n'); end
    if editFlag(2)==1, fprintf(fpout, 'First step manually removed \r\n'); end
    if editFlag(3)==1, fprintf(fpout, 'Walking Segment Missing \r\n'); end
    if editFlag(4)==1, fprintf(fpout, 'EIX edited manually in analysis \r\n'); end
    if editFlag(5)==1, fprintf(fpout, 'Turns edited manually in analysis \r\n'); end
    if editFlag(6)==1, fprintf(fpout, 'STS1 Multiple Attempts edited manually in analysis \r\n'); end
    if walkFlag, fprintf(fpout, 'Unable to distinguish walking from turns \r\n'); end
    if sum(editFlag)+walkFlag > 0, fprintf(fpout, '\r\n'); end
    
    strMan = [{'Six1'}, {'Six2'}, {'Eix1'}, {'Eix2'}, {'P1a'}, {'P1b'}, {'P2a'}, {'P2b'}];
    indMan = zeros(1,8);
    manStrOut = 'Indexes found manually: ';
    
    hSix1 = findobj('Style', 'checkbox', 'Tag', 'manSix1');
    indMan(1) =  get(hSix1,'Value');
    hSix2 = findobj('Style', 'checkbox', 'Tag', 'manSix2');
    indMan(2) =  get(hSix2,'Value');
    hEix1 = findobj('Style', 'checkbox', 'Tag', 'manEix1');
    indMan(4) =  get(hEix1,'Value');
    hEix2 = findobj('Style', 'checkbox', 'Tag', 'manEix2');
    indMan(4) =  get(hEix2,'Value');
    
    hP1a = findobj('Style', 'checkbox', 'Tag', 'manP1a');
    indMan(5) =  get(hP1a,'Value');
    hP1b = findobj('Style', 'checkbox', 'Tag', 'manP1b');
    indMan(6) =  get(hP1b,'Value');
    hP2a = findobj('Style', 'checkbox', 'Tag', 'manP2a');
    indMan(7) =  get(hP2a,'Value');
    hP2b = findobj('Style', 'checkbox', 'Tag', 'manP2b');
    indMan(8) =  get(hP2b,'Value');
    
    manIX = find(indMan);
    if isempty(manIX)
        manStrOut = [manStrOut,  'None. '];
    else
        for III=1:length(manIX)
            manStrOut = [manStrOut, strMan{manIX(III)}, ', '];
        end
    end
    manStrOut = [manStrOut(1:end-2), '\r\n'];
    fprintf(fpout, manStrOut);
    
    six1 = apIX(1)+remBeg; six2 = apIX(2)+remBeg; eix1 = apIX(3)+remBeg; eix2 = apIX(4)+remBeg;
    if ~walkFlag
        ts1 = yawIX(1)+remBeg; te1 = yawIX(2)+remBeg; ts2 = yawIX(3)+remBeg; te2 = yawIX(4)+remBeg;
    else 
        ts1 = NaN; te1 = NaN; ts2 = NaN; te2 = NaN;
    end
    p1a = pitchIX(1)+remBeg; p1b = pitchIX(2)+remBeg; p2a = pitchIX(3)+remBeg; p2b = pitchIX(4)+remBeg;

    fprintf(fpout, 'Six1: %i\r\n', six1);
    fprintf(fpout, 'Six2: %i\r\n', six2);
    fprintf(fpout, 'Eix1: %i\r\n', eix1);
    fprintf(fpout, 'Eix2: %i\r\n', eix2);
    fprintf(fpout, 'Turn 1: %i to %i\r\n', ts1, te1);
    fprintf(fpout, 'Turn 2: %i to %i\r\n', ts2, te2);
    fprintf(fpout, 'P1a: %i\r\n', p1a);
    fprintf(fpout, 'P1b: %i\r\n', p1b);
    fprintf(fpout, 'P2a: %i\r\n', p2a);
    fprintf(fpout, 'P2b: %i\r\n\r\n', p2b);
    
    if sts1
        fprintf(fpout, 'Multiple Attempts for STS1: Yes \r\n');
    else
        fprintf(fpout, 'Multiple Attempts for STS1: No \r\n');
    end
        
    
    for jj = 1:size(walkSeg,1)
        fprintf(fpout, 'Walk Segment %s: %i to %i\r\n', num2str(jj), walkSeg(jj,1)+remBeg, walkSeg(jj,2)+remBeg);
    end
    fprintf(fpout, '\r\n');
  
    
    fprintf(fpout, 'Trial Duration (s): %g\r\n', DATA.dur);
    fprintf(fpout, 'STS1 AP Duration (s): %g\r\n', DATA.apDUR_STS1);
    fprintf(fpout, 'STS1 AP Range (ft/s^2): %g\r\n', DATA.apRNG_STS1);
    fprintf(fpout, 'STS1 Pitch Jerk (deg/s^2): %g\r\n', DATA.pitchJERK_STS1);
    fprintf(fpout, 'STS2 AP Range (ft/s^2): %g\r\n', DATA.apRNG_STS2);
    fprintf(fpout, 'STS2 AP Median (ft/s^2): %g\r\n', DATA.apMD_STS2);
    fprintf(fpout, 'STS2 Pitch Jerk (deg/s^2): %g\r\n', DATA.pitchJERK_STS2);
    fprintf(fpout, 'Turn1 Yaw Amp (deg/s): %g\r\n', DATA.yawAMP_T1);
    fprintf(fpout, 'Turn1 Yaw Freq (Hz): %g\r\n', DATA.yawF_T1);
    
    fprintf(fpout, '\r\n');
    
    fprintf(fpout, 'STS1 AP Jerk (ft/s^3): %g\r\n', DATA.apJERK_STS1);
    fprintf(fpout, 'STS1 AP SD (ft/s^2): %g\r\n', DATA.apSD_STS1);
    fprintf(fpout, 'STS1 AP Median (ft/s^2): %g\r\n', DATA.apMD_STS1);
    fprintf(fpout, 'STS1 Pitch Duration (s): %g\r\n', DATA.pitchDUR_STS1);
    fprintf(fpout, 'STS1 Pitch Range (deg/s): %g\r\n', DATA.pitchRNG_STS1);
    fprintf(fpout, 'STS1 Pitch Median (deg/s): %g\r\n', DATA.pitchMD_STS1);
    fprintf(fpout, 'STS1 Pitch SD (deg/s): %g\r\n', DATA.pitchSD_STS1);
    fprintf(fpout, 'STS2 AP Duration (s): %g\r\n', DATA.apDUR_STS2);
    fprintf(fpout, 'STS2 AP Jerk (ft/s^3): %g\r\n', DATA.apJERK_STS2);
    fprintf(fpout, 'STS2 AP SD (ft/s^2): %g\r\n', DATA.apSD_STS2);
    fprintf(fpout, 'STS2 Pitch Duration (s): %g\r\n', DATA.pitchDUR_STS2);
    fprintf(fpout, 'STS2 Pitch Range (deg/s): %g\r\n', DATA.pitchRNG_STS2);
    fprintf(fpout, 'STS2 Pitch Median (deg/s): %g\r\n', DATA.pitchMD_STS2);
    fprintf(fpout, 'STS2 Pitch SD (deg/s): %g\r\n', DATA.pitchSD_STS2);
    fprintf(fpout, 'Turn2 Yaw Amp (deg/s): %g\r\n', DATA.yawAMP_T2);
    fprintf(fpout, 'Turn2 Yaw Freq (Hz): %g\r\n', DATA.yawF_T2);
    fprintf(fpout, 'STS1 AP Jerk A (ft/s^3): %g\r\n', DATA.apJERK_STS1_A);
    fprintf(fpout, 'STS1 AP Jerk B (ft/s^3): %g\r\n', DATA.apJERK_STS1_B);
    fprintf(fpout, 'STS1 Pitch Jerk A (deg/s^2): %g\r\n', DATA.pitchJERK_STS1_A);
    fprintf(fpout, 'STS1 Pitch Jerk B (deg/s^2): %g\r\n', DATA.pitchJERK_STS1_B);
    fprintf(fpout, 'STS2 AP Jerk A (ft/s^3): %g\r\n', DATA.apJERK_STS2_A);
    fprintf(fpout, 'STS2 AP Jerk B (ft/s^3): %g\r\n', DATA.apJERK_STS2_B);
    fprintf(fpout, 'STS2 Pitch Jerk A (deg/s^2): %g\r\n', DATA.pitchJERK_STS2_A);
    fprintf(fpout, 'STS2 Pitch Jerk B (deg/s^2): %g\r\n', DATA.pitchJERK_STS2_B);
    
    fprintf(fpout, '\r\n');
    
    
    fprintf(fpout, 'Walk Speed (ft/s): %g\r\n', DATA.speed);
    fprintf(fpout, 'Step Length (ft): %g\r\n', DATA.stepLn);
    fprintf(fpout, 'Cadence (steps/s): %g\r\n', DATA.cadence);
    fprintf(fpout, 'Step Regularity: %g\r\n', DATA.stpRegAvg);
    fprintf(fpout, 'Stride Regularity: %g\r\n', DATA.strRegAvg);
    fprintf(fpout, 'Step Symmetry: %g\r\n', DATA.stpSymAvg);
    fprintf(fpout, 'Step Time CV: %g\r\n', DATA.stepTimeCV);
    
    fclose(fpout);
    
    % remove file from pendingFileList
    % that should take care of loading in the next data as well
    set(handles.pendingFiles, 'Value', 1);
    h = findobj('Style', 'pushbutton', 'Tag', 'removeFiles');
    removeFiles_Callback(h, eventdata, handles);
    
end



% --- Executes on button press in stsAttempts.
function stsAttempts_Callback(hObject, eventdata, handles)
% hObject    handle to stsAttempts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global editFlag;
global sts1;

%editFlag = [editSTS1 firstStep missWalk editEIX addTurn multAttempt]
editFlag(6) = ~editFlag(6);

sts1 = ~sts1;

h = findobj('Style', 'edit', 'Tag', 'stsFLG');
if sts1
    set(h,'String', 'Yes');
else
    set(h,'String', 'No');
end



function stsFLG_Callback(hObject, eventdata, handles)
% hObject    handle to stsFLG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stsFLG as text
%        str2double(get(hObject,'String')) returns contents of stsFLG as a double


% --- Executes during object creation, after setting all properties.
function stsFLG_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stsFLG (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in firstStep.
function firstStep_Callback(hObject, eventdata, handles)
% hObject    handle to firstStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global walk;
global walkSeg;
global editFlag;

%editFlag = [editSTS1 firstStep missWalk editEIX addTurn multAttempt]
editFlag(2) = 1;

walk{1}(1) = [];
walkSeg(1,1) = min(walk{1});
calcVars;


% --- Executes on button press in editEIX.
function editEIX_Callback(hObject, eventdata, handles)
% hObject    handle to editEIX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global acc2;
global apIX;
global yawIX;
global pitchIX;
global editFlag;

%editFlag = [editSTS1 firstStep missWalk editEIX addTurn multAttempt]
editFlag(4) = 1;

ap = acc2(:,3);
pitch = acc2(:,5);
ln = length(ap);
mdpt = floor(ln/2);
win = [yawIX(3), apIX(3)-10];


%Use same algorithm to determine EIX, but in window from start of Turn 2 to the original Eix1
%For use b/c prior to clicker subjects leaned forward at end, which algorithm may call eix
[pkE1, locE1]=findpeaks(-ap(win(1):win(2)));
[~, indE1] = max(pkE1);
eix1 = locE1(indE1) + win(1);
aX = find(diff(sign(ap(eix1:win(2)))));
if isempty(aX), aX = 0; end
aX = aX(1) + eix1;
[~, locE2]=findpeaks(ap(aX:win(2)));
if isempty(locE2) 
    %Find first point that is within 10% of max height (may change 10%)
    tol = .90;
    thresh = tol*max(ap(eix1:win(2)));
    xThresh = ap(eix1:win(2)) - thresh;
    locE2 = find(xThresh>0);
    if isempty(locE2)
        eix2 = length(ap);
    else
        eix2 = locE2(1) + eix1;
    end
else
    eix2 = locE2(1)+aX;
end

apIX(3) = eix1; apIX(4) = eix2;



%Use new EIX to calculate p2a/b
ss2 = yawIX(3);
ee2=apIX(4); %+0.5*fs;if (ee2>ln ), ee2=ln; end

[pk2B, loc2B]=findpeaks(-pitch(ss2:ee2));
%if peak is detected at end, remove it from list b/c p2b occurs before p2a
temp = ee2-ss2;
if (loc2B(end) == temp)
    loc2B(end) = [];
    pk2B(end) = [];
end

[~, ind2B] = max(pk2B);
p2b = loc2B(ind2B) + ss2;
%If less than tenth of a second between p2b and end of search, take second min
if (ee2-p2b) < 10
    loc2B(ind2B) = [];
    pk2B(ind2B) = [];
    [~, ind2] = max(pk2B);
    p2b = loc2B(ind2) + ss2;
end
pX = find(diff(sign(pitch(p2b:ee2))));
if isempty(pX), pX = 0; end
pX = pX(1) + p2b;
[pk2A, loc2A]=findpeaks(pitch(pX:ee2));
[~, ind2A] = max(pk2A);
p2a = loc2A(ind2A) + pX;

if isempty(p2a)
    [pkA, locA]=findpeaks(pitch(ss2:ee2));
    [~, indA] = max(pkA);
    p2a = locA(indA) + ss2;
    pX = find(diff(sign(pitch(ss2:p2a))));
    if isempty(pX)
        pX = ee2;
    else
        pX = pX(end) + ss2;
    end
    [pkB, locB]=findpeaks(-pitch(ss2:pX),'MinPeakProminence',5);
    [~, indB] = max(pkB);
    p2b = locB(indB) + ss2;
end
    

%Check magnitude of peak differences
check = 0;
[pk, loc] = findpeaks(pitch(ss2:p2b));
if ~isempty(pk)
    pk = pk(end); 
    loc = loc(end)+ss2;
end
check = abs(pk-pitch(p2b)) > abs(pitch(p2a) - pitch(p2b));

if check
    p2a = loc;
    pX = find(diff(sign(pitch(ss2:p2a))));
    pX = pX(end) + ss2;
    [~, loc] = findpeaks(-pitch(ss2:pX));
    p2b = loc(end)+ss2;
end

pitchIX(3) = p2a; pitchIX(4) = p2b;

calcVars;
drawPlots(1);


% --- Executes on button press in walkFail.
function walkFail_Callback(hObject, eventdata, handles)
% hObject    handle to walkFail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global walkFlag;
global yawIX;
global DATA;

walkFlag = 1;
yawIX = [NaN, NaN, NaN, NaN, NaN, NaN];
DATA.yawAMP_T1 = NaN;
DATA.yawF_T1 = NaN;
DATA.yawAMP_T2 = NaN;
DATA.yawF_T2 = NaN;
DATA.speed = NaN;
DATA.stepLn = NaN;
DATA.cadence = NaN;
DATA.strRegAvg = NaN;
DATA.stpSymAvg = NaN;
    


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global resetUsed;
resetUsed = 1;

global prev_path;

prev_str = get(handles.pendingFiles, 'String');

if ~iscell(prev_str)
    temptext = prev_str;
    prev_str = cell(1);
    prev_str{1} = temptext;
end

if ~iscell(prev_path)
    temptext = prev_path;
    prev_path = cell(1);
    prev_path{1} = temptext;
end

loadNewData(prev_path{1}, prev_str{1});
calcVars;


% --- Executes on button press in editSts1.
function editSts1_Callback(hObject, eventdata, handles)
% hObject    handle to editSts1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global acc1;
global acc2;
global apIX;
global yawIX;
global pitchIX;
global sts1;
global editFlag;
global walkSeg;
global walk; 
global steps;

beg2 = 150;
acc0 = acc1(beg2:end,:);
[ ap0, ~, pitch0, sts0 ] = findTugEvents( acc0 );
six1 = ap0(1)+beg2; six2 = ap0(2)+beg2;
p1a = pitch0(1)+beg2; p1b = pitch0(2)+beg2;

sts1 = sts0;
apIX(1) = six1; apIX(2) = six2;
pitchIX(1) = p1a; pitchIX(2) = p1b;

ap2 = acc2(:,3);
[ walkSeg, walk, steps ] = findTugSteps( ap2, apIX, yawIX );

h = findobj('Style', 'edit', 'Tag', 'stsFLG');
if sts1
    set(h,'String', 'Yes');
else
    set(h,'String', 'No');
end

calcVars;

%editFlag = [editSTS1 firstStep missWalk editEIX addTurn multAttempt]
editFlag(1) = 1;




% --- Executes on button press in manSix1.
function manSix1_Callback(hObject, eventdata, handles)
% hObject    handle to manSix1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manSix1
global apIX;
global yawIX;
global acc1;
global acc2;
global walkSeg;
global walk;
global steps;



hPlot = findobj('Type', 'axes', 'Tag', 'apPlot');
[manT,~] = ginput(1);

%Convert from time to index
manIX = round(manT .*100 +1);

%Take the MAXIMUM within small window of manually chosen point
wind = manIX-5:manIX+5;
[~, newIX] = max(acc1(wind,3));
newIX = newIX + wind(1) - 1;

if newIX > apIX(2)
    mydlg = warndlg('Please select a point Before the end of the transition.', 'Error');
    waitfor(mydlg);
    set(hObject,'Value',0);
else
    apIX(1) = newIX;
    set(hObject,'Value',1);
    [ walkSeg, walk, steps ] = findTugSteps( acc2(:,3), apIX, yawIX );
    calcVars;
end





% --- Executes on button press in manEix1.
function manEix1_Callback(hObject, eventdata, handles)
% hObject    handle to manEix1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manEix1

global apIX;
global yawIX;
global acc2;
global walkSeg;
global walk;
global steps;

hPlot = findobj('Type', 'axes', 'Tag', 'apPlot');
[manT,~] = ginput(1);

%Convert from time to index
manIX = round(manT .*100 +1);

%Take the MINIMUM within small window of manually chosen point
wind = manIX-5:manIX+5;
[~, newIX] = min(acc2(wind,3));
newIX = newIX + wind(1) - 1;

if newIX > apIX(4)
    mydlg = warndlg('Please select a point Before the end of the transition.', 'Error');
    waitfor(mydlg);
%     hTog = findobj('Style', 'checkbox', 'Tag', 'manEix1');
    set(hObject,'Value',0);
else
    apIX(3) = newIX;
    set(hObject,'Value',1);
    [ walkSeg, walk, steps ] = findTugSteps( acc2(:,3), apIX, yawIX );
    calcVars;
end

% --- Executes on button press in manSix2.
function manSix2_Callback(hObject, eventdata, handles)
% hObject    handle to manSix2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manSix2

global apIX;
global yawIX;
global acc1;
global acc2;
global walkSeg;
global walk;
global steps;

hPlot = findobj('Type', 'axes', 'Tag', 'apPlot');
[manT,~] = ginput(1);

%Convert from time to index
manIX = round(manT .*100 +1);

%Take the MINIMUM within small window of manually chosen point
wind = manIX-5:manIX+5;
[~, newIX] = min(acc1(wind,3));
newIX = newIX + wind(1) - 1;

if newIX < apIX(1)
    mydlg = warndlg('Please select a point After the start of the transition.', 'Error');
    waitfor(mydlg);
    set(hObject,'Value',0);
else
    apIX(2) = newIX;
    set(hObject,'Value',1);
    [ walkSeg, walk, steps ] = findTugSteps( acc2(:,3), apIX, yawIX );
    calcVars;
end


% --- Executes on button press in manP1a.
function manP1a_Callback(hObject, eventdata, handles)
% hObject    handle to manP1a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manP1a

global pitchIX;
global apIX;
global yawIX;
global acc1;
global acc2;
global walkSeg;
global walk;
global steps;

hPlot = findobj('Type', 'axes', 'Tag', 'pitchPlot');
[manT,~] = ginput(1);

%Convert from time to index
manIX = round(manT .*100 +1);

%Take the MINIMUM within small window of manually chosen point
wind = manIX-5:manIX+5;
[~, newIX] = min(acc1(wind,3));
newIX = newIX + wind(1) - 1;

if newIX > pitchIX(2)
    mydlg = warndlg('Please select a point Before the end of the transition.', 'Error');
    waitfor(mydlg);
    set(hObject,'Value',0);
else
    pitchIX(1) = newIX;
    set(hObject,'Value',1);
    [ walkSeg, walk, steps ] = findTugSteps( acc2(:,3), apIX, yawIX );
    calcVars;
end

% --- Executes on button press in manP2b.
function manP2b_Callback(hObject, eventdata, handles)
% hObject    handle to manP2b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manP2b
global pitchIX;
global apIX;
global yawIX;
global acc2;
global walkSeg;
global walk;
global steps;

hPlot = findobj('Type', 'axes', 'Tag', 'pitchPlot');
[manT,~] = ginput(1);

%Convert from time to index
manIX = round(manT .*100 +1);

%Take the MINIMUM within small window of manually chosen point
wind = manIX-5:manIX+5;
[~, newIX] = min(acc2(wind,3));
newIX = newIX + wind(1) - 1;

if newIX > pitchIX(3)
    mydlg = warndlg('Please select a point Before the end of the transition.', 'Error');
    waitfor(mydlg);
    set(hObject,'Value',0);
else
    pitchIX(4) = newIX;
    set(hObject,'Value',1);
    [ walkSeg, walk, steps ] = findTugSteps( acc2(:,3), apIX, yawIX );
    calcVars;
end
 


% --- Executes on button press in manEix2.
function manEix2_Callback(hObject, eventdata, handles)
% hObject    handle to manEix2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manEix2

global apIX;
global yawIX;
global acc2;
global walkSeg;
global walk;
global steps;

h = findobj('Type', 'axes', 'Tag', 'apPlot');
[manT,~] = ginput(1);

%Convert from time to index
manIX = round(manT .*100 +1);

%Take the MAXIMUM within small window of manually chosen point
wind = manIX-5:manIX+5;
[~, newIX] = max(acc2(wind,3));
newIX = newIX + wind(1) - 1;

if newIX < apIX(3)
    mydlg = warndlg('Please select a point After the start of the transition.', 'Error');
    waitfor(mydlg);
    set(hObject,'Value',0);
else
    apIX(4) = newIX;
    set(hObject,'Value',1);
    [ walkSeg, walk, steps ] = findTugSteps( acc2(:,3), apIX, yawIX );
    calcVars;
end


% --- Executes on button press in manP1b.
function manP1b_Callback(hObject, eventdata, handles)
% hObject    handle to manP1b (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manP1b
global pitchIX;
global apIX;
global yawIX;
global acc1;
global acc2;
global walkSeg;
global walk;
global steps;

h = findobj('Type', 'axes', 'Tag', 'pitchPlot');
[manT,~] = ginput(1);

%Convert from time to index
manIX = round(manT .*100 +1);

%Take the MAXIMUM within small window of manually chosen point
wind = manIX-5:manIX+5;
[~, newIX] = max(acc1(wind,3));
newIX = newIX + wind(1) - 1;

if newIX < pitchIX(1)
    mydlg = warndlg('Please select a point After the start of the transition.', 'Error');
    waitfor(mydlg);
    set(hObject,'Value',0);
else
    pitchIX(2) = newIX;
    set(hObject,'Value',1);
    [ walkSeg, walk, steps ] = findTugSteps( acc2(:,3), apIX, yawIX );
    calcVars;
end


% --- Executes on button press in manP2a.
function manP2a_Callback(hObject, eventdata, handles)
% hObject    handle to manP2a (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of manP2a
global pitchIX;
global apIX;
global yawIX;
global acc2;
global walkSeg;
global walk;
global steps;

h = findobj('Type', 'axes', 'Tag', 'pitchPlot');
[manT,~] = ginput(1);

%Convert from time to index
manIX = round(manT .*100 +1);

%Take the MAXIMUM within small window of manually chosen point
wind = manIX-5:manIX+5;
[~, newIX] = max(acc2(wind,3));
newIX = newIX + wind(1) - 1;

if newIX < pitchIX(4)
    mydlg = warndlg('Please select a point After the start of the transition.', 'Error');
    waitfor(mydlg);
    set(hObject,'Value',0);
else
    pitchIX(3) = newIX;
    set(hObject,'Value',1);
    [ walkSeg, walk, steps ] = findTugSteps( acc2(:,3), apIX, yawIX );
    calcVars;
end
