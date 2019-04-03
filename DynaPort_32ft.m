function varargout = DynaPort_32ft(varargin)
% DYNAPORT_32FT MATLAB code for DynaPort_32ft.fig
%      DYNAPORT_32FT, by itself, creates a new DYNAPORT_32FT or raises the existing
%      singleton*.
%
%      H = DYNAPORT_32FT returns the handle to a new DYNAPORT_32FT or the handle to
%      the existing singleton*.
%
%      DYNAPORT_32FT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYNAPORT_32FT.M with the given input arguments.
%
%      DYNAPORT_32FT('Property','Value',...) creates a new DYNAPORT_32FT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DynaPort_32ft_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DynaPort_32ft_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DynaPort_32ft

% Last Modified by GUIDE v2.5 21-Jan-2019 10:20:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DynaPort_32ft_OpeningFcn, ...
                   'gui_OutputFcn',  @DynaPort_32ft_OutputFcn, ...
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


% --- Executes just before DynaPort_32ft is made visible.
function DynaPort_32ft_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DynaPort_32ft (see VARARGIN)

% Choose default command line output for DynaPort_32ft
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DynaPort_32ft wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DynaPort_32ft_OutputFcn(hObject, eventdata, handles) 
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

[infilename, inpathname] = uigetfile('*32FT.txt', 'Multiselect', 'on');
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


% --- Executes on button press in addPeaks.
function addPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to addPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ap;
global yaw;
global turns;
global peaks;
global walkSeg;
global walk;
global steps;
global editFlag;

%editFlag = [twoApPeaks, firstStep, lastStep, editEnd, addPeak, removePeak]
editFlag(5) = 1;

[x, ~] = getpts;

%Convert x from time to index
x = round(x .*100 +1);

if any(abs(yaw(x)) < std(yaw))
    errordlg('Point selected is less than a standard deviation from 0');
