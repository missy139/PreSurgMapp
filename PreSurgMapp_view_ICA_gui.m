function varargout = PreSurgMapp_view_ICA_gui(varargin)
% The mainframe to input some parameters
%-----------------------------------------------------------
%   Copyright (C) 2009
%   Neuroimage Computing Group, State Key Laboratory of
%   Cognitive Neuroscience and Learning, Beijing normal University
%	Written by Guiwen Chen
%	Version=1.0;
%	Release=20090715;
%-----------------------------------------------------------
%
% PreSurgMapp_VIEW_ICA_GUI M-file for PreSurgMapp_view_ICA_gui.fig
%      PreSurgMapp_VIEW_ICA_GUI, by itself, creates a new PreSurgMapp_VIEW_ICA_GUI or raises the existing
%      singleton*.
%
%      H = PreSurgMapp_VIEW_ICA_GUI returns the handle to a new PreSurgMapp_VIEW_ICA_GUI or the handle to
%      the existing singleton*.
%
%      PreSurgMapp_VIEW_ICA_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PreSurgMapp_VIEW_ICA_GUI.M with the given input arguments.
%
%      PreSurgMapp_VIEW_ICA_GUI('Property','Value',...) creates a new PreSurgMapp_VIEW_ICA_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before moica_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PreSurgMapp_view_ICA_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PreSurgMapp_view_ICA_gui

% Last Modified by Zhang Han 2011/10/20, modified memory estimation disp error

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
try
    % add this statement to fix the button color
    feature('JavaFigures', 0);
catch
end
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PreSurgMapp_view_ICA_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @PreSurgMapp_view_ICA_gui_OutputFcn, ...
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


% --- Executes just before PreSurgMapp_view_ICA_gui is made visible.
function PreSurgMapp_view_ICA_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% open the window
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PreSurgMapp_view_ICA_gui (see VARARGIN)

% Choose default command line output for PreSurgMapp_view_ICA_gui
handles.output = hObject;

if(~isfield(handles,'moicaCfg'))
    handles.moicaCfg=struct();
    handles.moicaCfg.AppFileList=cell(0,0);
end

for i=2:length(handles.randMode)
    set(handles.randMode(i), 'Value',1);
end
% handles.moicaCfg.dataReduction=setup_gui([compNum,subjectNum,tcNum],'');


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PreSurgMapp_view_ICA_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PreSurgMapp_view_ICA_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in autoEstimate.
function autoEstimate_Callback(hObject, eventdata, handles)
% select the option of estimating the number of component automatically
% hObject    handle to autoEstimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoEstimate

if(get(handles.autoEstimate,'value')==1)
    tmpMsg=sprintf('It will cost a lot of time to estimate the number of component!\n\nAre you sure to do this?');
    if strcmp(questdlg(tmpMsg, 'Confirmation'), 'Yes')
        handles.moicaCfg.isAutoEstimate=1;
        set(handles.compNum,'Enable','off');
    else
        handles.moicaCfg.isAutoEstimate=0;
        set(handles.autoEstimate,'value',0);
        set(handles.compNum,'Enable','on');
    end
else
    set(handles.compNum,'Enable','on');
end
guidata(hObject,handles);


function compNum_Callback(hObject, eventdata, handles)
% hObject    handle to compNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of compNum as text
%        str2double(get(hObject,'String')) returns contents of compNum as a double


% --- Executes during object creation, after setting all properties.
function compNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to compNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in icaAlgorithm.
function icaAlgorithm_Callback(hObject, eventdata, handles)
% hObject    handle to icaAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns icaAlgorithm contents as cell array
%        contents{get(hObject,'Value')} returns selected item from icaAlgorithm


% --- Executes during object creation, after setting all properties.
function icaAlgorithm_CreateFcn(hObject, eventdata, handles)
% hObject    handle to icaAlgorithm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in configICA.
function configICA_Callback(hObject, eventdata, handles)
% hObject    handle to configICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
icaAlgoNo=get(handles.icaAlgorithm, 'Value');
compNum=str2num(get(handles.compNum, 'String'));
if(length(compNum)==0 || compNum<=0)
    compNum=20;
end

if(isfield(handles.moicaCfg,'icaAlgorithmNo'))
    if(icaAlgoNo==handles.moicaCfg.icaAlgorithmNo && isfield(handles.moicaCfg,'ICA_Options'))
        handles.moicaCfg.ICA_Options=icatb_icaOptions([compNum 68000],handles.moicaCfg.icaAlgorithmNo,'on',handles.moicaCfg.ICA_Options);
        guidata(hObject,handles);
        return;
    end
