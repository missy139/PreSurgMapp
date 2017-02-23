function varargout = TUMOR(varargin)

% Toolbox for pipelined processing dedicated to individualized presurgical mapping of eloquent functional areas based on multimodal functional MRI (PreSurgMapp) GUI by Huiyuan Huang.
% Release=V2.0
% Copyright(c) 2014; GNU GENERAL PUBLIC LICENSE
% Written by Huiyuan Huang on Augest-2014
% Zhejiang Key Laboratory for Research in Assessment of Cognitive Impairments,Center for Cognition and Brain Disorder, Hangzhou Normal University, China
% Mail to Author:  <a href="missy139@163.com">Huiyuan Huang
% -----------------------------------------------------------
% Citing Information:
% The processing was carried out by using PreSurgMapp,which is based on SPM8, REST, DPARSFA and MICA.

% Last Modified by Huiyuan Huang on 15-April-2016


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TUMOR_OpeningFcn, ...
    'gui_OutputFcn',  @TUMOR_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before DPARSFA is made visible.
function TUMOR_OpeningFcn(hObject, eventdata, handles, varargin)
Release='V2.0';
handles.Release = Release; % Will be used in mat file version checking (e.g., in function SetLoadedData)

if ispc
    UserName =getenv('USERNAME');
else
    UserName =getenv('USER');
end
Datetime=fix(clock);
fprintf('Welcome: %s, %.4d-%.2d-%.2d %.2d:%.2d \n', UserName,Datetime(1),Datetime(2),Datetime(3),Datetime(4),Datetime(5));
fprintf('Toolbox for pipelined processing dedicated to individualized presurgical mapping of eloquent functional areas based on multimodal functional MRI (PreSurgMapp). \nRelease=%s\n',Release);
fprintf('Copyright(c) 2014; GNU GENERAL PUBLIC LICENSE\n');
fprintf('Zhejiang Key Laboratory for Research in Assessment of Cognitive Impairments,Center for Cognition and Brain Disorder, Hangzhou Normal University, China\n');
fprintf('Mail to Author:  <a href="missy139@163.com">Huang Hui-Yuan\n');
fprintf('-----------------------------------------------------------\n');
fprintf('Citing Information:\nThe processing was carried out by using PreSurgMapp,which is based on SPM8, REST, DPARSFA and MICA.\n');

handles.hContextMenu =uicontextmenu;
set(handles.listSubjectID, 'UIContextMenu', handles.hContextMenu);	% Added popup menu to delete selected subject by right click.
uimenu(handles.hContextMenu, 'Label', 'Remove the selected participant', 'Callback', 'TUMOR(''DeleteSelectedSubjectID'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenu, 'Label', 'Remove all the participants', 'Callback', 'TUMOR(''DeleteAllSubjects'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenu, 'Label', 'Load participant ID from a text file', 'Callback', 'TUMOR(''LoadSubIDFromTextFile'',gcbo,[], guidata(gcbo))');
uimenu(handles.hContextMenu, 'Label', 'Save participant ID to a text file', 'Callback', 'TUMOR(''SaveSubIDToTextFile'',gcbo,[], guidata(gcbo))');


TemplateParameters={ 'Parameter Templates'...
    'ZJPPH'...
    'CCBD'...
    'Calculate FC only'...
    'Calculate Traditional ICA (rest) only'...
    'Calculate Traditional ICA (task) only'...
    'Calculate ICA with DICI (rest) only'...
    'Calculate Task activation only'...
    'Blank'};
set(handles.popupmenuTemplateParameters,'String',TemplateParameters);


if (~ispc) && (~ismac)
    TipString = sprintf([  'Parameter Templates\n'...
        'ZJPPH\n'...
        'CCBD\n'...
        'Calculate FC only\n'...
        'Calculate Traditional ICA (rest) only\n'...
        'Calculate Traditional ICA (task) only\n'...
        'Calculate ICA with DICI (rest) only\n'...
        'Calculate Task activation only'...
        'Blank\n']);
    set(handles.popupmenuTemplateParameters,'ToolTipString',TipString);
end

handles.Cfg.TumorProVersion=Release;
handles.Cfg.WorkingDir=pwd;
handles.Cfg.DataProcessDir=handles.Cfg.WorkingDir;
handles.Cfg.SubjectID={};
handles.Cfg.TimePoints=240;
handles.Cfg.TR=2;
handles.Cfg.IsNeedConvertFunDCM2IMG=1;
handles.Cfg.IsApplyDownloadedReorientMats=0; %YAN Chao-Gan, 130612.
%handles.Cfg.IsNeedConvert4DFunInto3DImg=0;
handles.Cfg.IsRemoveFirstTimePoints=1;
handles.Cfg.RemoveFirstTimePoints=4;
handles.Cfg.IsSliceTiming=1;
handles.Cfg.SliceTiming.SliceNumber=31;
%handles.Cfg.SliceTiming.TR=handles.Cfg.TR;
%handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
handles.Cfg.SliceTiming.SliceOrder=[1:2:31,2:2:30];
handles.Cfg.SliceTiming.ReferenceSlice=31;
handles.Cfg.IsRealign=1;
handles.Cfg.IsCalVoxelSpecificHeadMotion=0;
handles.Cfg.IsNeedReorientFunImgInteractively=0;

handles.Cfg.IsNeedConvertT1DCM2IMG=1;
%handles.Cfg.IsNeedUnzipT1IntoT1Img=0;
handles.Cfg.IsNeedReorientCropT1Img=0;
handles.Cfg.IsNeedReorientT1ImgInteractively=0;
handles.Cfg.IsNeedT1CoregisterToFun=1;
handles.Cfg.IsNeedReorientInteractivelyAfterCoreg=0;

handles.Cfg.IsSegment=0;
handles.Cfg.Segment.AffineRegularisationInSegmentation='mni';

handles.Cfg.IsDARTEL=0;

handles.Cfg.IsCovremove=0;
handles.Cfg.Covremove.Timing='AfterNormalizeFiltering';  %Another option: AfterNormalizeFiltering
handles.Cfg.Covremove.PolynomialTrend=1;
handles.Cfg.Covremove.HeadMotion=1;
handles.Cfg.Covremove.IsHeadMotionScrubbingRegressors=0;
handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDType='FD_Power';
handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDThreshold=0.5;
handles.Cfg.Covremove.HeadMotionScrubbingRegressors.PreviousPoints=1;
handles.Cfg.Covremove.HeadMotionScrubbingRegressors.LaterPoints=2;
handles.Cfg.Covremove.WholeBrain=0;
handles.Cfg.Covremove.CSF=0;
handles.Cfg.Covremove.WhiteMatter=0;
handles.Cfg.Covremove.OtherCovariatesROI=[];