else
    lim = max(abs(yaw(1:150)));
    if lim*3 > max(abs(yaw))
        ind = find(diff(sign(yaw)));
    else
        ind = find(abs(yaw) < lim);
    end

    [~, pks] = findpeaks(yaw);
    [~, vly] = findpeaks(-yaw);
    tAdd = zeros(length(x), 2);

    for ii = 1:length(x)
        limCross = ind - x(ii);
        if yaw(x(ii)) > 0
            loc = vly;
        else
            loc = pks;
        end
        
        l = limCross(limCross<0);
        l = l(end) + x(ii);
        lLim = loc - l;
        lLim = lLim(lLim<0);
        tAdd(ii,1) = lLim(end) + l;
        
        r = limCross(limCross>0);
        if isempty(r)
            rLim = length(yaw);
        else
            r = r(1) + x(ii);
            rPeak = loc - r;
            rPeak = rPeak(rPeak>0);
            rLim = rPeak(1) + r;
        end
        tAdd(ii,2) = rLim;
        [~, xPeak] = max(abs(yaw(tAdd(ii,1):tAdd(ii,2))));
        x(ii) = xPeak + tAdd(ii,1);
    end
    
    dupl = 0;
    for jj = 1:size(turns,1)
        tol = 50;
        check = turns(jj,1)-tol:turns(jj,2)+tol;
        if ~isempty(intersect(tAdd, check))
            turns(jj,:) = [min(tAdd(1), turns(jj,1)) , max(tAdd(2) , turns(jj,2))];
            dupl = 1;
        end
    end
        
    if ~dupl
        turns = [turns; tAdd];
        turns = sort(turns);
        peaks = [peaks x'];
        peaks = sort(peaks);
    end
    
    [ walkSeg, walk, steps ] = findSteps( ap, turns );
    calcVars;
    
end
    
    

% --- Executes on button press in removePeaks.
function removePeaks_Callback(hObject, eventdata, handles)
% hObject    handle to removePeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global ap;
global turns;
global peaks;
global walkSeg;
global walk;
global steps;
global editFlag;

%editFlag = [twoApPeaks, firstStep, lastStep, editEnd, addPeak, removePeak]
editFlag(6) = 1;

checkLn = length(peaks);
[x, ~] = getpts;

%Convert x from time to index
x = round(x .*100 +1);
tol = 15;

for ii = 1: length(x);
    ind = find(peaks >= x(ii)-tol & peaks <=x(ii)+tol);
    peaks(ind) = [];
    turns(ind,:) = [];
end

if checkLn == length(peaks)
    errordlg('No Peaks Selected');
else
    [ walkSeg, walk, steps ] = findSteps( ap, turns );
    calcVars;
end

% --- Executes on button press in editEnd.
function editEnd_Callback(hObject, eventdata, handles)
% hObject    handle to editEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global turns;
global peaks;
global walkSeg;
global walk;
global steps;
global acc;
global yaw;
global ap;
global endTurn;
global editFlag;

%editFlag = [twoApPeaks, firstStep, lastStep, editEnd, addPeak, removePeak]
editFlag(4) = 1;


[x, ~] = getpts;
%Convert x from time to index
x = round(x .*100 +1);
tol = 15;

%Find if point selected has already been identified as a turn
ind = find(peaks >= x-tol & peaks <=x+tol);
if (abs(yaw(x)) < std(yaw))
    errordlg('Point selected is less than a standard deviation from 0');
else
    if isempty(ind)
        xCross = find(diff(sign(yaw)));
        tStart = xCross(xCross < x);
        newEnd = tStart(end);
        int = ceil(x-newEnd)/2;
        endInt = newEnd:newEnd+int;
        endStep = intersect(steps,endInt);
    else
        newEnd = turns(ind(1),1);
        int = round(diff(turns(ind(1),:))/4);
        endInt = turns(ind(1),1):turns(ind(1),1)+int;
        endStep = intersect(steps, endInt);
        
        peaks(ind(1):end) = [];
        turns(ind(1):end,:) = [];
    end
    if ~isempty(endStep)
        m = mean(diff(steps));
        sd = 2*std(diff(steps));
        endStep = endStep(1);
        stepIX = find(steps == endStep); 
        checkStep = endStep(1) - steps(stepIX(1)-1);
        if checkStep < m+sd && checkStep > m-sd
            endTurn = newEnd;
            tempE = find(diff(sign(ap)));
            tempE = tempE(tempE > endStep);
            newEnd = tempE(1)+5;    %allow time after sign change for algorithm to calculate a step
        end
    end
    acc(newEnd:end, :) = [];
    yaw(newEnd:end, :) = [];
    ap(newEnd:end, :) = [];
    [ walkSeg, walk, steps ] = findSteps( ap, turns );
    calcVars;
end




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




function loadNullData()
clearvars -global signal;
clearvars -global acc;
clearvars -global ap;
clearvars -global yaw;
clearvars -global walkSeg;
clearvars -global walk;
clearvars -global steps;
clearvars -global turnMin;
clearvars -global turns;
clearvars -global peaks;
clearvars -global data;
clearvars -global removeYaw;
clearvars -global removeVert;
clearvars -global remBeg;

drawPlots(0);

%clear text in flagText
h = findobj('Style', 'edit', 'Tag', 'flagText');
set(h,'String', ' ');



function loadNewData(path, file)

loadNullData;
filename = [path file];

pathRemove = 'segmented\';
pathQC = [path(1:end-length(pathRemove)) 'qc\'];
fileRemove = '_32FT.txt';
fileQC = [file(1:end-length(fileRemove)) '.qcd'];
filenameQC = [pathQC fileQC];

global remBeg;
global signal;
global acc;
global yaw;
global ap;
global turnMin;
global peaks;
global turns;
global walkSeg;
global walk;
global steps;
global endTurn;
global editFlag;

endTurn = [];   %Used for visualization if editEnd is used
editFlag = zeros(1,6);  %Used to determine which buttons were used to deviate from normal algroithm
%editFlag = [twoApPeaks, firstStep, lastStep, editEnd, addPeak, removePeak]

fs = 100;

signal = textread(filename);
remBeg = 5*fs; remEnd = 3*fs;
avgOr = mean(signal(fs/2:remBeg - (fs/2),:));
acc = signal(remBeg:length(signal)-remEnd, :);
acc = CorrectAlignment(acc, avgOr);
acc = real(acc);
g = 32.174;
acc(:,1:3) = acc(:,1:3)*g;

fc = 3;
[b, a] = butter(4,fc/(fs/2));
accFilt = filtfilt(b,a, acc);
ap = accFilt(:,3);
yaw = accFilt(:,4);


qc = importdata(filenameQC);
qcData = qc.data;
t360(1) = qcData(4,4) - qcData(4,3);
t360(2) = qcData(5,4) - qcData(5,3);
if any(t360 ==0)
    t360 = sum(t360);
elseif sum(t360) == 0
    t360 = 250;
end

turnMin = min(t360);
[peaks, turns] = findTurns(yaw, turnMin);
[ walkSeg, walk, steps ] = findSteps( ap, turns );



function calcVars()

global acc;
global walkSeg;
global walk;
global data;

walkLN = 8*length(walkSeg);

[stpReg, strReg, stpSym, nSteps, walkTime, stepTime] = varWalk(acc, walkSeg, walk);

stepTimeAvg = mean(stepTime);
stepTimeSD = std(stepTime);
stepTimeCV = stepTimeSD/stepTimeAvg;
stepLn = walkLN/nSteps;
cadence = (nSteps/walkTime)*60;
speed = walkLN/walkTime;

stpRegAvg = mean(stpReg);
strRegAvg = mean(strReg);
stpSymAvg = mean(stpSym);

data = [stpRegAvg, strRegAvg, stpSymAvg, walkTime, nSteps, stepTimeAvg, stepTimeCV, stepLn, speed, cadence, walkLN];

drawPlots(1);


function drawPlots(realdataflag)

if realdataflag             %for the case that there's a valid current file
    global acc;
    global yaw;
    global ap;
    global turns;
    global peaks;
    global steps;
    global walk;
    global endTurn;
    
    timevec = linspace(0.0, (length(acc) -1 )/100, length(acc));
    
    tSteps = (steps - 1) ./ 100;
    tPeaks = (peaks - 1) ./ 100;
    tTurns = (turns - 1) ./ 100;
    
    if ~isempty(endTurn)
        tTurns = [tTurns; (endTurn-1)/100 , timevec(end)];
    end
    
    
    %AP Acc Plot
    apLim = [min(ap) , max(ap)];
    hAP = findobj('Type', 'axes', 'Tag', 'apPlot');
    cla(hAP);
    axes(hAP);
    line(timevec, ap, 'Color' , 'k');
    line(tSteps, ap(steps), 'Marker', '*', 'Color' , 'g', 'LineStyle' , 'none');

    set(hAP, 'XLim', [0 timevec(end)] );
    for ii = 1:size(tTurns,1)
        removeAP(ii) = rectangle('Position' , [tTurns(ii,1), apLim(1), diff(tTurns(ii,:)), diff(apLim)], 'FaceColor', [1 .72 .72], 'EdgeColor', [0 0 0], 'LineStyle', 'none');
        uistack(removeAP(ii), 'bottom');
    end
    for ii = 1:length(walk)
        walkLim = [walk{ii}(1), walk{ii}(end)]/100;
        walkSeg(ii) = rectangle('Position' , [walkLim(1), apLim(1), diff(walkLim), diff(apLim)], 'EdgeColor', 'b');
        %uistack(walkSeg(ii), 'bottom');
        %walkSeg = [walk{ii}(1), walk{ii}(end)];
        %line(walkSeg/100, ap(walkSeg), 'Color', 'b')
    end
    
    %Yaw Plot
    yawLim = [min(yaw) , max(yaw)];
    hYaw = findobj('Type', 'axes', 'Tag', 'yawPlot');
    cla(hYaw);
    axes(hYaw);
    line(timevec, yaw, 'Color', 'k');
    line(tPeaks, yaw(peaks), 'Marker', '*', 'Color' , 'r', 'LineStyle' , 'none');
    set(hYaw, 'XLim', [0 timevec(end)]);
    for ii = 1:size(tTurns,1)
        removeYaw(ii) = rectangle('Position' , [tTurns(ii,1), yawLim(1), diff(tTurns(ii,:)), diff(yawLim)], 'FaceColor', [1 .72 .72], 'EdgeColor', [0 0 0], 'LineStyle', 'none');
        uistack(removeYaw(ii), 'bottom');
    end

    
else % for the case that it's null data (there is no valid file in the pending file list)
    
    hAP = findobj('Type', 'axes', 'Tag', 'apPlot');
    cla(hAP);
    axes(hAP);
    set(hAP, 'XLim', [0 30]);
    
    hYaw = findobj('Type', 'axes', 'Tag', 'yawPlot');
    cla(hYaw);
    axes(hYaw);
    set(hYaw, 'XLim', [0 30]);
    
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

global prev_path;
global remBeg;
global acc;
global data;
global turns;
global walkSeg;
global editFlag;


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
    
    newdir = [prev_path{1} '/32FT_analysis'];
    if exist(newdir, 'dir') ~= 7
        mkdir(newdir);
    end
    
    
    filename = [newdir '/' prev_str{1}];
    filename = filename(1:length(filename)-4);
    filename = [filename '_analysis.txt'];
    fpout = fopen(filename, 'w');
    
    fprintf(fpout, 'File: %s\r\n', prev_str{1});
    fprintf(fpout, 'GUI Version 1\r\n');
    idstr = ['Performing analysis: ' get(handles.id, 'String') '\r\n\r\n'];
    fprintf(fpout, idstr);
    
    if length(flg) > 1
        fprintf(fpout, 'Reason for flag: %s\r\n\r\n', flg);
    end
    
    %editFlag = [twoApPeaks, firstStep, lastStep, editEnd, addPeak, removePeak]
    
    if editFlag(1)==1, fprintf(fpout, 'Two AP Peak Analysis Used \r\n'); end
    if editFlag(4)==1, fprintf(fpout, 'New Length: %i \r\n', length(acc)+remBeg); end
    if editFlag(2)==1, fprintf(fpout, 'First step removed manually in analysis \r\n'); end
    if editFlag(3)==1, fprintf(fpout, 'Last step removed manually in analysis \r\n'); end
    if (editFlag(5) + editFlag(6)) > 0, fprintf(fpout, 'Turns edited manually in analysis \r\n'); end
    if sum(editFlag) > 0, fprintf(fpout, '\r\n'); end
    
    for ii = 1:size(turns,1)
        fprintf(fpout, 'Turn %s: %i to %i\r\n', num2str(ii), turns(ii,1)+remBeg, turns(ii,2)+remBeg);
    end
    fprintf(fpout, '\r\n');
    
    for jj = 1:size(walkSeg,1)
        fprintf(fpout, 'Walk Segment %s: %i to %i\r\n', num2str(jj), walkSeg(jj,1)+remBeg, walkSeg(jj,2)+remBeg);
    end
    fprintf(fpout, '\r\n');
    
    %data = [stpReg, strReg, stpSym, walkTime, nSteps, stepTimeAvg, stepTimeCV, stepLn, speed, cadence, walkLN];
    
    fprintf(fpout, 'Walk Length Analyzed (ft): %g\r\n' , data(11));
    fprintf(fpout, 'Walking Time (s): %g\r\n' , data(4));
    fprintf(fpout, 'Speed (ft/s): %g\r\n' , data(9));
    fprintf(fpout, 'Mean Step Time (s): %g\r\n' , data(6));
    fprintf(fpout, 'Step Time CV: %g\r\n' , data(7));
    fprintf(fpout, 'Number of Steps: %g\r\n' , data(5));
    fprintf(fpout, 'Step Length: %g\r\n' , data(8));
    fprintf(fpout, 'Cadence: %g\r\n' , data(10));
    fprintf(fpout, 'Step Regularity: %g\r\n' , data(1));
    fprintf(fpout, 'Stride Regularity: %g\r\n' , data(2));
    fprintf(fpout, 'Step Symmetry: %g\r\n' , data(3));
    
    
    fclose(fpout);
    
    % remove file from pendingFileList
    % that should take care of loading in the next data as well
    set(handles.pendingFiles, 'Value', 1);
    h = findobj('Style', 'pushbutton', 'Tag', 'removeFiles');
    removeFiles_Callback(h, eventdata, handles);
    
    
end


% --- Executes on button press in apPeaks.
function apPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to apPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ap;
global turns;
global steps;
global walk;
global walkSeg;
global editFlag;

%editFlag = [twoApPeaks, firstStep, lastStep, editEnd, addPeak, removePeak]
editFlag(1) = 1;

ln = length(ap);
minStep = 40;
steps = [];
for ii=minStep+1:ln-minStep
    a=ap(ii-minStep:ii+minStep);
    if ap(ii) == max(a)
        steps = [steps ii];
    end
end

nTurns = size(turns,1);
sd = 2*std(diff(steps));
m = mean(diff(steps));
walk = cell(1,nTurns+1);
for ii = 1:nTurns+1
    if ii==1, 
       walk{ii} = steps(steps < turns(ii,1));
       int = round(diff(turns(ii,:))/4);
       endInt = turns(ii,1):turns(ii,1)+int;
       endStep = intersect(steps, endInt);
       if ~isempty(endStep)
           temp = endStep(1) - walk{ii}(end);
           if  temp < m+sd && temp > m-sd
               walk{ii} = [walk{ii}, endStep(1)];
           end
       end
    elseif ii>nTurns
        walk{ii} = steps(steps > turns(ii-1,2));
        int = round(diff(turns(ii-1,:))/4);
        startInt = turns(ii-1,2)-int:turns(ii-1,2);
        startStep = intersect(steps, startInt );
        if ~isempty(startStep)
            temp = walk{ii}(1) - startStep(end);
            if temp < m+sd && temp > m-sd
                walk{ii} = [startStep(end), walk{ii}];
            end
        end
    else
        walk{ii} = steps(steps<turns(ii,1)); 
        walk{ii} = walk{ii}(walk{ii} > turns(ii-1,2));
        int = round(diff(turns(ii-1,:))/4);
        startInt = turns(ii-1,2)-int:turns(ii-1,2);
        startStep = intersect(steps, startInt );
        if ~isempty(startStep)
            temp = walk{ii}(1) - startStep(end);
            if temp < m+sd && temp > m-sd
                walk{ii} = [startStep(end), walk{ii}];
            end
        end
        int = round(diff(turns(ii,:))/4);
        endInt = turns(ii,1):turns(ii,1)+int;
        endStep = intersect(steps, endInt);
        if ~isempty(endStep)
           temp = endStep(1) - walk{ii}(end);
           if temp < m+sd && temp > m-sd
               walk{ii} = [walk{ii}, endStep(1)];
           end
        end
    end
end

walkSeg = zeros(length(walk),2);
for ii = 1:length(walk)
    walkSeg(ii,1) = min(walk{ii});
    walkSeg(ii,2) = max(walk{ii});
end

calcVars;


% --- Executes on button press in lastStep.
function lastStep_Callback(hObject, eventdata, handles)
% hObject    handle to lastStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global walk;
global walkSeg;
global editFlag;

%editFlag = [twoApPeaks, firstStep, lastStep, editEnd, addPeak, removePeak]
editFlag(3) = 1;

ln = length(walk);
walk{ln}(end) = [];
walkSeg(ln,2) = max(walk{ln});
calcVars;


% --- Executes on button press in firstStep.
function firstStep_Callback(hObject, eventdata, handles)
% hObject    handle to firstStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global walk;
global walkSeg;
global editFlag;

%editFlag = [twoApPeaks, firstStep, lastStep, editEnd, addPeak, removePeak]
editFlag(2) = 1;

walk{1}(1) = [];
walkSeg(1,1) = min(walk{1});
calcVars;


% --- Executes on button press in resetAnalysis.
function resetAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to resetAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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

% --- Executes on button press in failAnalysis.
function failAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to failAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global prev_path;
global remBeg;
global acc;
global data;
global turns;
global walkSeg;
global editFlag;


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
    
    newdir = [prev_path{1} '/32FT_analysis'];
    if exist(newdir, 'dir') ~= 7
        mkdir(newdir);
    end
    
    
    filename = [newdir '/' prev_str{1}];
    filename = filename(1:length(filename)-4);
    filename = [filename '_analysis.txt'];
    fpout = fopen(filename, 'w');
    
    fprintf(fpout, 'File: %s\r\n', prev_str{1});
    fprintf(fpout, 'GUI Version 1.01\r\n');
    idstr = ['Performing analysis: ' get(handles.id, 'String') '\r\n\r\n'];
    fprintf(fpout, idstr);
    
    if length(flg) > 1
        fprintf(fpout, 'Reason for flag: %s\r\n\r\n', flg);
    end

    fclose(fpout);
    
    % remove file from pendingFileList
    % that should take care of loading in the next data as well
    set(handles.pendingFiles, 'Value', 1);
    h = findobj('Style', 'pushbutton', 'Tag', 'removeFiles');
    removeFiles_Callback(h, eventdata, handles);
    
    
end

