function varargout = DynaPort_8Ft(varargin)
% DYNAPORT_8FT MATLAB code for DynaPort_8Ft.fig
%      DYNAPORT_8FT, by itself, creates a new DYNAPORT_8FT or raises the existing
%      singleton*.
%
%      H = DYNAPORT_8FT returns the handle to a new DYNAPORT_8FT or the handle to
%      the existing singleton*.
%
%      DYNAPORT_8FT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYNAPORT_8FT.M with the given input arguments.
%
%      DYNAPORT_8FT('Property','Value',...) creates a new DYNAPORT_8FT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DynaPort_8Ft_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DynaPort_8Ft_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DynaPort_8Ft

% Last Modified by GUIDE v2.5 31-Jan-2019 12:56:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DynaPort_8Ft_OpeningFcn, ...
                   'gui_OutputFcn',  @DynaPort_8Ft_OutputFcn, ...
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


% --- Executes just before DynaPort_8Ft is made visible.
function DynaPort_8Ft_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DynaPort_8Ft (see VARARGIN)

% Choose default command line output for DynaPort_8Ft
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DynaPort_8Ft wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DynaPort_8Ft_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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


% --- Executes on button press in addFile.
function addFile_Callback(hObject, eventdata, handles)
% hObject    handle to addFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[infilename, inpathname] = uigetfile('*8FT*', 'Multiselect', 'on');
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


% --- Executes on button press in saveAnalysis.
function saveAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to saveAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global prev_path;
global stpReg;
global strReg;
global stpSym;
global nSteps;
global walkTime;
global stepTimeAvg;
global stepTimeCV;
global stepLn;
global cadence;
global speed;
global editFlag;

if isnan(speed)
    h = findobj('Style', 'pushbutton', 'Tag', 'failAnalysis');
    failAnalysis_Callback(h, eventdata, handles);
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

    newdir = [prev_path{1} '/8FT_analysis'];
    if exist(newdir, 'dir') ~= 7
        mkdir(newdir);
    end


    filename = [newdir '/' prev_str{1}];
    filename = filename(1:length(filename)-4);
    filename = [filename '_analysis.txt'];
    fpout = fopen(filename, 'w');

    fprintf(fpout, 'File: %s\r\n', prev_str{1});
    fprintf(fpout, 'GUI Version 1\r\n\r\n');
    
    if editFlag(1)==1
        fprintf(fpout, 'First Step Removed: Yes\r\n');
    else
        fprintf(fpout, 'First Step Removed: No\r\n');
    end
    
    if editFlag(2)==1
        fprintf(fpout, 'Last Step Removed: Yes\r\n\r\n');
    else
        fprintf(fpout, 'Last Step Removed: No\r\n\r\n');
    end

    fprintf(fpout, 'Walking Time (s): %g\r\n' , walkTime);
    fprintf(fpout, 'Speed (ft/s): %g\r\n' , speed);
    fprintf(fpout, 'Mean Step Time (s): %g\r\n' , stepTimeAvg);
    fprintf(fpout, 'Step Time CV: %g\r\n' , stepTimeCV);
    fprintf(fpout, 'Number of Steps: %g\r\n' , nSteps);
    fprintf(fpout, 'Step Length: %g\r\n' , stepLn);
    fprintf(fpout, 'Cadence: %g\r\n' , cadence);
    fprintf(fpout, 'Step Regularity: %g\r\n' , stpReg);
    fprintf(fpout, 'Stride Regularity: %g\r\n' , strReg);
    fprintf(fpout, 'Step Symmetry: %g\r\n' , stpSym);


    fclose(fpout);

    % remove file from pendingFileList
    % that should take care of loading in the next data as well
    set(handles.pendingFiles, 'Value', 1);
    h = findobj('Style', 'pushbutton', 'Tag', 'removeFiles');
    removeFiles_Callback(h, eventdata, handles);
end


% --- Executes on button press in failAnalysis.
function failAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to failAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global prev_path;

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

newdir = [prev_path{1} '/8FT_analysis'];
if exist(newdir, 'dir') ~= 7
    mkdir(newdir);
end


filename = [newdir '/' prev_str{1}];
filename = filename(1:length(filename)-4);
filename = [filename '_analysis.txt'];
fpout = fopen(filename, 'w');

fprintf(fpout, 'File: %s\r\n', prev_str{1});
fprintf(fpout, 'GUI Version 1\r\n\r\n');
fprintf(fpout, 'Failed Analysis');

fclose(fpout);

% remove file from pendingFileList
% that should take care of loading in the next data as well
set(handles.pendingFiles, 'Value', 1);
h = findobj('Style', 'pushbutton', 'Tag', 'removeFiles');
removeFiles_Callback(h, eventdata, handles);



function loadNullData()

clearvars -global signal;
clearvars -global acc;
clearvars -global ap;
clearvars -global steps;
clearvars -global stpReg;
clearvars -global strReg;
clearvars -global stpSym;
clearvars -global nSteps;
clearvars -global walkTime;
clearvars -global stepTime;
clearvars -global stepTimeAvg;
clearvars -global stepTimeSD;
clearvars -global stepTimeCV;
clearvars -global stepLn;
clearvars -global cadence;
clearvars -global speed;
clearvars -global editFlag;