handles.Cfg.IsFilter=1;
handles.Cfg.Filter.Timing='AfterNormalize'; %Another option: BeforeNormalize
handles.Cfg.Filter.ALowPass_HighCutoff=0.08;
handles.Cfg.Filter.AHighPass_LowCutoff=0.01;
handles.Cfg.Filter.AAddMeanBack='Yes';

handles.Cfg.IsNormalize=0;
handles.Cfg.Normalize.Timing='OnFunctionalData'; %Another option: OnFunctionalData
handles.Cfg.Normalize.BoundingBox=[-90 -126 -72;90 90 108];
handles.Cfg.Normalize.VoxSize=[3 3 3];

handles.Cfg.IsSmooth=1;
handles.Cfg.Smooth.Timing='OnFunctionalData'; %Another option: OnFunctionalData
handles.Cfg.Smooth.FWHM=[6 6 6];

handles.Cfg.MaskFile ='';

handles.Cfg.IsWarpMasksIntoIndividualSpace=0;

handles.Cfg.IsDetrend=1;

handles.Cfg.IsCalALFF=0;
%handles.Cfg.CalALFF.ASamplePeriod=2;
handles.Cfg.CalALFF.AHighPass_LowCutoff=0.01;
handles.Cfg.CalALFF.ALowPass_HighCutoff=0.08;
%handles.Cfg.CalALFF.AMaskFilename='Default';
%handles.Cfg.CalALFF.mALFF_1=1;
%handles.Cfg.IsCalfALFF=1;
%handles.Cfg.CalfALFF.ASamplePeriod=2;
%handles.Cfg.CalfALFF.AHighPass_LowCutoff=0.01;
%handles.Cfg.CalfALFF.ALowPass_HighCutoff=0.08;
%handles.Cfg.CalfALFF.AMaskFilename='Default';
%handles.Cfg.CalfALFF.mfALFF_1=1;

handles.Cfg.IsScrubbing=0;
handles.Cfg.Scrubbing.Timing='AfterPreprocessing';
handles.Cfg.Scrubbing.FDType='FD_Power';
handles.Cfg.Scrubbing.FDThreshold=0.5;
handles.Cfg.Scrubbing.PreviousPoints=1;
handles.Cfg.Scrubbing.LaterPoints=2;
handles.Cfg.Scrubbing.ScrubbingMethod='cut';

handles.Cfg.IsCalReHo=0;
handles.Cfg.CalReHo.ClusterNVoxel=27;
handles.Cfg.CalReHo.SmoothReHo=0; %YAN Chao-Gan, 121225.
%handles.Cfg.CalReHo.AMaskFilename='Default';
%handles.Cfg.CalReHo.smReHo=1;
%handles.Cfg.CalReHo.mReHo_1=1;

handles.Cfg.IsCalDegreeCentrality=0;
handles.Cfg.CalDegreeCentrality.rThreshold=0.25;

handles.Cfg.IsCalFCtotal=0; %HHY20150505
handles.Cfg.IsCalFC=0;
handles.Cfg.IsExtractROISignals=0;
handles.Cfg.CalFC.IsMultipleLabel=0;
handles.Cfg.CalFC.ROIDef=[];
%handles.Cfg.CalFC.AMaskFilename='Default';
handles.Cfg.IsDefineROIInteractively = 0;

handles.Cfg.IsExtractAALTC=0;


handles.Cfg.IsCWAS = 0;
handles.Cfg.CWAS.Regressors = [];
handles.Cfg.CWAS.iter = 0;


handles.Cfg.IsNormalizeToSymmetricGroupT1Mean = 0; %YAN Chao-Gan, 121225.
handles.Cfg.IsCalVMHC = 0;


handles.Cfg.FunctionalSessionNumber=1;
handles.Cfg.StartingDirName='FunRaw';


handles.NiftiPairsDataDir={};
handles.NiftiPairsOutputDir={};

handles.Cfg.IsCalICA=0; %HHY20150505
handles.Cfg.IsCalrestICA=0;    % Revised byHHY20150607
handles.Cfg.restICA.TNC=[];
handles.Cfg.IsCaltaskICA=0;
handles.Cfg.taskICA.TNC=[];
handles.Cfg.IsCalDICIICA=0;

handles.Cfg.IsCaltaskactivation=0; %HHY20150505
handles.Cfg.taskname=[];
handles.Cfg.taskactivation.Onset1=[]; %HHY20160415
handles.Cfg.taskactivation.Duration1=[];
handles.Cfg.taskactivation.Onset2=[];
handles.Cfg.taskactivation.Duration2=[];
handles.Cfg.taskcondition=1;


if ~(exist('rest.m')&&exist('spm.m'))
    uiwait(msgbox('TUMOR is based on SPM and REST, Please install Matlab 7.3, SPM5, REST V1.8 or later version at first.','TUMOR')); %Huang Huiyuan 20140815
else
    [SPMversion,c]=spm('Ver');
    SPMversion=str2double(SPMversion(end));
    RESTversion=str2double(rest_misc('GETRESTVERSION'));
    FullMatlabVersion = sscanf(version,'%d.%d.%d.%d%s');
    if (SPMversion<5)||(RESTversion<1.8)||(FullMatlabVersion(1)*1000+FullMatlabVersion(2)<7*1000+3)
        uiwait(msgbox('TUMOR is based on SPM and REST, Please install Matlab 7.3, SPM5, REST V1.8 or later version at first.','TUMOR'));
    end
end


% Make Display correct in linux
if ~ispc
    ZoomFactor=0.8;  %ZoomFactor=0.85;
    ObjectNames = fieldnames(handles);
    for i=1:length(ObjectNames);
        eval(['IsFontSizeProp=isprop(handles.',ObjectNames{i},',''FontSize'');']);
        if IsFontSizeProp
            eval(['PCFontSize=get(handles.',ObjectNames{i},',''FontSize'');']);
            FontSize=PCFontSize*ZoomFactor;
            eval(['set(handles.',ObjectNames{i},',''FontSize'',',num2str(FontSize),');']);
        end
    end
end

% Choose default command line output for TUMOR
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TUMOR wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TUMOR_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on selection change in popupmenuTemplateParameters.
function popupmenuTemplateParameters_Callback(hObject, eventdata, handles)
[ProgramPath, fileN, extn] = fileparts(which('TUMOR.m'));
switch get(hObject, 'Value'),
    case 1,	% PT
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_Blank.mat']);
    case 2,	%ZJPPH
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_ZJPPH.mat']);
    case 3,	%CCBD
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_CCBD.mat']);
    case 4, %Calculating FC only
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_FC.mat']);
    case 5,% restICA
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_restICA.mat']);
    case 6, % taskICA
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_taskICA.mat']);
    case 7, %Calculating DICI ICA only
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_DICIICA.mat']);
    case 8, %Calculating task activation only
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_activation.mat']);
    case 9, % Blank
        load([ProgramPath,filesep,'Jobmats',filesep,'Template_Blank.mat']);
        