end

handles.moicaCfg.icaAlgorithmNo=icaAlgoNo;

handles.moicaCfg.ICA_Options=icatb_icaOptions([compNum 66000],handles.moicaCfg.icaAlgorithmNo,'on');

guidata(hObject,handles);


% --- Executes on button press in loadConfig.
function loadConfig_Callback(hObject, eventdata, handles)
% press the button of 'Load Configure'
% hObject    handle to loadConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[filename, pathname, filterindex] =uigetfile( ...
{ '*.mat','MAT-files (*.mat)'; ...
 '*.*',  'All Files (*.*)'},...
 'Please select the file storing configure');
if ~(filename==0)
    load(fullfile(pathname,filename));

    handles.moicaCfg=moicacfg;

    set(handles.autoEstimate, 'value',moicacfg.isAutomaticEstimate);%Automatical estimation?
    if(moicacfg.isAutomaticEstimate==1)
        set(handles.compNum, 'Enable','off');
    end
    set(handles.compNum, 'String',sprintf('%d',moicacfg.compNum));% the specfied component number
    % strs=get(handles.icaAlgorithm, 'String');
    set(handles.icaAlgorithm, 'Value',moicacfg.icaAlgorithmNo);% the index of algorithm
    for i=1:length(handles.randMode)
        set(handles.randMode(i), 'Value',moicacfg.randMode{i});
    end

    set(handles.runTimes, 'String',sprintf('%d',moicacfg.runTimes));
    set(handles.outPrefix, 'String',moicacfg.outPrefix);
    set(handles.scaleType, 'Value',moicacfg.scaleType);
    set(handles.outDir, 'String',moicacfg.outDir);
    labels=moicacfg.AppSubjectLabels;
    set(handles.subjectInfo,'String',sprintf('%d groups, %d subjects are selected',length(unique(labels)),length(labels)));

    guidata(hObject, handles);

end

% --- Executes on selection change in randMode.
function randMode_Callback(hObject, eventdata, handles)
% hObject    handle to randMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns randMode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from randMode
handles.mociaCfg.randMode=get(handles.randMode, 'Value');
sumv=sum(cell2mat(handles.mociaCfg.randMode));
numTimes=str2num(get(handles.runTimes, 'String'));
if(sumv==0)
   handles.moicaCfg.runTimes=1;
   set(handles.runTimes, 'String',sprintf('%d',1));
   set(handles.runTimes, 'enable','off');
elseif(sumv>0)
    if(numTimes==1)
        handles.moicaCfg.runTimes=20;
       set(handles.runTimes, 'String',sprintf('%d',handles.moicaCfg.runTimes));
          set(handles.runTimes, 'enable','on');
    end
end
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function randMode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to randMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function runTimes_Callback(hObject, eventdata, handles)
% hObject    handle to runTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of runTimes as text
%        str2double(get(hObject,'String')) returns contents of runTimes as a double


% --- Executes during object creation, after setting all properties.
function runTimes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to runTimes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outPrefix_Callback(hObject, eventdata, handles)
% hObject    handle to outPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outPrefix as text
%        str2double(get(hObject,'String')) returns contents of outPrefix as a double


% --- Executes during object creation, after setting all properties.
function outPrefix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outPrefix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scaleType.
function scaleType_Callback(hObject, eventdata, handles)
% hObject    handle to scaleType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns scaleType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scaleType


% --- Executes during object creation, after setting all properties.
function scaleType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function outDir_Callback(hObject, eventdata, handles)
% hObject    handle to outDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outDir as text
%        str2double(get(hObject,'String')) returns contents of outDir as a double


% --- Executes during object creation, after setting all properties.
function outDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in selectOutDir.
function selectOutDir_Callback(hObject, eventdata, handles)
% hObject    handle to selectOutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
theDir=pwd;
theDir =uigetdir(theDir, 'Please select a file directory to output all the data: ');


if ischar(theDir),
    set(handles.outDir,'String',theDir);
    handles.moicaCfg.outDir=theDir;
end
guidata(hObject, handles);