drawPlots(0);

function loadNewData(path, file)

loadNullData;
filename = [path file];

global signal;
global acc;
global ap;
global editFlag;

editFlag = [0,0];

fs = 100;
signal = textread(filename);
remBeg = 5*fs; remEnd = 3*fs;
if length(signal) > remBeg+remEnd+fs
    acc = signal(remBeg:length(signal)-remEnd, :);
else
    acc = signal(1:length(signal)-remEnd, :);
end
acc = CorrectAlignment(acc);
acc = real(acc);
g = 32.174;
acc(:,1:3) = acc(:,1:3)*g;

fc = 3;
[b, a] = butter(4,fc/(fs/2));
accFilt = filtfilt(b,a, acc);
ap = accFilt(:,3);

calcSteps;



function calcSteps()
global ap;
global steps;
global walk;
global walkSeg;

%Steps are counted as the peak that preceeds the change in sign of the AP acceleration
apCross = find(diff(sign(ap))<0);

%Some Samples show a second peak in the AP acceleration, if this happens,
%choose the first peak
[~,vly] = findpeaks(-ap, 'MinPeakProminence', 1);
vly(ap(vly)<0) = [];
apCross = sort([vly; apCross]);
apCross(apCross<30) = [];

checkDiff = diff(apCross);
minDist = 40;
checkDiff = find(checkDiff < minDist);
apCross(checkDiff+1) = [];


steps = zeros(1,length(apCross));
for ii = 1:length(apCross)
    [~ , loc] = findpeaks(ap(1:apCross(ii)));
    if ~isempty(loc), steps(ii) = loc(end); end         
end
steps(steps==0) = [];

walkSeg = [min(steps), max(steps)];
walk = cell(1);
walk{1} = steps;



function calcVars()
global acc;
global walkSeg;
global walk;
global steps;
global stpReg;
global strReg;
global stpSym;
global nSteps;
global walkTime;
global stepTime;
global stepTimeAvg;
global stepTimeSD;
global stepTimeCV;
global stepLn;
global cadence;
global speed;



if length(steps)>2
    [stpReg, strReg, stpSym, nSteps, walkTime, stepTime] = varWalk(acc, walkSeg, walk);
    walkLN = 8;
    stepTimeAvg = mean(stepTime);
    stepTimeSD = std(stepTime);
    stepTimeCV = stepTimeSD/stepTimeAvg;
    stepLn = walkLN/nSteps;
    cadence = (nSteps/walkTime)*60;
    speed = walkLN/walkTime;
else
    stpReg = NaN; strReg = NaN; stpSym = NaN; nStepts = NaN; walkTime = NaN;
    stepTimeAvg = NaN; stepTimeSD = NaN; stepTimeCV = NaN;
    stepLn = NaN; cadence = NaN; speed = NaN;
end

drawPlots(1)

function drawPlots(realData)

if realData
    global ap;
    global steps;

    timevec = linspace(0.0, (length(ap) -1 )/100, length(ap));
    tSteps = (steps - 1) ./ 100;

    %AP Acc Plot
    hAP = findobj('Type', 'axes', 'Tag', 'apPlot');
    cla(hAP);
    axes(hAP);
    line(timevec, ap, 'Color' , 'k');
    line(tSteps, ap(steps), 'Marker', '*', 'Color' , 'g', 'LineStyle' , 'none');
    set(hAP, 'XLim', [0 timevec(end)] );

else % for the case that it's null data (there is no valid file in the pending file list)
    
    hAP = findobj('Type', 'axes', 'Tag', 'apPlot');
    cla(hAP);
    axes(hAP);
    set(hAP, 'XLim', [0 30]);
end


% --- Executes on button press in firstStep.
function firstStep_Callback(hObject, eventdata, handles)
% hObject    handle to firstStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global walk;
global walkSeg;
global editFlag;
global steps;

%editFlag = [firstStep, lastStep]
editFlag(1) = 1;

steps(1) = [];
walk{1}(1) = [];
walkSeg(1,1) = min(walk{1});
calcVars;

% --- Executes on button press in lastStep.
function lastStep_Callback(hObject, eventdata, handles)
% hObject    handle to lastStep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global walk;
global walkSeg;
global editFlag;
global steps;

%editFlag = [firstStep, lastStep]
editFlag(2) = 1;

steps(end) = [];
ln = length(walk);
walk{ln}(end) = [];
walkSeg(ln,2) = max(walk{ln});
calcVars;


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

prev_str = get(handles.pendingFiles, 'String');

% if prev_str contains only one line of text, it may not be a cell; make it
% a cell
if ~iscell(prev_str)
    temptext = prev_str;
    
    prev_str = cell(1);
    prev_str{1} = temptext;
end

global prev_path;

loadNewData(prev_path{1}, prev_str{1});
calcVars;



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