end

Cfg.WorkingDir =pwd;
Cfg.DataProcessDir =handles.Cfg.WorkingDir;
SetLoadedData(hObject,handles, Cfg);

% --- Executes during object creation, after setting all properties.
function popupmenuTemplateParameters_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenuTemplateParameters (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function edtWorkingDir_Callback(hObject, eventdata, handles)
theDir =get(hObject, 'String');
SetWorkingDir(hObject,handles, theDir);




% --- Executes during object creation, after setting all properties.
function edtWorkingDir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edtWorkingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in btnSelectWorkingDir.
function btnSelectWorkingDir_Callback(hObject, eventdata, handles)
% hObject    handle to btnSelectWorkingDir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)%     uiwait(msgbox({'DPARSF''s standard processing steps:';...
%         '1. Convert DICOM files to NIFTI images. 2. Remove First Time Points. 3. Slice Timing. 4. Realign. 5. Normalize. 6. Smooth (optional). 7. Detrend. 8. Filter. 9. Calculate ReHo, ALFF, fALFF (optional). 10. Regress out the Covariables (optional). 11. Calculate Functional Connectivity (optional). 12. Extract AAL or ROI time courses for further analysis (optional).';...
%         '';...
%         'All the input image files should be arranged in the working directory, and DPARSF will put all the output results in the working directory.';...
%         '';...
%         'For example, if you start with raw DICOM images, you need to arrange each subject''s fMRI DICOM images in one directory, and then put them in "FunRaw" directory under the working directory. i.e.:';...
%         '{Working Directory}\FunRaw\Subject001\xxxxx001.dcm';...
%         '{Working Directory}\FunRaw\Subject001\xxxxx002.dcm';...
%         '...';...
%         '{Working Directory}\FunRaw\Subject002\xxxxx001.dcm';...
%         '{Working Directory}\FunRaw\Subject002\xxxxx002.dcm';...
%         '...';...
%         '...';...
%         'Please do not name your subjects initiated with letter "a", DPARSF will face difficulties to distinguish the images before and after slice timing if the subjects'' name has an "a" initial.';...
%         '';...
%         'If you start with NIFTI images (.hdr/.img pairs) before slice timing, you need to arrange each subject''s fMRI NIFTI images in one directory, and then put them in "FunImg" directory under the working directory. i.e.:';...
%         '{Working Directory}\FunImg\Subject001\xxxxx001.img';...
%         '{Working Directory}\FunImg\Subject001\xxxxx002.img';...
%         '...';...
%         '{Working Directory}\FunImg\Subject002\xxxxx001.img';...
%         '{Working Directory}\FunImg\Subject002\xxxxx002.img';...
%         '...';...
%         '...';...
%         '';...
%         'If you start with NIFTI images after normalization, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalized" directory under the working directory.';...
%         'If you start with NIFTI images after smooth, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothed" directory under the working directory.';...
%         'If you start with NIFTI images after filter, you need to arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothedDetrendedFiltered" (or "FunImgNormalizedDetrendedFiltered" if without smooth) directory under the working directory.';...
%         },'Please select the Working directory'));
theDir =handles.Cfg.WorkingDir;
theDir =uigetdir(theDir, 'Please select the Working directory: ');
if ~isequal(theDir, 0)
    SetWorkingDir(hObject,handles, theDir);
end

function SetWorkingDir(hObject, handles, ADir)
if 7==exist(ADir,'dir')
    handles.Cfg.WorkingDir =ADir;
    handles.Cfg.DataProcessDir =handles.Cfg.WorkingDir;
    guidata(hObject, handles);
    UpdateDisplay(handles);
end
handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes on selection change in listSubjectID.
function listSubjectID_Callback(hObject, eventdata, handles)
theIndex =get(hObject, 'Value');


function listSubjectID_KeyPressFcn(hObject, eventdata, handles)
%Delete the selected item when 'Del' is pressed
key =get(handles.figDPARSFAMain, 'currentkey');
if seqmatch({key},{'delete', 'backspace'})
    DeleteSelectedSubjectID(hObject, eventdata,handles);
end

function DeleteSelectedSubjectID(hObject, eventdata, handles)
theIndex =get(handles.listSubjectID, 'Value');
if size(handles.Cfg.SubjectID, 1)==0 ...
        || theIndex>size(handles.Cfg.SubjectID, 1),
    return;
end
theSubject=handles.Cfg.SubjectID{theIndex, 1};
tmpMsg=sprintf('Delete the Participant: "%s" ?', theSubject);
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
    if theIndex>1,
        set(handles.listSubjectID, 'Value', theIndex-1);
    end
    handles.Cfg.SubjectID(theIndex, :)=[];
    if size(handles.Cfg.SubjectID, 1)==0
        handles.Cfg.SubjectID={};
    end
    guidata(hObject, handles);
    UpdateDisplay(handles);
end

function DeleteAllSubjects(hObject, eventdata, handles)
tmpMsg=sprintf('Delete all the participants?');
if strcmp(questdlg(tmpMsg, 'Delete confirmation'), 'Yes')
    handles.Cfg.SubjectID={};
    guidata(hObject, handles);
    UpdateDisplay(handles);
end

function LoadSubIDFromTextFile(hObject, eventdata, handles)
[SubID_Name , SubID_Path]=uigetfile({'*.txt','Subject ID Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Pick the text file for all the subject IDs');
SubID_File=[SubID_Path,SubID_Name];
if ischar(SubID_File)
    if exist(SubID_File,'file')==2
        fid = fopen(SubID_File);
        IDCell = textscan(fid,'%s','\n');
        fclose(fid);
        handles.Cfg.SubjectID=IDCell{1};
        guidata(hObject, handles);
        UpdateDisplay(handles);
    end
end

function SaveSubIDToTextFile(hObject, eventdata, handles)
[SubID_Name , SubID_Path]=uiputfile({'*.txt','Subject ID Files (*.txt)';'*.*', 'All Files (*.*)';}, ...
    'Specify a text file to save all the subject IDs');
SubID_File=[SubID_Path,SubID_Name];
if ischar(SubID_File)
    fid = fopen(SubID_File,'w');
    for iSub=1:length(handles.Cfg.SubjectID)
        fprintf(fid,'%s\n',handles.Cfg.SubjectID{iSub});
    end
    fclose(fid);
end


function ReLoadSubjects(hObject, eventdata, handles)
handles.Cfg.SubjectID={};
handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);



% --- Executes during object creation, after setting all properties.
function listSubjectID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listSubjectID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editTimePoints_Callback(hObject, eventdata, handles)
handles.Cfg.TimePoints =str2double(get(hObject,'String'));
if handles.Cfg.TimePoints==0
    uiwait(msgbox({'If the Number of Time Points is set to 0, then PreSurgMapp will not check the number of time points. Please make sure the number of time points by yourself!';...
        },'Set Number of Time Points'));