% --- Executes on button press in help.
function help_Callback(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in exit.
function exit_Callback(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% delete(gcf);
delete(get(0, 'children'));
objs=findobj('-regexp','Name','^gc_\w+$');

if(~isempty(objs))
    delete(objs);
end

% --- Executes on button press in RulAll.
function RulAll_Callback(hObject, eventdata, handles)
% hObject    handle to RulAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
isAutomaticEstimate=0;
% isAutomaticEstimate=get(findobj(handles, 'tag', 'autoEstimate'), 'value')
if(length(handles.moicaCfg.AppFileList)==0)
    warndlg('Please select the file first!');
    return;
end

handles.moicaCfg.isAutomaticEstimate=get(handles.autoEstimate, 'value');%Automatical estimation?
handles.moicaCfg.compNum=str2num(get(handles.compNum, 'String'));% the specfied component number
strs=get(handles.icaAlgorithm, 'String');
handles.moicaCfg.icaAlgorithm=strs{get(handles.icaAlgorithm, 'Value')};% the algorithm of ICA
handles.moicaCfg.icaAlgorithmNo=get(handles.icaAlgorithm, 'Value');% the index of algorithm
handles.moicaCfg.randMode=get(handles.randMode, 'Value');

handles.moicaCfg.runTimes=str2num(get(handles.runTimes, 'String'));
handles.moicaCfg.outPrefix=get(handles.outPrefix, 'String');
strs=get(handles.scaleType, 'String');
handles.moicaCfg.scaleType=get(handles.scaleType, 'Value');
handles.moicaCfg.outDir=get(handles.outDir, 'String');
if(0==exist(handles.moicaCfg.outDir,'dir'))
    errordlg('Please select the output directory');
    return;
end

if(isempty(handles.moicaCfg.outPrefix))
    errordlg('Please input the prefix for outputing');
    return;
end


if 2==exist(fullfile(handles.moicaCfg.outDir, [handles.moicaCfg.outPrefix,'_results.log']),'file'),
    diary off;
	delete(fullfile(handles.moicaCfg.outDir, [handles.moicaCfg.outPrefix,'_results.log']));
    pause(0.1);
end
diary(fullfile(handles.moicaCfg.outDir, [handles.moicaCfg.outPrefix,'_results.log']));
%Initialize the log file
diary on;
    
if(~isfield(handles.moicaCfg,'dataReduction'))
         compNum=handles.moicaCfg.compNum;
        
        if(isfield(handles.moicaCfg,'AppSubjectLabels'))
            subjectNum=length(handles.moicaCfg.AppSubjectLabels);
            tcNum=handles.moicaCfg.AppFileList{1,2};
        else
            subjectNum=20;
            tcNum=200;
        end
        
        handles.moicaCfg.dataReduction=setup_gui([compNum,subjectNum,tcNum],'init');
end

guidata(hObject, handles);

% save the file
saveFile=fullfile(handles.moicaCfg.outDir,[handles.moicaCfg.outPrefix,'_mica_parameter_info.mat']);
if 0==exist(saveFile,'file'),
    moicacfg=handles.moicaCfg;
    save(saveFile,'moicacfg');
end

set(handles.RulAll,'Enable','off');
try
    handles.moicaCfg=nic_rsdd_runAnalysis(handles.moicaCfg);
catch
    nic_waitbar;
    set(handles.RulAll,'Enable','on');
    nic_rsdd_misc('EXCEPTION');
    diary off;
end

set(handles.RulAll,'Enable','on');
guidata(hObject, handles);

% --- Executes on button press in selectFiles.
function selectFiles_Callback(hObject, eventdata, handles)
% hObject    handle to selectFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(size(handles.moicaCfg.AppFileList,1)>0)
    [files labels]=nic_rsdd_inputData('initData',handles.moicaCfg.AppFileList,handles.moicaCfg.AppSubjectLabels);
else
    [files labels]=nic_rsdd_inputData();
end

 handles.moicaCfg.AppFileList=files;
 handles.moicaCfg.AppSubjectLabels=labels;


set(handles.subjectInfo,'String',sprintf('%d group, %d subjects are selected',length(unique(labels)),length(labels)));
 
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function moICA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to moICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




% --- Executes on button press in randOrder.
function randOrder_Callback(hObject, eventdata, handles)
% hObject    handle to randOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of randOrder



% --- Executes on button press in saveConfig.
function saveConfig_Callback(hObject, eventdata, handles)
% hObject    handle to saveConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
isAutomaticEstimate=0;
% isAutomaticEstimate=get(findobj(handles, 'tag', 'autoEstimate'), 'value')
if(length(handles.moicaCfg.AppFileList)==0)
    warndlg('Please select the file first!');
    return;
end

handles.moicaCfg.isAutomaticEstimate=get(handles.autoEstimate, 'value');%Automatical estimation?
handles.moicaCfg.compNum=str2num(get(handles.compNum, 'String'));% the specfied component number
strs=get(handles.icaAlgorithm, 'String');
handles.moicaCfg.icaAlgorithm=strs{get(handles.icaAlgorithm, 'Value')};% the algorithm of ICA
handles.moicaCfg.icaAlgorithmNo=get(handles.icaAlgorithm, 'Value');% the index of algorithm
handles.moicaCfg.randMode=get(handles.randMode, 'Value');

handles.moicaCfg.runTimes=str2num(get(handles.runTimes, 'String'));
handles.moicaCfg.outPrefix=get(handles.outPrefix, 'String');
strs=get(handles.scaleType, 'String');
handles.moicaCfg.scaleType=get(handles.scaleType, 'Value');
handles.moicaCfg.outDir=get(handles.outDir, 'String');
if(~isfield(handles.moicaCfg,'dataReduction'))
         compNum=handles.moicaCfg.compNum;
        
        if(isfield(handles.moicaCfg,'AppSubjectLabels'))
            subjectNum=length(handles.moicaCfg.AppSubjectLabels);
            tcNum=handles.moicaCfg.AppFileList{1,2};
        else
            subjectNum=20;
            tcNum=200;
        end
        
        handles.moicaCfg.dataReduction=setup_gui([compNum,subjectNum,tcNum],'init');
end

moicacfg=handles.moicaCfg;

[filename, pathname, filterindex] =uiputfile( ...
{ '*.mat','MAT-files (*.mat)'; ...
 '*.*',  'All Files (*.*)'},...
 'Save as');

if ~(filename==0)
    save(fullfile(pathname,filename),'moicacfg');
end



% --------------------------------------------------------------------
function SetUpICA_Callback(hObject, eventdata, handles)
% hObject    handle to SetUpICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  compNum=str2num(get(handles.compNum,'String'));
  if(isempty(compNum))
      compNum=20;
  end
        
  if(isfield(handles.moicaCfg,'AppSubjectLabels'))
      subjectNum=length(handles.moicaCfg.AppSubjectLabels);
      tcNum=handles.moicaCfg.AppFileList{1,2};
  else
       subjectNum=20;
       tcNum=200;
       warndlg('Please select the file first!');
       return;
  end
 
  if(isfield(handles.moicaCfg,'dataReduction') && ~isempty(handles.moicaCfg.dataReduction))
      dataReduction=handles.moicaCfg.dataReduction;
       handles.moicaCfg.dataReduction=setup_gui([compNum,subjectNum,tcNum],'dataReduction',dataReduction);
  else
       handles.moicaCfg.dataReduction=setup_gui([compNum,subjectNum,tcNum]);
  end

  guidata(hObject,handles);

% --------------------------------------------------------------------
function EstimateMem_Callback(hObject, eventdata, handles)
% hObject    handle to EstimateMem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
compNum=str2num(get(handles.compNum,'String'));
        
if(~isfield(handles.moicaCfg,'AppSubjectLabels'))
     warndlg('Please select the subject list first!');
     return;
end

handles.moicaCfg.compNum=str2num(get(handles.compNum, 'String'));% the specfied component number
handles.moicaCfg.runTimes=str2num(get(handles.runTimes, 'String'));

[memory_MB memory_GB]=nic_estimate_mem(handles.moicaCfg);
warndlg(sprintf('Memory required is about %.1f GB\nDisk space required is about %.1f GB',memory_MB,memory_GB));

guidata(hObject,handles);

% --------------------------------------------------------------------
function sliceViewer_Callback(hObject, eventdata, handles)
% hObject    handle to sliceViewer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function compExplorer_Callback(hObject, eventdata, handles)
% hObject    handle to compExplorer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)






% --- Executes on button press in guiView.
function guiView_Callback(hObject, eventdata, handles)
% hObject    handle to guiView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% maskMenu = uimenu(handles.guiView, 'label', 'Select mask', 'callback', ...
%     ['icatb_openHTMLHelpFile('''');']);
if(length(handles.moicaCfg.AppFileList)==0)
    warndlg('Please select the file first!');
    return;
end

view_gui(handles.moicaCfg);


% --- Executes during object creation, after setting all properties.
function text1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function selectFiles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function autoEstimate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to autoEstimate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function configICA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to configICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function uipanel4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function text8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function selectOutDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectOutDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function saveConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to saveConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function loadConfig_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadConfig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function RulAll_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RulAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function help_CreateFcn(hObject, eventdata, handles)
% hObject    handle to help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function guiView_CreateFcn(hObject, eventdata, handles)
% hObject    handle to guiView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function exit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to exit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
