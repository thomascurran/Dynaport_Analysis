function varargout = DynaPort_Sway_EC_v101(varargin)
% DYNAPORT_SWAY_EC_V101 MATLAB code for DynaPort_Sway_EC_v101.fig
%      DYNAPORT_SWAY_EC_V101, by itself, creates a new DYNAPORT_SWAY_EC_V101 or raises the existing
%      singleton*.
%
%      H = DYNAPORT_SWAY_EC_V101 returns the handle to a new DYNAPORT_SWAY_EC_V101 or the handle to
%      the existing singleton*.
%
%      DYNAPORT_SWAY_EC_V101('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DYNAPORT_SWAY_EC_V101.M with the given input arguments.
%
%      DYNAPORT_SWAY_EC_V101('Property','Value',...) creates a new DYNAPORT_SWAY_EC_V101 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DynaPort_Sway_EC_v101_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DynaPort_Sway_EC_v101_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DynaPort_Sway_EC_v101

% Last Modified by GUIDE v2.5 01-Oct-2018 15:12:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DynaPort_Sway_EC_v101_OpeningFcn, ...
                   'gui_OutputFcn',  @DynaPort_Sway_EC_v101_OutputFcn, ...
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


% --- Executes just before DynaPort_Sway_EC_v101 is made visible.
function DynaPort_Sway_EC_v101_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DynaPort_Sway_EC_v101 (see VARARGIN)

% Choose default command line output for DynaPort_Sway_EC_v101
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DynaPort_Sway_EC_v101 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DynaPort_Sway_EC_v101_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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


% --- Executes on button press in saveAnalysis.
function saveAnalysis_Callback(hObject, eventdata, handles)
% hObject    handle to saveAnalysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global prev_path;
global signal;
global jerk;
global rms_RD;
global mv;
global cf;
global tp;
global tTot;


flag = get(handles.flagText , 'String');


if length(get(handles.id, 'String')) ~= 3
    errordlg('Specify your 3-digit ID before saving.','modal')
else
    
    prev_str = get(handles.file_list, 'String');
  
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
    
    newdir = [prev_path{1} '/EC_analysis'];
    if exist(newdir, 'dir') ~= 7
        mkdir(newdir);
    end
    
    
    filename = [newdir '/' prev_str{1}];
    filename = filename(1:length(filename)-4);
    filename = [filename '_analysis.txt'];
    fpout = fopen(filename, 'w');
    
    fprintf(fpout, 'Sway analysis for file %s\r\n', prev_str{1});
    fprintf(fpout, 'GUI Version 1.01\r\n');
    dtStr = ['Analyzed on: ' datestr(datetime('now')) '\r\n'];
    fprintf(fpout, dtStr);
    idstr = ['Performing analysis = ' get(handles.id, 'String') '\r\n\r\n'];
    fprintf(fpout, idstr);
    
    check = mean(signal(1:500,1));
    tol = 0.25;
    if (check > 1+tol || check < 1 - tol)
        fprintf(fpout, 'Device Misaligned /r/n');
    end
    
    if length(flag) > 1
        fprintf(fpout, 'Flag: \t%s\r\n', flag);
    else
        fprintf(fpout, 'Flag: \tNone\r\n');
    end
    
    f = cell(6,1);
    f{1} = tTot;
    f{2} = mv;
    f{3} = jerk;
    f{4} = rms_RD;
    f{5} = tp;
    f{6} = cf;
    
    e = cell(6,1);
    e{1} = 'Length of performance (s)';
    e{2} = 'Mean velocity (m/s)';
    e{3} = 'Jerk (m^2/s^2)';
    e{4} = 'Root mean square (m/s^2)';
    e{5} = 'Total power ((m^2/s)^2/Hz)';
    e{6} = 'Centroid frequency (Hz)';
    
    for ii = 1:6
        fprintf(fpout, '%e \t %s\r\n' , f{ii}, e{ii});
    end
    
    
    
    
    
    

      
    fclose(fpout);
    
    % remove file from pendingFileList
    % that should take care of loading in the next data as well
    set(handles.file_list, 'Value', 1);
    h = findobj('Style', 'pushbutton', 'Tag', 'removefile');
    removefile_Callback(h, eventdata, handles);
    
end

% --- Executes on button press in flagPush.
function flagPush_Callback(hObject, eventdata, handles)
% hObject    handle to flagPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function timeVal_Callback(hObject, eventdata, handles)
% hObject    handle to timeVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of timeVal as text
%        str2double(get(hObject,'String')) returns contents of timeVal as a double


% --- Executes during object creation, after setting all properties.
function timeVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to timeVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function jerkVal_Callback(hObject, eventdata, handles)
% hObject    handle to rmsVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmsVal as text
%        str2double(get(hObject,'String')) returns contents of rmsVal as a double


% --- Executes during object creation, after setting all properties.
function jerkVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmsVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rmsVal_Callback(hObject, eventdata, handles)
% hObject    handle to jerkVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jerkVal as text
%        str2double(get(hObject,'String')) returns contents of jerkVal as a double


% --- Executes during object creation, after setting all properties.
function rmsVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jerkVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function mvVal_Callback(hObject, eventdata, handles)
% hObject    handle to rmsVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rmsVal as text
%        str2double(get(hObject,'String')) returns contents of rmsVal as a double


% --- Executes during object creation, after setting all properties.
function mvVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rmsVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cfVal_Callback(hObject, eventdata, handles)
% hObject    handle to cfVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cfVal as text
%        str2double(get(hObject,'String')) returns contents of cfVal as a double


% --- Executes during object creation, after setting all properties.
function cfVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cfVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tpVal_Callback(hObject, eventdata, handles)
% hObject    handle to cfVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cfVal as text
%        str2double(get(hObject,'String')) returns contents of cfVal as a double


% --- Executes during object creation, after setting all properties.
function tpVal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cfVal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addPush.
function addPush_Callback(hObject, eventdata, handles)
% hObject    handle to addPush (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[infilename, inpathname] = uigetfile('*EC.txt', 'Multiselect', 'on');
prev_str = get(handles.file_list, 'String');

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
    set(handles.file_list, 'String', prev_str, 'Value', length(prev_str));
    
    %Make sure files selected are the correct performance
    err = [];
    for ii = 1:length(prev_str)
        if ~strcmp('EO.txt', prev_str{ii}(length(prev_str{ii})-5 : length(prev_str{ii}))) && ~strcmp('EC.txt' , prev_str{ii}(length(prev_str{ii})-5 : length(prev_str{ii})))
            err = [err ii];
        end
    end
    
    if ~isempty(err)
        errmsg = ['File(s) ' , num2str(err), ' not the correct performance, please remove' ];
        uiwait(errordlg(errmsg));
    end
    
    
    if curlength == 0 %this means "if there was not already a valid file in the list"
        loadNewData(prev_path{1}, prev_str{1});
        showData(1);
    end
end


% --- Executes on button press in removefile.
function removefile_Callback(hObject, eventdata, handles)
% hObject    handle to removefile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
prev_str = get(handles.file_list, 'String');
toremove = get(handles.file_list, 'Value');
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
            showData(1);
        %If all files removed    
        elseif toremove(i) == 1 && removeall == true
            prev_str{1} = 'No files selected.';
            clearvars -global prev_path;
            loadNullData();
            showData(0);
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

set(handles.file_list, 'String', prev_str, 'Value', selection);


% --- Executes on selection change in file_list.
function file_list_Callback(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns file_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from file_list


% --- Executes during object creation, after setting all properties.
function file_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

 function loadNullData()
%clear a few global vars
clearvars -global signal;
clearvars -global acc;
clearvars -global timevec;  
clearvars -global jerk; 
clearvars -global rms_RD;
clearvars -global rms_ML;
clearvars -global rms_AP;
clearvars -global mv;
clearvars -global cf;
clearvars -global tp;
clearvars -global aML;
clearvars -global aAP;
clearvars -global pML;
clearvars -global pAP;
clearvars -global tTot;

%clear text in flagText
h = findobj('Style', 'edit', 'Tag', 'flagText');
set(h,'String', ' ');


%tc function 8/15/16
function loadNewData(path, file)

loadNullData;   
    
filename = [path file];


global acc;
global signal;
global jerk;
global rms_RD;
global rms_ML;
global rms_AP;
global mv;
global cf;
global tp;
global aML;
global aAP;
global pML;
global pAP;
global timevec;
global tTot;
    

signal = importdata(filename);
acc =  signal(500:length(signal)-300 , :);

fs = 100;
ln = length(acc);
midAvg = mean(acc(floor(ln/2)-(fs/2):floor(ln/2)+(fs/2),:));

acc = CorrectAlignment(acc, midAvg);
acc = real(acc);
[jerk, rms_RD, rms_ML, rms_AP, mv, cf, tp, aML, aAP, pML, pAP, tTot] = varsSway(acc);
timevec = linspace(0.0, (length(aML)-1)/100, length(aAP));

%tc function 8/15/16
function showData(realdataflag)

if realdataflag             %for the case that there's a valid current file
    global signal;
    global jerk;
    global rms_RD;
    global rms_ML;
    global rms_AP;
    global mv;
    global cf;
    global tp;
    global aML;
    global aAP;
    global pML;
    global pAP;
    global timevec;
    global tTot;
   
    %ML plot (Acceleration)
    rms_ML_line = rms_ML*ones(size(timevec));
    hMLplot = findobj('Type', 'axes', 'Tag', 'MLplot');
    cla(hMLplot);
    axes(hMLplot);
    line(timevec, aML, 'Color', 'b');
    line(timevec, rms_ML_line, 'Color' , 'r');
    set(hMLplot, 'XLim', [0 17] , 'YLim' , [-0.4 0.4]);
    
    %AP plot (Acceleration)
    rms_AP_line = rms_AP*ones(size(timevec));
    hAPplot = findobj('Type', 'axes', 'Tag', 'APplot');
    cla(hAPplot);
    axes(hAPplot);
    line(timevec, aAP, 'Color', 'b');
    line(timevec, rms_AP_line, 'Color' , 'r');
    set(hAPplot, 'XLim', [0 17] , 'YLim' , [-0.4 0.4]);
    
    %RD plot (Position)
    hRDplot = findobj('Type', 'axes', 'Tag', 'RDplot');
    cla(hRDplot);
    axes(hRDplot);
    line(pML, pAP, 'Color', 'k');
    set(hRDplot, 'XLim', [-0.006 0.006] , 'YLim' , [-0.006 0.006]);
    
    %Display Variable Values
    h = findobj('Style', 'edit', 'Tag', 'timeVal');
    set(h,'String', num2str(tTot));
    h = findobj('Style', 'edit', 'Tag', 'jerkVal');
    set(h,'String', num2str(jerk));
    h = findobj('Style', 'edit', 'Tag', 'rmsVal');
    set(h,'String', num2str(rms_RD));
    h = findobj('Style', 'edit', 'Tag', 'mvVal');
    set(h,'String', num2str(mv));
    h = findobj('Style', 'edit', 'Tag', 'cfVal');
    set(h,'String', num2str(cf));
    h = findobj('Style', 'edit', 'Tag', 'tpVal');
    set(h,'String', num2str(tp));

    
else % for the case that it's null data (there is no valid file in the pending file list)
    hMLplot = findobj('Type', 'axes', 'Tag', 'MLplot');
    cla(hMLplot);
    axes(hMLplot);
    set(hMLplot, 'XLim', [0 17], 'YLim', [-0.4 0.4]);
    
    hAPplot = findobj('Type', 'axes', 'Tag', 'APplot');
    cla(hAPplot);
    axes(hAPplot);
    set(hAPplot, 'XLim', [0 17], 'YLim', [-0.4 0.4]);
    
    hRDplot = findobj('Type', 'axes', 'Tag', 'RDplot');
    cla(hRDplot);
    axes(hRDplot);
    set(hRDplot, 'XLim', [-0.006 0.006] , 'YLim' , [-0.006 0.006]);
    
    h = findobj('Style', 'edit', 'Tag', 'timeVal');
    set(h,'String', ' ');
    h = findobj('Style', 'edit', 'Tag', 'jerkVal');
    set(h,'String', ' ');
    h = findobj('Style', 'edit', 'Tag', 'rmsVal');
    set(h,'String', ' ');
    h = findobj('Style', 'edit', 'Tag', 'mvVal');
    set(h,'String', ' ');
    h = findobj('Style', 'edit', 'Tag', 'cfVal');
    set(h,'String', ' ');
    h = findobj('Style', 'edit', 'Tag', 'tpVal');
    set(h,'String', ' ');
    h = findobj('Style', 'edit', 'Tag', 'flagText');
    set(h,'String', ' ');
    
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