end
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function editTimePoints_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTimePoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editTR_Callback(hObject, eventdata, handles)
handles.Cfg.TR =str2double(get(hObject,'String'));
if handles.Cfg.TR==0
    uiwait(msgbox({'If TR is set to 0, then PreSurgMapp will retrieve the TR information from the NIfTI images. Please ensure the TR information in NIfTI images are correct!';...
        },'Set TR'));
end
%handles.Cfg.SliceTiming.TR=handles.Cfg.TR;
%handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
%handles.Cfg.Filter.ASamplePeriod=handles.Cfg.TR;
%handles.Cfg.CalALFF.ASamplePeriod=handles.Cfg.TR;
%handles.Cfg.CalfALFF.ASamplePeriod=handles.Cfg.TR;
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function editTR_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editTR (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSliceNumber_Callback(hObject, eventdata, handles)
handles.Cfg.SliceTiming.SliceNumber =str2double(get(hObject,'String'));

if handles.Cfg.SliceTiming.SliceNumber==0
    if exist([handles.Cfg.DataProcessDir,filesep,'SliceOrderInfo.tsv'])==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
    else
        uiwait(msgbox({'SliceOrderInfo.tsv (under working directory) is not detected. Please go {DPARSF}/Docs/SliceOrderInfo.tsv_Instruction.txt for instructions to allow different slice timing correction for different participants. If SliceNumber is set to 0 while SliceOrderInfo.tsv is not set, the slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!!';...
            },'Set Number of Slices'));
    end
end

%handles.Cfg.SliceTiming.TR = handles.Cfg.TR;
%handles.Cfg.SliceTiming.TA=handles.Cfg.SliceTiming.TR-(handles.Cfg.SliceTiming.TR/handles.Cfg.SliceTiming.SliceNumber);
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function editSliceNumber_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSliceNumber (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editSliceOrder_Callback(hObject, eventdata, handles)
SliceOrder=get(hObject,'String');
handles.Cfg.SliceTiming.SliceOrder =eval(['[',SliceOrder,']']);
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function editSliceOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editSliceOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editReferenceSlice_Callback(hObject, eventdata, handles)
handles.Cfg.SliceTiming.ReferenceSlice =str2double(get(hObject,'String'));
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function editReferenceSlice_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editReferenceSlice (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in checkbox_FCtotal.
function checkbox_FCtotal_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.IsCalFCtotal=1;
else
    handles.Cfg.IsCalFCtotal=0;
    handles.Cfg.IsCovremove=0;
    handles.Cfg.IsCalFC=0;
end
handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes on button press in checkboxCovremoveAfterNormalizeFiltering.
function checkboxCovremoveAfterNormalizeFiltering_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.IsCovremove = 1;
    handles.Cfg.Covremove.Timing='AfterNormalizeFiltering';
    %         uiwait(msgbox({'Linear regression was performed to remove the effects of the nuisance covariates:';...
    %             '1. Six head motion parameters: estimated by SPM5''s realign step. If you do not want to use SPM5'' realign, please arrange each subject''s rp*.txt file in one directory (named as same as its functional image directory) , and then put them in "RealignParameter" directory under the working directory. i.e.:';...
    %             '{Working Directory}\RealignParameter\Subject001\rpxxxxx.txt';...
    %             '...';...
    %             '{Working Directory}\RealignParameter\Subject002\rpxxxxx.txt';...
    %             '...';...
    %             '2. Global mean signal: mask created by setting a threshold at 50% on SPM5''s apriori mask (brainmask.nii).';...
    %             '3. White matter signal: mask created by setting a threshold at 90% on SPM5''s apriori mask (white.nii).';...
    %             '4. Cerebrospinal fluid signal: mask created by setting a threshold at 70% on SPM5''s apriori mask (csf.nii).';...
    %             '';...
    %             %         'The regression was based on data after filter, if you want to regress another kind of data, please arrange each subject''s NIFTI images in one directory, and then put them in "FunImgNormalizedSmoothedDetrendedFiltered" (or "FunImgNormalizedDetrendedFiltered") directory under the working directory. i.e.:';...
    %             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject001\xxx001.img';...
    %             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject001\xxx002.img';...
    %             %         '...';...
    %             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject002\xxx001.img';...
    %             %         '{Working Directory}\FunImgNormalizedSmoothedDetrendedFiltered\Subject002\xxx002.img';...
    %             %         '...';...
    %             '';...
    %             },'Regress out nuisance covariates:'));
else
    handles.Cfg.IsCovremove = 0;
end
handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes on button press in checkboxCalFC.
function checkboxCalFC_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.IsCalFC = 1;
else
    handles.Cfg.IsCalFC = 0;
end
%handles.Cfg.CalFC.AMaskFilename=handles.Cfg.MaskFile;
handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);



% --- Executes on button press in pushbutton_DICOMSorter.
function pushbutton_DICOMSorter_Callback(hObject, eventdata, handles)
TUMOR_DicomSorter_gui



% --- Executes on button press in checkbox_ICAtotal.
function checkbox_ICAtotal_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.IsCalICA = 1;
else
    handles.Cfg.IsCalICA = 0;
    handles.Cfg.IsCalrestICA=0;
    handles.Cfg.IsCaltaskICA=0;
    handles.Cfg.IsCalDICIICA =0;
    
end
handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes on button press in checkbox_restICA.
function checkbox_restICA_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.IsCalrestICA = 1;
else
    handles.Cfg.IsCalrestICA = 0;
end

handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);

function edit_rest_TNC_Callback(hObject, eventdata, handles)
handles.Cfg.restICA.TNC =str2double(get(hObject,'String'));
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function text_rest_TNC_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in checkbox_taskICA.
function checkbox_taskICA_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.IsCaltaskICA = 1;
else
    handles.Cfg.IsCaltaskICA = 0;
end

handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);

function edit_task_TNC_Callback(hObject, eventdata, handles)
handles.Cfg.taskICA.TNC =str2double(get(hObject,'String'));
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function text_task_TNC_CreateFcn(hObject, eventdata, handles)



% --- Executes on button press in checkbox_DICIICA.
function checkbox_DICIICA_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.IsCalDICIICA= 1;
    handles.Cfg.IsSegment= 1;
else
    handles.Cfg.IsCalDICIICA = 0;
    handles.Cfg.IsSegment= 0;
end

handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);



% --- Executes on button press in pushbuttonViewComponents.
function pushbuttonViewComponents_Callback(hObject, eventdata, handles)
TUMOR_view_ICA_gui


% --- Executes during object creation, after setting all properties.
function checkbox_ICAtotal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_ICAtotal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_restICA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_restICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function checkbox_DICIICA_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_DICIICA (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% --- Executes during object creation, after setting all properties.

function text_TCN_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit_rest_TNC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rest_TNC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function edit_task_TNC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_task_TNC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function editFWHM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function editFWHM_Callback(hObject, eventdata, handles)
FWHM=get(hObject,'String');
handles.Cfg.Smooth.FWHM =eval(['[',FWHM,']']);
guidata(hObject, handles);
UpdateDisplay(handles);


% --- Executes during object creation, after setting all properties.
function textFWHM_CreateFcn(hObject, eventdata, handles)
% hObject    handle to textFWHM (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function checkbox_taskactivation_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox_taskactivation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in checkbox_taskactivation.
function checkbox_taskactivation_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
    handles.Cfg.IsCaltaskactivation= 1;
else
    handles.Cfg.IsCaltaskactivation = 0;
    
end
handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);



function edit_taskname_Callback(hObject, eventdata, handles)
handles.Cfg.taskname =get(hObject,'String');
handles=CheckCfgParametersBeforeRun(handles);
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function edit_taskname_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function edit_Onset1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Onset1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit_Duration1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Duration1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes during object creation, after setting all properties.
function text_taskname_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function text_Onset1_CreateFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function text_Duration1_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in radiobutton_task_condition1.
function radiobutton_task_condition1_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
handles.Cfg.taskcondition=1;
set(handles.radiobutton_task_condition1,'Value',1);
set(handles.radiobutton_task_condition2,'Value',0);
drawnow;
guidata(hObject, handles);
UpdateDisplay(handles);
end

function edit_Onset1_Callback(hObject, eventdata, handles)
Onset1=get(hObject,'String');
handles.Cfg.taskactivation.Onset1=eval(['[',Onset1,']']);
guidata(hObject, handles);
UpdateDisplay(handles);


function edit_Duration1_Callback(hObject, eventdata, handles)
% handles.Cfg.taskactivation.Duration =str2double(get(hObject,'String'));
% guidata(hObject, handles);
% UpdateDisplay(handles);
Duration1=get(hObject,'String');
handles.Cfg.taskactivation.Duration1 =eval(['[',Duration1,']']);
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes on button press in radiobutton_task_condition2.
function radiobutton_task_condition2_Callback(hObject, eventdata, handles)
if get(hObject,'Value')
handles.Cfg.taskcondition=2;
set(handles.radiobutton_task_condition1,'Value',0);
set(handles.radiobutton_task_condition2,'Value',1);
drawnow;
guidata(hObject, handles);
UpdateDisplay(handles);
end

% --- Executes during object creation, after setting all properties.
function text_Onset2_CreateFcn(hObject, eventdata, handles)

function edit_Onset2_Callback(hObject, eventdata, handles)
Onset2=get(hObject,'String');
handles.Cfg.taskactivation.Onset2=eval(['[',Onset2,']']);
guidata(hObject, handles);
UpdateDisplay(handles);

function edit_Duration2_Callback(hObject, eventdata, handles)
Duration2=get(hObject,'String');
handles.Cfg.taskactivation.Duration2 =eval(['[',Duration2,']']);
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function edit_Duration2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Duration2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editStartingDirName_Callback(hObject, eventdata, handles)
uiwait(msgbox({'If you do not start with raw DICOM images, you need to specify the Starting Directory Name.';...
    'E.g. "FunImgARW" means you start with images which have been slice timing corrected, realigned and normalized.';...
    '';...
    'Abbreviations:';...
    'A - Slice Timing;';...
    'R - Realign';...
    'W - Normalize';...
    'S - Smooth';...
    'D - Detrend';...
    'F - Filter';...
    'C - Covariates Removed';...
    'B - ScruBBing';...
    'sym - Normalized to a symmetric template';...
    },'Tips for Starting Directory Name'));

handles.Cfg.StartingDirName=get(hObject,'String');
handles=CheckCfgParametersBeforeRun(handles);
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function editStartingDirName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editStartingDirName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function editFunctionalSessions_Callback(hObject, eventdata, handles)
uiwait(msgbox({'You need to specify the number of sessions.';...
    'If you have two sections (rest & task), put your rest data into a directory named as FunRaw (or FunImg) for the first session';...
    'put your task data into a directory named as S2_FunRaw (or S2_FunImg) for the second session.';...
    '**************************************************************************';...
    'If you have just one section (rest or task), put your rest or task data into a directory named as FunRaw (or FunImg).';...
    },'Tips for Multiple Functional Sessions'));

handles.Cfg.FunctionalSessionNumber =str2double(get(hObject,'String'));
handles=CheckCfgParameters(handles);
guidata(hObject, handles);
UpdateDisplay(handles);

% --- Executes during object creation, after setting all properties.
function editFunctionalSessions_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editFunctionalSessions (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbuttonSave.
function pushbuttonSave_Callback(hObject, eventdata, handles)
[filename, pathname] = uiputfile({'*.mat'}, 'Save Parameters As');
Cfg=handles.Cfg;
save(['',pathname,filename,''], 'Cfg');

% --- Executes on button press in pushbuttonLoad.
function pushbuttonLoad_Callback(hObject, eventdata, handles)
[filename, pathname] = uigetfile({'*.mat'}, 'Load Parameters From');
load([pathname,filename]);
SetLoadedData(hObject,handles, Cfg);

function SetLoadedData(hObject,handles, Cfg);
handles.Cfg=Cfg;

if ~isfield(handles.Cfg,'TumorProVersion')
    uiwait(msgbox({'The current version doesn''t support the mat files saved in version earlier than TUMOR V1.0.';...
        },'Version Compatibility'));
else
    % YAN Chao-Gan, 130224. Update the DPARSF Version information.
    if str2num(handles.Cfg.TumorProVersion(end-3:end)) ~= str2num(handles.Release(end-3:end))
        uiwait(msgbox({['The mat file is created with TUMOR ',handles.Cfg.TumorProVersion,', and now is succesfully updated to TUMOR ',handles.Release,'.'];...
            },'Version Compatibility'));
        handles.Cfg.TumorProVersion = handles.Release;
    end
end



if ~isfield(handles.Cfg.Covremove.HeadMotionScrubbingRegressors,'FDType')
    handles.Cfg.Covremove.HeadMotionScrubbingRegressors.FDType='FD_Power';
end

if ~isfield(handles.Cfg.Scrubbing,'FDType')
    handles.Cfg.Scrubbing.FDType='FD_Power';
end


if ~isfield(handles.Cfg.CalReHo,'SmoothReHo')
    handles.Cfg.CalReHo.SmoothReHo=0;
end

if ~isfield(handles.Cfg,'IsNormalizeToSymmetricGroupT1Mean')
    handles.Cfg.IsNormalizeToSymmetricGroupT1Mean=0;
end

if ~isfield(handles.Cfg,'IsApplyDownloadedReorientMats')
    handles.Cfg.IsApplyDownloadedReorientMats=0;
end

guidata(hObject, handles);
UpdateDisplay(handles);



% --- Executes on button press in pushbuttonRun.
function pushbuttonRun_Callback(hObject, eventdata, handles)
[handles, CheckingPass]=CheckCfgParametersBeforeRun(handles);
if CheckingPass==0
    return
end

RawBackgroundColor=get(handles.pushbuttonRun ,'BackgroundColor');
RawForegroundColor=get(handles.pushbuttonRun ,'ForegroundColor');
set(handles.pushbuttonRun ,'Enable', 'off','BackgroundColor', 'red','ForegroundColor','green');
Cfg=handles.Cfg; %Added by YAN Chao-Gan, 100130. Save the configuration parameters automatically.
Datetime=fix(clock); %Added by YAN Chao-Gan, 100130.
save([handles.Cfg.DataProcessDir,filesep,'TumorProcessing_AutoSave_',num2str(Datetime(1)),'_',num2str(Datetime(2)),'_',num2str(Datetime(3)),'_',num2str(Datetime(4)),'_',num2str(Datetime(5)),'.mat'], 'Cfg'); %Added by YAN Chao-Gan, 100130.
[Error]=TumorProcessing_main(handles.Cfg);
if ~isempty(Error)
    uiwait(msgbox(Error,'Errors were encountered while processing','error'));
end
set(handles.pushbuttonRun ,'Enable', 'on','BackgroundColor', RawBackgroundColor,'ForegroundColor',RawForegroundColor);
UpdateDisplay(handles);

%% Check if the configuration parameters is correct
function [handles, CheckingPass]=CheckCfgParameters(handles)   %The parameter checking is no longer needed every time
CheckingPass=1;
return


%% Check if the configuration parameters is correct
function [handles, CheckingPass]=CheckCfgParametersBeforeRun(handles)
CheckingPass=0;
if isempty (handles.Cfg.WorkingDir)
    uiwait(msgbox('Please set the working directory!','Configuration parameters checking','warn'));
    return
end

if (handles.Cfg.IsNeedConvertFunDCM2IMG==1)
    handles.Cfg.StartingDirName='FunRaw';
    if 7==exist([handles.Cfg.WorkingDir,filesep,'FunRaw'],'dir')
        if isempty (handles.Cfg.SubjectID)
            Dir=dir([handles.Cfg.WorkingDir,filesep,'FunRaw']);
            if strcmpi(Dir(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            for i=StartIndex:length(Dir)
                handles.Cfg.SubjectID=[handles.Cfg.SubjectID;{Dir(i).name}];
            end
        end
    else
        uiwait(msgbox('Please arrange each subject''s DICOM images in one directory, and then put them in "FunRaw" directory under the working directory!','Configuration parameters checking','warn'));
        return
    end
else
    if 7==exist([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName],'dir')
        if isempty (handles.Cfg.SubjectID)
            Dir=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName]);
            if strcmpi(Dir(3).name,'.DS_Store')  %110908 YAN Chao-Gan, for MAC OS compatablie
                StartIndex=4;
            else
                StartIndex=3;
            end
            for i=StartIndex:length(Dir)
                handles.Cfg.SubjectID=[handles.Cfg.SubjectID;{Dir(i).name}];
            end
        end
        
        if (handles.Cfg.TimePoints)>0 % If the number of time points is not set at 0, then check the number of time points.
            if ~(strcmpi(handles.Cfg.StartingDirName,'T1Raw') || strcmpi(handles.Cfg.StartingDirName,'T1Img') || strcmpi(handles.Cfg.StartingDirName,'T1NiiGZ') ) %If not just use for VBM, check if the time points right. %YAN Chao-Gan, 111130. Also add T1 .nii.gz support.
                DirImg=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,'*.img']);
                if isempty(DirImg)  %YAN Chao-Gan, 111114. Also support .nii files.
                    DirImg=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,'*.nii']);
                    if length(DirImg)>1
                        NTimePoints = length(DirImg);
                    elseif length(DirImg)==1
                        Nii  = nifti([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name]);
                        NTimePoints = size(Nii.dat,4);
                    elseif length(DirImg)==0
                        DirImg=dir([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,'*.nii.gz']);% Search .nii.gz and unzip; YAN Chao-Gan, 120806.
                        if length(DirImg)==1
                            gunzip([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name]);
                            Nii  = nifti([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name(1:end-3)]);
                            delete([handles.Cfg.WorkingDir,filesep,handles.Cfg.StartingDirName,filesep,handles.Cfg.SubjectID{1},filesep,DirImg(1).name(1:end-3)]);
                            NTimePoints = size(Nii.dat,4);
                        else
                            uiwait(msgbox(['Too many .nii.gz files in each subject''s directory, should only keep one 4D .nii.gz file.'],'Configuration parameters checking','warn')); %YAN Chao-Gan 090922, %uiwait(msgbox(['The detected time points of subject "',handles.Cfg.SubjectID{1},'" is: ',num2str(length(DirImg)),', it is different from the predefined time points: ',num2str(handles.Cfg.TimePoints-handles.Cfg.RemoveFirstTimePoints),'. Please check your data!'],'Configuration parameters checking','warn'));
                            return
                        end
                    end
                else
                    NTimePoints = length(DirImg);
                end
                
                if NTimePoints~=(handles.Cfg.TimePoints) %YAN Chao-Gan 090922, %if length(DirImg)~=(handles.Cfg.TimePoints-handles.Cfg.RemoveFirstTimePoints)
                    uiwait(msgbox(['The detected time points of subject "',handles.Cfg.SubjectID{1},'" is: ',num2str(NTimePoints),', it is different from the predefined time points: ',num2str(handles.Cfg.TimePoints),'. Please check your data!'],'Configuration parameters checking','warn')); %YAN Chao-Gan 090922, %uiwait(msgbox(['The detected time points of subject "',handles.Cfg.SubjectID{1},'" is: ',num2str(length(DirImg)),', it is different from the predefined time points: ',num2str(handles.Cfg.TimePoints-handles.Cfg.RemoveFirstTimePoints),'. Please check your data!'],'Configuration parameters checking','warn'));
                    return
                end
            end
        end
    else
        uiwait(msgbox(['Please arrange each subject''s NIFTI images in one directory, and then put them in your defined Starting Directory Name "',handles.Cfg.StartingDirName,'" directory under the working directory!'],'Configuration parameters checking','warn'));
        return
    end
    
end %handles.Cfg.IsNeedConvertFunDCM2IMG


if handles.Cfg.TimePoints==0
    Answer=questdlg('If the Number of Time Points is set to 0, then DPARSFA will not check the number of time points. Do you want to skip the checking of number of time points?','Configuration parameters checking','Yes','No','Yes');
    if ~strcmpi(Answer,'Yes')
        return
    end
end

if handles.Cfg.TR==0
    Answer=questdlg('If TR is set to 0, then DPARSFA will retrieve the TR information from the NIfTI images. Are you sure the TR information in NIfTI images are correct?','Configuration parameters checking','Yes','No','Yes');
    if ~strcmpi(Answer,'Yes')
        return
    end
end

if (handles.Cfg.IsSliceTiming==1) && (handles.Cfg.SliceTiming.SliceNumber==0)
    if ~exist([handles.Cfg.DataProcessDir,filesep,'SliceOrderInfo.tsv'])==2 % YAN Chao-Gan, 130524. Read the slice timing information from a tsv file (Tab-separated values)
        Answer=questdlg('SliceOrderInfo.tsv (under working directory) is not detected. Please go {DPARSF}/Docs/SliceOrderInfo.tsv_Instruction.txt for instructions to allow different slice timing correction for different participants. If SliceNumber is set to 0 while SliceOrderInfo.tsv is not set, the slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!! Are you sure want to continue?','Configuration parameters checking','Yes','No','No');
        if ~strcmpi(Answer,'Yes')
            return
        end
    end
end

CheckingPass=1;
UpdateDisplay(handles);



%% Update All the uiControls' display on the GUI
function UpdateDisplay(handles)
set(handles.edtWorkingDir ,'String', handles.Cfg.WorkingDir);

if size(handles.Cfg.SubjectID,1)>0
    theOldIndex =get(handles.listSubjectID, 'Value');
    set(handles.listSubjectID, 'String',  handles.Cfg.SubjectID , 'Value', 1);
    theCount =size(handles.Cfg.SubjectID,1);
    if (theOldIndex>0) && (theOldIndex<= theCount)
        set(handles.listSubjectID, 'Value', theOldIndex);
    end
else
    set(handles.listSubjectID, 'String', '' , 'Value', 0);
end

set(handles.editTimePoints ,'String', num2str(handles.Cfg.TimePoints));
set(handles.editTR ,'String', num2str(handles.Cfg.TR));




if handles.Cfg.IsSliceTiming==1
    
    set(handles.editSliceNumber, 'Enable', 'on', 'String', num2str(handles.Cfg.SliceTiming.SliceNumber));
    set(handles.editSliceOrder, 'Enable', 'on', 'String', mat2str(handles.Cfg.SliceTiming.SliceOrder));
    set(handles.editReferenceSlice, 'Enable', 'on', 'String', num2str(handles.Cfg.SliceTiming.ReferenceSlice));
    set(handles.textSliceNumber,'Enable', 'on');
    set(handles.textSliceOrder,'Enable', 'on');
    set(handles.textReferenceSlice,'Enable', 'on');
else
    
    set(handles.editSliceNumber, 'Enable', 'off', 'String', num2str(handles.Cfg.SliceTiming.SliceNumber));
    set(handles.editSliceOrder, 'Enable', 'off', 'String', mat2str(handles.Cfg.SliceTiming.SliceOrder));
    set(handles.editReferenceSlice, 'Enable', 'off', 'String', num2str(handles.Cfg.SliceTiming.ReferenceSlice));
    set(handles.textSliceNumber,'Enable', 'off');
    set(handles.textSliceOrder,'Enable', 'off');
    set(handles.textReferenceSlice,'Enable', 'off');
end

% add FWHM on 2016.0217
if handles.Cfg.IsSmooth==1
    set(handles.editFWHM, 'Enable', 'on', 'String', mat2str(handles.Cfg.Smooth.FWHM), 'ForegroundColor', 'k');
    set(handles.textFWHM,'Enable', 'on', 'ForegroundColor', 'k');
else
    set(handles.editFWHM, 'Enable', 'off', 'String', mat2str(handles.Cfg.Smooth.FWHM));
    set(handles.textFWHM,'Enable', 'off');
end


if  handles.Cfg.IsCalFCtotal==1
    
    set(handles.checkbox_FCtotal, 'Value', 1);
    set(handles.checkboxCovremoveAfterNormalizeFiltering, 'Enable', 'on','Value', handles.Cfg.IsCovremove,'ForegroundColor','k');
    set(handles.checkboxCalFC, 'Enable', 'on','Value', handles.Cfg.IsCalFC,'ForegroundColor','k');
else
    set(handles.checkbox_FCtotal, 'Value', 0);
    set(handles.checkboxCovremoveAfterNormalizeFiltering, 'Enable', 'off', 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
    set(handles.checkboxCalFC, 'Enable', 'off', 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
    %set(handles.pushbuttonDefineROI, 'Enable', 'off', 'Value', ~isempty(handles.Cfg.CalFC.ROIDef), 'ForegroundColor', 'k');
end


if handles.Cfg.IsCalFCtotal==1&&handles.Cfg.IsCovremove==1
    
    if strcmpi(handles.Cfg.Covremove.Timing,'AfterNormalizeFiltering')
        
        set(handles.checkboxCovremoveAfterNormalizeFiltering, 'Value', 1, 'ForegroundColor', 'b');
        %set(handles. pushbuttonOtherCovariates, 'Enable', 'on', 'Value', ~isempty(handles.Cfg.Covremove.OtherCovariatesROI), 'ForegroundColor', 'b');
    end
    
else
    
    set(handles.checkboxCovremoveAfterNormalizeFiltering, 'Value', 0);
    % set(handles. pushbuttonOtherCovariates, 'Enable', 'off', 'Value', ~isempty(handles.Cfg.Covremove.OtherCovariatesROI), 'ForegroundColor', 'k');
end



if  handles.Cfg.IsCalFCtotal==1&&handles.Cfg.IsCalFC==1
    
    set(handles.checkboxCalFC, 'Value', 1, 'ForegroundColor', 'b');
    %set(handles.pushbuttonDefineROI, 'Enable', 'on', 'Value', ~isempty(handles.Cfg.CalFC.ROIDef), 'ForegroundColor', 'b');
    
elseif handles.Cfg.IsCalFCtotal==0
    set(handles.checkboxCalFC, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
    %set(handles.pushbuttonDefineROI, 'Enable', 'off', 'Value', ~isempty(handles.Cfg.CalFC.ROIDef), 'ForegroundColor', 'k');
    
end


if  handles.Cfg.IsCalICA==1
    set(handles.checkbox_ICAtotal, 'Value', 1);
    set(handles.checkbox_restICA, 'Enable', 'on', 'Value', handles.Cfg.IsCalrestICA, 'ForegroundColor', 'k');
    set(handles.checkbox_taskICA, 'Enable', 'on', 'Value', handles.Cfg.IsCaltaskICA, 'ForegroundColor', 'k');
    set(handles.checkbox_DICIICA, 'Enable', 'on', 'Value', handles.Cfg.IsCalDICIICA, 'ForegroundColor', 'k');
    set(handles.edit_rest_TNC, 'Enable', 'on', 'String', num2str(handles.Cfg.restICA.TNC));
    set(handles.edit_task_TNC, 'Enable', 'on', 'String', num2str(handles.Cfg.taskICA.TNC));
    set(handles.text_rest_TNC,'Enable', 'on');
    set(handles.text_task_TNC,'Enable', 'on');
    
else
    set(handles.checkbox_ICAtotal, 'Value', 0);
    set(handles.checkbox_restICA, 'Enable', 'off', 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
    set(handles.checkbox_taskICA, 'Enable', 'off', 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
    set(handles.checkbox_DICIICA, 'Enable', 'off',  'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
    set(handles.edit_rest_TNC, 'Enable', 'off', 'String', num2str(handles.Cfg.restICA.TNC));
    set(handles.edit_task_TNC, 'Enable', 'off', 'String', num2str(handles.Cfg.taskICA.TNC));
    set(handles.text_rest_TNC,'Enable', 'off');
    set(handles.text_task_TNC,'Enable', 'off');
    
    %set(handles.pushbuttonDefineROI, 'Enable', 'off', 'Value', ~isempty(handles.Cfg.CalFC.ROIDef), 'ForegroundColor', 'k');
end



if handles.Cfg.IsCalICA==1&&handles.Cfg.IsCalrestICA==1
    set(handles.checkbox_restICA, 'Value', 1, 'ForegroundColor', 'b');
    set(handles.edit_rest_TNC, 'Enable', 'on', 'String', num2str(handles.Cfg.restICA.TNC));
    set(handles.text_rest_TNC,'Enable', 'on');
elseif  handles.Cfg.IsCalrestICA==0
    set(handles.checkbox_restICA, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
    set(handles.edit_rest_TNC, 'Enable', 'off', 'String', num2str(handles.Cfg.restICA.TNC));
    set(handles.text_rest_TNC,'Enable', 'off');
end


if handles.Cfg.IsCalICA==1&&handles.Cfg.IsCaltaskICA==1
    set(handles.checkbox_taskICA, 'Value', 1, 'ForegroundColor', 'b');
    set(handles.edit_task_TNC, 'Enable', 'on', 'String', num2str(handles.Cfg.taskICA.TNC));
    set(handles.text_task_TNC,'Enable', 'on');
elseif handles.Cfg.IsCaltaskICA==0
    set(handles.checkbox_taskICA, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
    set(handles.edit_task_TNC, 'Enable', 'off', 'String', num2str(handles.Cfg.taskICA.TNC));
    set(handles.text_task_TNC,'Enable', 'off');
end


if  handles.Cfg.IsCalICA==1&&handles.Cfg.IsCalDICIICA==1
    set(handles.checkbox_DICIICA, 'Value', 1, 'ForegroundColor', 'b');
elseif  handles.Cfg.IsCalDICIICA==0
    set(handles.checkbox_DICIICA, 'Value', 0, 'ForegroundColor', [0.4,0.4,0.4]);
end



if handles.Cfg.IsCaltaskactivation==1
    set(handles.checkbox_taskactivation, 'Value', 1);
    set(handles.edit_taskname, 'Enable', 'on', 'String', handles.Cfg.taskname);
    set(handles.text_taskname,'Enable', 'on');
    set(handles.radiobutton_task_condition1, 'Enable', 'on');
    set(handles.radiobutton_task_condition2, 'Enable', 'on');
    % add taskconditon on 2016.0415
    if handles.Cfg.taskcondition==1
        set(handles.edit_Onset1, 'Enable', 'on', 'String', mat2str(handles.Cfg.taskactivation.Onset1));
        set(handles.edit_Duration1, 'Enable', 'on', 'String', num2str(handles.Cfg.taskactivation.Duration1));
        set(handles.text_Onset1,'Enable', 'on');
        set(handles.text_Duration1,'Enable', 'on');
        set(handles.edit_Onset2, 'Enable', 'off', 'String', mat2str(handles.Cfg.taskactivation.Onset2));
        set(handles.edit_Duration2, 'Enable', 'off', 'String', num2str(handles.Cfg.taskactivation.Duration2));
        set(handles.text_Onset2,'Enable', 'off');
        set(handles.text_Duration2,'Enable', 'off');
        
    elseif handles.Cfg.taskcondition==2
        set(handles.edit_Onset1, 'Enable', 'on', 'String', mat2str(handles.Cfg.taskactivation.Onset1));
        set(handles.edit_Duration1, 'Enable', 'on', 'String', num2str(handles.Cfg.taskactivation.Duration1));
        set(handles.text_Onset1,'Enable', 'on');
        set(handles.text_Duration1,'Enable', 'on');
        set(handles.edit_Onset2, 'Enable', 'on', 'String', mat2str(handles.Cfg.taskactivation.Onset2));
        set(handles.edit_Duration2, 'Enable', 'on', 'String', num2str(handles.Cfg.taskactivation.Duration2));
        set(handles.text_Onset2,'Enable', 'on');
        set(handles.text_Duration2,'Enable', 'on');
        
    end
else
    set(handles.checkbox_taskactivation, 'Value', 0);
    set(handles.edit_taskname, 'Enable', 'off', 'String',handles.Cfg.taskname);
    set(handles.text_taskname,'Enable', 'off');
    set(handles.radiobutton_task_condition1, 'Enable', 'off');
    set(handles.radiobutton_task_condition2, 'Enable', 'off');
    set(handles.edit_Onset1, 'Enable', 'off', 'String', mat2str(handles.Cfg.taskactivation.Onset1));
    set(handles.edit_Duration1, 'Enable', 'off', 'String', num2str(handles.Cfg.taskactivation.Duration1));
    set(handles.text_Onset1,'Enable', 'off');
    set(handles.text_Duration1,'Enable', 'off');
    set(handles.edit_Onset2, 'Enable', 'off', 'String', mat2str(handles.Cfg.taskactivation.Onset2));
    set(handles.edit_Duration2, 'Enable', 'off', 'String', num2str(handles.Cfg.taskactivation.Duration2));
    set(handles.text_Onset2,'Enable', 'off');
    set(handles.text_Duration2,'Enable', 'off');
    
end



set(handles.editFunctionalSessions ,'String', num2str(handles.Cfg.FunctionalSessionNumber));
set(handles.editStartingDirName ,'String',handles.Cfg.StartingDirName);

drawnow;


% --- Executes during object creation, after setting all properties.
function edit_Onset2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_Onset2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on editTimePoints and none of its controls.
function editTimePoints_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to editTimePoints (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
