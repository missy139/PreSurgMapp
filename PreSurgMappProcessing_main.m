function [Error]=PreSurgMappProcessing_main(AutoDataProcessParameter)
% FORMAT [Error]=PreSurgMappProcessing_main(AutoDataProcessParameter)
% Input:
%   AutoDataProcessParameter - the parameters for auto data processing
% Output:
%   The processed data that you want.
%___________________________________________________________________________
% Toolbox for pipelined processing dedicated to individualized presurgical mapping of eloquent functional areas based on multimodal functional MRI (PreSurgMapp)GUI by Huiyuan Huang.
% Release=V2.0
% Copyright(c) 2014; GNU GENERAL PUBLIC LICENSE
% Written by Huiyuan Huang on Augest-2014
% Zhejiang Key Laboratory for Research in Assessment of Cognitive Impairments,Center for Cognition and Brain Disorder, Hangzhou Normal University, China
% Mail to Author:  <a href="missy139@163.com">Huiyuan Huang
% -----------------------------------------------------------
% Citing Information:
% The processing was carried out by using PreSurgMapp,which is based on SPM8, REST, DPARSFA and MICA.

% Last Modified by Huiyuan Huang on 15-Sep-2016

if ischar(AutoDataProcessParameter)  %If inputed a .mat file name. (Cfg inside)
    load(AutoDataProcessParameter);
    AutoDataProcessParameter=Cfg;
end

[ProgramPath, fileN, extn] = fileparts(which('PreSurgMappProcessing_main.m'));
AutoDataProcessParameter.SubjectNum=length(AutoDataProcessParameter.SubjectID);
Error=[];
addpath([ProgramPath,filesep,'Subfunctions']);

[SPMversion,c]=spm('Ver');
SPMversion=str2double(SPMversion(end));


%Make compatible with missing parameters.
if ~isfield(AutoDataProcessParameter,'DataProcessDir')
    AutoDataProcessParameter.DataProcessDir=AutoDataProcessParameter.WorkingDir;
end

if ~isfield(AutoDataProcessParameter,'FunctionalSessionNumber')
    AutoDataProcessParameter.FunctionalSessionNumber=1;
end
if ~isfield(AutoDataProcessParameter,'IsNeedConvertFunDCM2IMG')
    AutoDataProcessParameter.IsNeedConvertFunDCM2IMG=0;
end
if ~isfield(AutoDataProcessParameter,'IsApplyDownloadedReorientMats')
    AutoDataProcessParameter.IsApplyDownloadedReorientMats=0;
end

if ~isfield(AutoDataProcessParameter,'RemoveFirstTimePoints')
    AutoDataProcessParameter.RemoveFirstTimePoints=0;
end
if ~isfield(AutoDataProcessParameter,'IsSliceTiming')
    AutoDataProcessParameter.IsSliceTiming=0;
end
if ~isfield(AutoDataProcessParameter,'IsRealign')
    AutoDataProcessParameter.IsRealign=0;
end
if ~isfield(AutoDataProcessParameter,'IsCalVoxelSpecificHeadMotion')
    AutoDataProcessParameter.IsCalVoxelSpecificHeadMotion=0;
end
if ~isfield(AutoDataProcessParameter,'IsNeedReorientFunImgInteractively')
    AutoDataProcessParameter.IsNeedReorientFunImgInteractively=0;
end
if ~isfield(AutoDataProcessParameter,'IsNeedConvertT1DCM2IMG')
    AutoDataProcessParameter.IsNeedConvertT1DCM2IMG=0;
end

if ~isfield(AutoDataProcessParameter,'IsNeedReorientCropT1Img')
    AutoDataProcessParameter.IsNeedReorientCropT1Img=0;
end
if ~isfield(AutoDataProcessParameter,'IsNeedReorientT1ImgInteractively')
    AutoDataProcessParameter.IsNeedReorientT1ImgInteractively=0;
end
if ~isfield(AutoDataProcessParameter,'IsNeedT1CoregisterToFun')
    AutoDataProcessParameter.IsNeedT1CoregisterToFun=0;
end
if ~isfield(AutoDataProcessParameter,'IsNeedReorientInteractivelyAfterCoreg')
    AutoDataProcessParameter.IsNeedReorientInteractivelyAfterCoreg=0;
end
if ~isfield(AutoDataProcessParameter,'IsSegment')  %1: Segment; 2: New Segment
    AutoDataProcessParameter.IsSegment=0;
end
if ~isfield(AutoDataProcessParameter,'IsDARTEL')
    AutoDataProcessParameter.IsDARTEL=0;
end
if ~isfield(AutoDataProcessParameter,'IsCovremove')
    AutoDataProcessParameter.IsCovremove=0;
end
if ~isfield(AutoDataProcessParameter,'IsFilter')
    AutoDataProcessParameter.IsFilter=0;
end
if ~isfield(AutoDataProcessParameter,'IsNormalize')  %1: Normalization by using the EPI template directly; 2: Normalization by using the T1 image segment information (T1 images stored in 'DataProcessDir\T1Img' and initiated with 'co*'); 3: Normalized by DARTEL
    AutoDataProcessParameter.IsNormalize=0;
end

if ~isfield(AutoDataProcessParameter,'IsSmooth')  %1: Smooth module in SPM; 2: Smooth by DARTEL
    AutoDataProcessParameter.IsSmooth=0;
end
if ~isfield(AutoDataProcessParameter,'MaskFile')
    AutoDataProcessParameter.MaskFile ='Default';
end
if ~isfield(AutoDataProcessParameter,'IsWarpMasksIntoIndividualSpace')
    AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace=0;
end
if ~isfield(AutoDataProcessParameter,'IsDetrend')
    AutoDataProcessParameter.IsDetrend=0;
end

if ~isfield(AutoDataProcessParameter,'IsCalALFF')
    AutoDataProcessParameter.IsCalALFF=0;
end

if ~isfield(AutoDataProcessParameter,'IsScrubbing')
    AutoDataProcessParameter.IsScrubbing=0;
end
if ~isfield(AutoDataProcessParameter,'IsCalReHo')
    AutoDataProcessParameter.IsCalReHo=0;
else
    if isfield(AutoDataProcessParameter,'CalReHo') && (~isfield(AutoDataProcessParameter.CalReHo,'SmoothReHo')) %YAN Chao-Gan, 121227.
        AutoDataProcessParameter.CalReHo.SmoothReHo=0;
    end
end

if ~isfield(AutoDataProcessParameter,'IsCalDegreeCentrality')
    AutoDataProcessParameter.IsCalDegreeCentrality=0;
end
if ~isfield(AutoDataProcessParameter,'IsCalFC')
    AutoDataProcessParameter.IsCalFC=0;
end
if ~isfield(AutoDataProcessParameter,'CalFC')
    AutoDataProcessParameter.CalFC.ROIDef = {};
elseif ~isfield(AutoDataProcessParameter.CalFC,'ROIDef')
    AutoDataProcessParameter.CalFC.ROIDef = {};
end
if ~isfield(AutoDataProcessParameter,'IsExtractROISignals')
    AutoDataProcessParameter.IsExtractROISignals=0;
end
if ~isfield(AutoDataProcessParameter,'IsDefineROIInteractively')
    AutoDataProcessParameter.IsDefineROIInteractively=0;
end
if ~isfield(AutoDataProcessParameter,'IsExtractAALTC')
    AutoDataProcessParameter.IsExtractAALTC=0;
end
if ~isfield(AutoDataProcessParameter,'IsNormalizeToSymmetricGroupT1Mean')
    AutoDataProcessParameter.IsNormalizeToSymmetricGroupT1Mean=0;
end
if ~isfield(AutoDataProcessParameter,'IsCalVMHC')
    AutoDataProcessParameter.IsCalVMHC=0;
end
if ~isfield(AutoDataProcessParameter,'IsCWAS')
    AutoDataProcessParameter.IsCWAS=0;
end

% HHY 20150506
if ~isfield(AutoDataProcessParameter,'IsCalFCtotal')
    AutoDataProcessParameter.IsCalFCtotal=0;
end
if ~isfield(AutoDataProcessParameter,'IsCalICA')
    AutoDataProcessParameter.IsCalICA=0;
end
if ~isfield(AutoDataProcessParameter,'IsCalrestICA')
    AutoDataProcessParameter.IsCalrestICA=0;
end
if ~isfield(AutoDataProcessParameter,'IsCaltaskICA')
    AutoDataProcessParameter.IsCaltaskICA=0;
end
if ~isfield(AutoDataProcessParameter,'IsCalDICIICA')
    AutoDataProcessParameter.IsCalDICIICA=0;
end
if ~isfield(AutoDataProcessParameter,'IsCaltaskactivation')
    AutoDataProcessParameter.IsCaltaskactivation=0;
end


% Multiple Sessions Processing
FunSessionPrefixSet={''}; %The first session doesn't need a prefix. From the second session, need a prefix such as 'S2_';
for iFunSession=2:AutoDataProcessParameter.FunctionalSessionNumber
    FunSessionPrefixSet=[FunSessionPrefixSet;{['S',num2str(iFunSession),'_']}];
end

%DICOM Sorter


%Convert Functional DICOM files to NIFTI images
if (AutoDataProcessParameter.IsNeedConvertFunDCM2IMG==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw']);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImg',filesep,AutoDataProcessParameter.SubjectID{i}];
            mkdir(OutputDir);
            DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'FunRaw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.*']);
            if strcmpi(DirDCM(3).name,'.DS_Store')
                StartIndex=4;
            else
                StartIndex=3;
            end
            InputFilename=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunRaw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirDCM(StartIndex).name];
            
            
            y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
            
            fprintf(['Converting Functional Images:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName='FunImg';   %Now start with FunImg directory.
end


%Convert T1 DICOM files to NIFTI images
if (AutoDataProcessParameter.IsNeedConvertT1DCM2IMG==1)
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw']);
    parfor i=1:AutoDataProcessParameter.SubjectNum
        OutputDir=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}];
        mkdir(OutputDir);
        DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*']); %Revised by YAN Chao-Gan 100130. %DirDCM=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.*']);
        if strcmpi(DirDCM(3).name,'.DS_Store')  % for MAC OS compatablie
            StartIndex=4;
        else
            StartIndex=3;
        end
        InputFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1Raw',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirDCM(StartIndex).name];
        
        
        y_Call_dcm2nii(InputFilename, OutputDir, 'DefaultINI');
        
        fprintf(['Converting T1 Images:',AutoDataProcessParameter.SubjectID{i},' OK']);
    end
    fprintf('\n');
end


%****************************************************************Processing of fMRI BOLD images*****************
%Check TR and store Subject ID, TR, Slice Number, Time Points, Voxel Size into TRInfo.tsv if needed.
if isfield(AutoDataProcessParameter,'TR')
    if AutoDataProcessParameter.TR==0  % Need to retrieve the TR information from the NIfTI images
        if ~( strcmpi(AutoDataProcessParameter.StartingDirName,'T1Raw') || strcmpi(AutoDataProcessParameter.StartingDirName,'T1Img') )  %Only need for functional processing
            if (2==exist([AutoDataProcessParameter.DataProcessDir,filesep,'TRInfo.tsv'],'file'))  %If the TR information is stored in TRInfo.tsv.
                
                fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'TRInfo.tsv']);
                StringFilter = '%s';
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    StringFilter = [StringFilter,'\t%f']; %Get the TRs for the sessions.
                end
                StringFilter = [StringFilter,'%*[^\n]']; %Skip the else till end of the line
                tline = fgetl(fid); %Skip the title line
                TRInfoTemp = textscan(fid,StringFilter);
                fclose(fid);
                
                for i=1:AutoDataProcessParameter.SubjectNum
                    if ~strcmp(AutoDataProcessParameter.SubjectID{i},TRInfoTemp{1}{i})
                        error(['The subject ID ',TRInfoTemp{1}{i},' in TRInfo.tsv doesn''t match the target sbuject ID: ',AutoDataProcessParameter.SubjectID{i},'!'])
                    end
                end
                
                TRSet = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber);
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    TRSet(:,iFunSession) = TRInfoTemp{1+iFunSession}; %The first column is Subject ID
                end
                
            elseif (2==exist([AutoDataProcessParameter.DataProcessDir,filesep,'TRSet.txt'],'file'))  %If the TR information is stored in TRSet.txt (DPARSF V2.2).
                TRSet = load([AutoDataProcessParameter.DataProcessDir,filesep,'TRSet.txt']);
                TRSet = TRSet';% This is for the compatibility with DPARSFA V2.2. Cause the TRSet saved there is in a transpose manner.
            else
                
                TRSet = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber);
                SliceNumber = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber);
                nTimePoints = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber);
                VoxelSize = zeros(AutoDataProcessParameter.SubjectNum,AutoDataProcessParameter.FunctionalSessionNumber,3);
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    parfor i=1:AutoDataProcessParameter.SubjectNum
                        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                        DirImg=dir('*.img');
                        if isempty(DirImg)  % Also support .nii files. % Either in .nii.gz or in .nii
                            DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                            if length(DirImg)==1
                                gunzip(DirImg(1).name);
                                delete(DirImg(1).name);
                            end
                            DirImg=dir('*.nii');
                        end
                        Nii  = nifti(DirImg(1).name);
                        if (~isfield(Nii.timing,'tspace'))
                            error('Can NOT retrieve the TR information from the NIfTI images');
                        end
                        TRSet(i,iFunSession) = Nii.timing.tspace;
                        
                        SliceNumber(i,iFunSession) = size(Nii.dat,3);
                        
                        if size(Nii.dat,4)==1 %Test if 3D volume
                            nTimePoints(i,iFunSession) = length(DirImg);
                        else %4D volume
                            nTimePoints(i,iFunSession) = size(Nii.dat,4);
                        end
                        
                        VoxelSize(i,iFunSession,:) = sqrt(sum(Nii.mat(1:3,1:3).^2));
                    end
                end
                %save([AutoDataProcessParameter.DataProcessDir,filesep,'TRSet.txt'], 'TRSet', '-ASCII', '-DOUBLE','-TABS'); % Save the TR information.
                
                % No longer save to TRSet.txt, but save to TRInfo.tsv with information of Slice Number, Time Points, Voxel Size.
                
                
                %Write the information as TRInfo.tsv
                fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'TRInfo.tsv'],'w');
                
                fprintf(fid,'Subject ID');
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'TR']);
                end
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Slice Number']);
                end
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Time Points']);
                end
                for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                    fprintf(fid,['\t',FunSessionPrefixSet{iFunSession},'Voxel Size']);
                end
                
                fprintf(fid,'\n');
                for i=1:AutoDataProcessParameter.SubjectNum
                    fprintf(fid,'%s',AutoDataProcessParameter.SubjectID{i});
                    
                    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                        fprintf(fid,'\t%g',TRSet(i,iFunSession));
                    end
                    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                        fprintf(fid,'\t%g',SliceNumber(i,iFunSession));
                    end
                    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                        fprintf(fid,'\t%g',nTimePoints(i,iFunSession));
                    end
                    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                        fprintf(fid,'\t%g %g %g',VoxelSize(i,iFunSession,1),VoxelSize(i,iFunSession,2),VoxelSize(i,iFunSession,3));
                    end
                    fprintf(fid,'\n');
                end
                
                fclose(fid);
                
            end
            AutoDataProcessParameter.TRSet = TRSet;
        end
    end
end


%Remove First Time Points
if (AutoDataProcessParameter.RemoveFirstTimePoints>0)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName]);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if ~isempty(DirImg)  % Also support .nii files.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                    Error=[Error;{['Error in Removing First ',num2str(AutoDataProcessParameter.RemoveFirstTimePoints),'Time Points: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                for j=1:AutoDataProcessParameter.RemoveFirstTimePoints
                    delete(DirImg(j).name);
                    delete([DirImg(j).name(1:end-4),'.hdr']);
                end
            else % either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                
                DirImg=dir('*.nii');
                
                if length(DirImg)>1  %3D .nii images.
                    if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                        Error=[Error;{['Error in Removing First ',num2str(AutoDataProcessParameter.RemoveFirstTimePoints),'Time Points: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    for j=1:AutoDataProcessParameter.RemoveFirstTimePoints
                        delete(DirImg(j).name);
                    end
                else %4D .nii images
                    Nii  = nifti(DirImg(1).name);
                    if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                        Error=[Error;{['Error in Removing First ',num2str(AutoDataProcessParameter.RemoveFirstTimePoints),'Time Points: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    y_Write4DNIfTI(Nii.dat(:,:,:,AutoDataProcessParameter.RemoveFirstTimePoints+1:end),Nii,DirImg(1).name);
                end
                
            end
            cd('..');
            fprintf(['Removing First ',num2str(AutoDataProcessParameter.RemoveFirstTimePoints),' Time Points: ',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.TimePoints=AutoDataProcessParameter.TimePoints-AutoDataProcessParameter.RemoveFirstTimePoints;
end
if ~isempty(Error)
    disp(Error);
    return;
end



%Slice Timing
if (AutoDataProcessParameter.IsSliceTiming==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        
        parfor i=1:AutoDataProcessParameter.SubjectNum
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'SliceTiming.mat']);
            
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            
            if isempty(DirImg)  % Also support .nii files. % Either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                    Error=[Error;{['Error in Slice Timing, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[];
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                end
            else %4D .nii images
                Nii  = nifti(DirImg(1).name);
                if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                    Error=[Error;{['Error in Slice Timing, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[];
                for j=1:size(Nii.dat,4)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name,',',num2str(j)]}];
                end
            end
            
            
            SPMJOB.jobs{1,1}.temporal{1,1}.st.scans{1}=FileList;
            
            
            if AutoDataProcessParameter.SliceTiming.SliceNumber==0 %If SliceNumber is set to 0, then retrieve the slice number from the NIfTI images. The slice order is then assumed as interleaved scanning: [1:2:SliceNumber,2:2:SliceNumber]. The reference slice is set to the slice acquired at the middle time point, i.e., SliceOrder(ceil(SliceNumber/2)). SHOULD BE EXTREMELY CAUTIOUS!!!
                
                Nii=nifti(FileList{1});
                SliceNumber = size(Nii.dat,3);
                SPMJOB.jobs{1,1}.temporal{1,1}.st.nslices = SliceNumber;
                
                if exist([AutoDataProcessParameter.DataProcessDir,filesep,'SliceOrderInfo.tsv'])==2 % Read the slice timing information from a tsv file (Tab-separated values)
                    
                    fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'SliceOrderInfo.tsv']);
                    StringFilter = '%s';
                    for iFunSessionTemp=1:AutoDataProcessParameter.FunctionalSessionNumber
                        StringFilter = [StringFilter,'\t%s']; %Get the Slice Order Type for the sessions.
                    end
                    tline = fgetl(fid); %Skip the title line
                    SliceOrderSet = textscan(fid,StringFilter,'\n');
                    fclose(fid);
                    
                    if ~strcmp(AutoDataProcessParameter.SubjectID{i},SliceOrderSet{1}{i})
                        error(['The subject ID ',SliceOrderSet{1}{i},' in SliceOrderInfo.tsv doesn''t match the target sbuject ID: ',AutoDataProcessParameter.SubjectID{i},'!'])
                    end
                    
                    switch SliceOrderSet{1+iFunSession}{i}
                        case {'IA'} %Interleaved Ascending
                            SliceOrder = [1:2:SliceNumber,2:2:SliceNumber];
                        case {'IA2'} %Interleaved Ascending for SIEMENS scanner if the slice number in an even number
                            SliceOrder = [2:2:SliceNumber,1:2:SliceNumber];
                        case {'ID'} %Interleaved Descending
                            SliceOrder = [SliceNumber:-2:1,SliceNumber-1:-2:1];
                        case {'ID2'} %Interleaved Descending for SIEMENS scanner if the slice number in an even number
                            SliceOrder = [SliceNumber-1:-2:1,SliceNumber:-2:1];
                        case {'SA'} %Sequential Ascending
                            SliceOrder = [1:SliceNumber];
                        case {'SD'} %Sequential Descending
                            SliceOrder = [SliceNumber:-1:1];
                            
                        otherwise
                            error(['The specified slice order definition ',SliceOrderSet{2}{i},' for subject ',AutoDataProcessParameter.SubjectID{i},' is not supported!'])
                    end;
                    
                    SPMJOB.jobs{1,1}.temporal{1,1}.st.so = SliceOrder;
                    
                else
                    SPMJOB.jobs{1,1}.temporal{1,1}.st.so = [1:2:SliceNumber,2:2:SliceNumber];
                end
                SPMJOB.jobs{1,1}.temporal{1,1}.st.refslice = SPMJOB.jobs{1,1}.temporal{1,1}.st.so(ceil(SliceNumber/2));
                
            else
                SliceNumber = AutoDataProcessParameter.SliceTiming.SliceNumber;
                SPMJOB.jobs{1,1}.temporal{1,1}.st.nslices = SliceNumber;
                SPMJOB.jobs{1,1}.temporal{1,1}.st.so = AutoDataProcessParameter.SliceTiming.SliceOrder;
                SPMJOB.jobs{1,1}.temporal{1,1}.st.refslice = AutoDataProcessParameter.SliceTiming.ReferenceSlice;
            end
            
            if AutoDataProcessParameter.TR==0  %If TR is set to 0, then Need to retrieve the TR information from the NIfTI images
                SPMJOB.jobs{1,1}.temporal{1,1}.st.tr = AutoDataProcessParameter.TRSet(i,iFunSession);
                SPMJOB.jobs{1,1}.temporal{1,1}.st.ta = AutoDataProcessParameter.TRSet(i,iFunSession) - (AutoDataProcessParameter.TRSet(i,iFunSession)/SliceNumber);
            else
                SPMJOB.jobs{1,1}.temporal{1,1}.st.tr = AutoDataProcessParameter.TR;
                SPMJOB.jobs{1,1}.temporal{1,1}.st.ta = AutoDataProcessParameter.TR - (AutoDataProcessParameter.TR/SliceNumber);
            end
            
            
            fprintf(['Slice Timing Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
            if SPMversion==5
                spm_jobman('run',SPMJOB.jobs);
            elseif SPMversion==8  % SPM8 compatible.
                SPMJOB.jobs = spm_jobman('spm5tospm8',{SPMJOB.jobs});
                spm_jobman('run',SPMJOB.jobs{1});
            else
                uiwait(msgbox('The current SPM version is not supported by DPARSF. Please install SPM5 or SPM8 first.','Invalid SPM Version.'));
                Error=[Error;{['Error in Slice Timing: The current SPM version is not supported by DPARSF. Please install SPM5 or SPM8 first.']}];
            end
        end
        
        %Copy the Slice Timing Corrected files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+A
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'A',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'a*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'A',filesep,AutoDataProcessParameter.SubjectID{i}])
            fprintf(['Moving Slice Timing Corrected Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
        
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'A']; %Now StartingDirName is with new suffix 'A'
end
if ~isempty(Error)
    disp(Error);
    return;
end


%Realign
if (AutoDataProcessParameter.IsRealign==1)
    parfor i=1:AutoDataProcessParameter.SubjectNum
        SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Realign.mat']);
        
        for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            
            
            if isempty(DirImg)  % Also support .nii files. % Either in .nii.gz or in .nii
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                    Error=[Error;{['Error in Realign, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[];
                for j=1:length(DirImg)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                end
            else %4D .nii images
                Nii  = nifti(DirImg(1).name);
                if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                    Error=[Error;{['Error in Realign, time point number doesn''t match: ',AutoDataProcessParameter.SubjectID{i}]}];
                end
                FileList=[];
                for j=1:size(Nii.dat,4)
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name,',',num2str(j)]}];
                end
            end
            
            
            SPMJOB.jobs{1,1}.spatial{1,1}.realign{1,1}.estwrite.data{1,iFunSession}=FileList;
        end
        
        fprintf(['Realign Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        if SPMversion==5
            spm_jobman('run',SPMJOB.jobs);
        elseif SPMversion==8  % SPM8 compatible.
            SPMJOB.jobs = spm_jobman('spm5tospm8',{SPMJOB.jobs});
            spm_jobman('run',SPMJOB.jobs{1});
        else
            uiwait(msgbox('The current SPM version is not supported by PreSurgMapp. Please install SPM5 or SPM8 first.','Invalid SPM Version.'));   % revised by HHY, 20160914
            Error=[Error;{['Error in Realign: The current SPM version is not supported by PreSurgMapp. Please install SPM5 or SPM8 first.']}];
        end
    end
    
    %Copy the Realign Parameters
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    if ~isempty(dir('*.ps'))
        copyfile('*.ps',[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    end
    parfor i=1:AutoDataProcessParameter.SubjectNum
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{1},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
        movefile('mean*',[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
        movefile('rp*.txt',[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
        for iFunSession=2:AutoDataProcessParameter.FunctionalSessionNumber
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirRP=dir('rp*.txt');
            [PathTemp, fileN, extn] = fileparts(DirRP.name);
            copyfile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name],[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},fileN, extn]);
        end
    end
    
    %Copy the Head Motion Corrected files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+R
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName]);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            mkdir(['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
            DirImg=dir('*.img');
            if ~isempty(DirImg)
                movefile('r*.img',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
                movefile('r*.hdr',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
            else
                movefile('r*.nii',['..',filesep,'..',filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'R',filesep,AutoDataProcessParameter.SubjectID{i}])
            end
            cd('..');
            fprintf(['Moving Head Motion Corrected Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
    end
    fprintf('\n');
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'R']; %Now StartingDirName is with new suffix 'R'
    
    %Check Head Motion
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        
        HeadMotion = zeros(AutoDataProcessParameter.SubjectNum,20);
        % max(abs(Tx)), max(abs(Ty)), max(abs(Tz)), max(abs(Rx)), max(abs(Ry)), max(abs(Rz)),
        % mean(abs(Tx)), mean(abs(Ty)), mean(abs(Tz)), mean(abs(Rx)), mean(abs(Ry)), mean(abs(Rz)),
        % mean RMS, mean relative RMS (mean FD_VanDijk),
        % mean FD_Power, Number of FD_Power>0.5, Percent of FD_Power>0.5, Number of FD_Power>0.2, Percent of FD_Power>0.2
        % mean FD_Jenkinson (FSL's relative RMS)
        
        for i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
            
            rpname=dir([FunSessionPrefixSet{iFunSession},'rp*']);
            
            RP=load(rpname.name);
            
            MaxRP = max(abs(RP));
            MaxRP(4:6) = MaxRP(4:6)*180/pi;
            
            MeanRP = mean(abs(RP));
            MeanRP(4:6) = MeanRP(4:6)*180/pi;
            
            %Calculate FD Van Dijk (Van Dijk, K.R., Sabuncu, M.R., Buckner, R.L., 2012. The influence of head motion on intrinsic functional connectivity MRI. Neuroimage 59, 431-438.)
            RPRMS = sqrt(sum(RP(:,1:3).^2,2));
            MeanRMS = mean(RPRMS);
            
            FD_VanDijk = abs(diff(RPRMS));
            FD_VanDijk = [0;FD_VanDijk];
            save([FunSessionPrefixSet{iFunSession},'FD_VanDijk_',AutoDataProcessParameter.SubjectID{i},'.txt'], 'FD_VanDijk', '-ASCII', '-DOUBLE','-TABS');
            MeanFD_VanDijk = mean(FD_VanDijk);
            
            %Calculate FD Power (Power, J.D., Barnes, K.A., Snyder, A.Z., Schlaggar, B.L., Petersen, S.E., 2012. Spurious but systematic correlations in functional connectivity MRI networks arise from subject motion. Neuroimage 59, 2142-2154.)
            RPDiff=diff(RP);
            RPDiff=[zeros(1,6);RPDiff];
            RPDiffSphere=RPDiff;
            RPDiffSphere(:,4:6)=RPDiffSphere(:,4:6)*50;
            FD_Power=sum(abs(RPDiffSphere),2);
            save([FunSessionPrefixSet{iFunSession},'FD_Power_',AutoDataProcessParameter.SubjectID{i},'.txt'], 'FD_Power', '-ASCII', '-DOUBLE','-TABS');
            MeanFD_Power = mean(FD_Power);
            
            NumberFD_Power_05 = length(find(FD_Power>0.5));
            PercentFD_Power_05 = length(find(FD_Power>0.5)) / length(FD_Power);
            NumberFD_Power_02 = length(find(FD_Power>0.2));
            PercentFD_Power_02 = length(find(FD_Power>0.2)) / length(FD_Power);
            
            %Calculate FD Jenkinson (FSL's relative RMS) (Jenkinson, M., Bannister, P., Brady, M., Smith, S., 2002. Improved optimization for the robust and accurate linear registration and motion correction of brain images. Neuroimage 17, 825-841. Jenkinson, M. 1999. Measuring transformation error by RMS deviation. Internal Technical Report TR99MJ1, FMRIB Centre, University of Oxford. Available at www.fmrib.ox.ac.uk/analysis/techrep for downloading.)
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  % Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            if ~isempty(DirMean)
                RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
            end
            
            FD_Jenkinson = y_FD_Jenkinson(rpname.name,RefFile);
            save([FunSessionPrefixSet{iFunSession},'FD_Jenkinson_',AutoDataProcessParameter.SubjectID{i},'.txt'], 'FD_Jenkinson', '-ASCII', '-DOUBLE','-TABS');
            MeanFD_Jenkinson = mean(FD_Jenkinson);
            
            
            HeadMotion(i,:) = [MaxRP,MeanRP,MeanRMS,MeanFD_VanDijk,MeanFD_Power,NumberFD_Power_05,PercentFD_Power_05,NumberFD_Power_02,PercentFD_Power_02,MeanFD_Jenkinson];
            
        end
        save([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,FunSessionPrefixSet{iFunSession},'HeadMotion.mat'],'HeadMotion');
        
        %Write the Head Motion as .tsv
        fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,FunSessionPrefixSet{iFunSession},'HeadMotion.tsv'],'w');
        fprintf(fid,'Subject ID\tmax(abs(Tx))\tmax(abs(Ty))\tmax(abs(Tz))\tmax(abs(Rx))\tmax(abs(Ry))\tmax(abs(Rz))\tmean(abs(Tx))\tmean(abs(Ty))\tmean(abs(Tz))\tmean(abs(Rx))\tmean(abs(Ry))\tmean(abs(Rz))\tmean RMS\tmean relative RMS (mean FD_VanDijk)\tmean FD_Power\tNumber of FD_Power>0.5\tPercent of FD_Power>0.5\tNumber of FD_Power>0.2\tPercent of FD_Power>0.2\tmean FD_Jenkinson\n');
        for i=1:AutoDataProcessParameter.SubjectNum
            fprintf(fid,'%s\t',AutoDataProcessParameter.SubjectID{i});
            fprintf(fid,'%e\t',HeadMotion(i,:));
            fprintf(fid,'\n');
        end
        fclose(fid);
        
        
        ExcludeSub_Text=[];
        for ExcludingCriteria=3:-0.5:0.5
            BigHeadMotion=find(HeadMotion(:,1:6)>ExcludingCriteria);
            if ~isempty(BigHeadMotion)
                [II JJ]=ind2sub([AutoDataProcessParameter.SubjectNum,6],BigHeadMotion);
                ExcludeSub=unique(II);
                ExcludeSub_ID=AutoDataProcessParameter.SubjectID(ExcludeSub);
                TempText='';
                for iExcludeSub=1:length(ExcludeSub_ID)
                    TempText=sprintf('%s%s\n',TempText,ExcludeSub_ID{iExcludeSub});
                end
            else
                TempText='None';
            end
            ExcludeSub_Text=sprintf('%s\nExcluding Criteria: %2.1fmm and %2.1f degree in max head motion\n%s\n\n\n',ExcludeSub_Text,ExcludingCriteria,ExcludingCriteria,TempText);
        end
        fid = fopen([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,FunSessionPrefixSet{iFunSession},'ExcludeSubjectsAccordingToMaxHeadMotion.txt'],'at+');
        fprintf(fid,'%s',ExcludeSub_Text);
        fclose(fid);
    end
    
end
if ~isempty(Error)
    disp(Error);
    return;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Coregister T1 Image to Functional space
if (AutoDataProcessParameter.IsNeedT1CoregisterToFun==1)
    %Backup the T1 images to T1ImgCoreg
    % Check if co* image exist.
    cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
    DirCo=dir('c*.img');
    if isempty(DirCo)
        DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip;
        if length(DirCo)==1
            gunzip(DirCo(1).name);
            delete(DirCo(1).name);
        end
        DirCo=dir('c*.nii');  % Also support .nii files.
    end
    if isempty(DirCo)
        DirImg=dir('*.img');
        if isempty(DirImg)  % Also support .nii files.
            DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
            if length(DirImg)>=1
                for j=1:length(DirImg)
                    gunzip(DirImg(j).name);
                    delete(DirImg(j).name);
                end
            end
            DirImg=dir('*.nii');
        end
        if length(DirImg)==1
            button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
            if strcmpi(button,'Yes')
                UseNoCoT1Image=1;
            else
                return;
            end
        elseif length(DirImg)==0
            errordlg(['No T1 image has been found.'],'No T1 image has been found');
            return;
        else
            errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
            return;
        end
    else
        UseNoCoT1Image=0;
    end
    
    parfor i=1:AutoDataProcessParameter.SubjectNum
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}]);
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
        % Check in co* image exist.
        if UseNoCoT1Image==0
            DirImg=dir('c*.img');
            if ~isempty(DirImg)
                copyfile('c*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
                copyfile('c*.img',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
            else
                DirImg=dir('c*.nii.gz');  % Search .nii.gz and unzip;
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                copyfile('c*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
            end
        else
            DirImg=dir('*.img');
            if ~isempty(DirImg)
                copyfile('*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
                copyfile('*.img',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
            else
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                copyfile('*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}])
            end
        end
        fprintf(['Copying T1 image Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
    end
    fprintf('\n');
    
    % Check if mean* image generated in Head Motion Correction exist.
    if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1}],'dir')
        DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.img']);
        if isempty(DirMean)  % Also support .nii files.
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip;
            if length(DirMean)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirMean(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirMean(1).name]);
            end
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'mean*.nii']);
        end
    else
        DirMean=[];
    end
    if isempty(DirMean)
        % Generate mean image. ONLY FOR situation with ONE SESSION.
        cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
        for i=1:AutoDataProcessParameter.SubjectNum
            fprintf('\nCalculate mean functional brain (%s) for "%s" since there is no mean* image generated in Head Motion Correction exist.\n',AutoDataProcessParameter.StartingDirName, AutoDataProcessParameter.SubjectID{i});
            cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
            DirImg=dir('*.img');
            if isempty(DirImg)  % Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                if length(DirImg)==1
                    gunzip(DirImg(1).name);
                    delete(DirImg(1).name);
                end
                DirImg=dir('*.nii');
            end
            
            if length(DirImg)>1  %3D .img or .nii images.
                [Data, Header] = rest_ReadNiftiImage(DirImg(1).name);
                AllVolume =repmat(Data, [1,1,1, length(DirImg)]);
                for j=2:length(DirImg)
                    [Data, Header] = rest_ReadNiftiImage(DirImg(j).name);
                    AllVolume(:,:,:,j) = Data;
                    if ~mod(j,5)
                        fprintf('.');
                    end
                end
            else %4D .nii images
                [AllVolume, Header] = rest_ReadNiftiImage(DirImg(1).name);
            end
            
            AllVolume=mean(AllVolume,4);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}]);
            Header.pinfo = [1;0;0];
            Header.dt    =[16,0];
            rest_WriteNiftiImage(AllVolume,Header,[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',AutoDataProcessParameter.SubjectID{i},'img']);
            fprintf('\nMean functional brain (%s) for "%s" saved as: %s\n',AutoDataProcessParameter.StartingDirName, AutoDataProcessParameter.SubjectID{i}, [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean',AutoDataProcessParameter.SubjectID{i},'img']);
            cd('..');
        end
    end
    
    
    parfor i=1:AutoDataProcessParameter.SubjectNum
        SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Coregister.mat']);
        
        RefDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
        if isempty(RefDir)  % Also support .nii files.
            RefDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
        end
        RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,RefDir(1).name,',1'];
        SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(SourceDir)  % Also support .nii files.
            SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name];
        
        SPMJOB.jobs{1,1}.spatial{1,1}.coreg{1,1}.estimate.ref={RefFile};
        SPMJOB.jobs{1,1}.spatial{1,1}.coreg{1,1}.estimate.source={SourceFile};
        fprintf(['Coregister Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        if SPMversion==5
            spm_jobman('run',SPMJOB.jobs);
        elseif SPMversion==8  % SPM8 compatible.
            SPMJOB.jobs = spm_jobman('spm5tospm8',{SPMJOB.jobs});
            spm_jobman('run',SPMJOB.jobs{1});
        else
            uiwait(msgbox('The current SPM version is not supported by DPARSF. Please install SPM5 or SPM8 first.','Invalid SPM Version.'));
            Error=[Error;{['Error in Coregister T1 Image to Functional space: The current SPM version is not supported by DPARSF. Please install SPM5 or SPM8 first.']}];
        end
    end
end


%% Deal with the other covariables mask: warp into original space
if (AutoDataProcessParameter.IsCovremove==1) && ((strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterRealign'))||(AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1))
    
    if ~isempty(AutoDataProcessParameter.Covremove.OtherCovariatesROI)
        
        if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks'],'dir'))
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks']);
        end
        
        % Check if masks appropriate %This can be used as a function!!! % ONLY WARP!!!
        OtherCovariatesROIForEachSubject=cell(AutoDataProcessParameter.SubjectNum,1);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            Suffix='OtherCovariateROI_'; %%!!! Change as in Function
            SubjectROI=AutoDataProcessParameter.Covremove.OtherCovariatesROI;%%!!! Change as in Fuction
            
            % Set the reference image
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  % Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip;
                if length(DirMean)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                end
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            RefFile = [AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name];
            
            % Ball to mask
            for iROI=1:length(SubjectROI)
                if rest_SphereROI( 'IsBallDefinition', SubjectROI{iROI})
                    ROIMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                    [MNIData MNIVox MNIHeader]=rest_readfile([ProgramPath,filesep,'Templates',filesep,'aal.nii']);
                    rest_Y_SphereROI( 'BallDefinition2Mask' , SubjectROI{iROI}, size(MNIData), MNIVox, MNIHeader, ROIMaskName);
                    SubjectROI{iROI}=[ROIMaskName];
                end
            end
            
            %Need to warp masks
            % Check if have .txt file. Note: the txt files should be put the last of the ROI definition
            NeedWarpMaskNameSet=[];
            WarpedMaskNameSet=[];
            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        NeedWarpMaskNameSet=[NeedWarpMaskNameSet;{SubjectROI{iROI}}];
                        WarpedMaskNameSet=[WarpedMaskNameSet;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii']}];
                        
                        SubjectROI{iROI}=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                    end
                end
            end
            
            if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
                % If is processed by New Segment and DARTEL
                
                TemplateDir_SubID=AutoDataProcessParameter.SubjectID{1};
                
                DARTELTemplateFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii'];
                DARTELTemplateMatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6_2mni.mat'];
                
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
                FlowFieldFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                
                
                y_WarpBackByDARTEL(NeedWarpMaskNameSet,WarpedMaskNameSet,RefFile,DARTELTemplateFilename,DARTELTemplateMatFilename,FlowFieldFilename,0);
                
                for iROI=1:length(NeedWarpMaskNameSet)
                    fprintf('\nWarp %s Mask (%s) for "%s" to individual space using DARTEL flow field (in T1ImgNewSegment) genereated by DARTEL.\n',Suffix,NeedWarpMaskNameSet{iROI}, AutoDataProcessParameter.SubjectID{i});
                end
                
            elseif (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
                % If is processed by unified segmentation
                
                MatFileDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*seg_inv_sn.mat']);
                MatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,MatFileDir(1).name];
                
                for iROI=1:length(NeedWarpMaskNameSet)
                    y_NormalizeWrite(NeedWarpMaskNameSet{iROI},WarpedMaskNameSet{iROI},RefFile,MatFilename,0);
                    fprintf('\nWarp %s Mask (%s) for "%s" to individual space using *seg_inv_sn.mat (in T1ImgSegment) genereated by T1 image segmentation.\n',Suffix,NeedWarpMaskNameSet{iROI}, AutoDataProcessParameter.SubjectID{i});
                end
                
            end
            
            
            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Covariables_List:', then get the corresponded covariables file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s','\n');
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Covariables_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
                
            end
            
            OtherCovariatesROIForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
            
        end
        
        AutoDataProcessParameter.Covremove.OtherCovariatesROIForEachSubject = OtherCovariatesROIForEachSubject;
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Reorient Interactively After Coregistration for better orientation in Segmentation      Added by HHY 20150603
%Do not need parfor

if (AutoDataProcessParameter.IsNeedReorientInteractivelyAfterCoreg==1)
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats']);
    end
    %Reorient
    cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    for i=1:AutoDataProcessParameter.SubjectNum
        FileList=[];
        
        DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(DirT1ImgCoreg)  % Also support .nii files.
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
            if length(DirT1ImgCoreg)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
            end
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name,',1']}];
        
        % if the mean* functional image exist, then also reorient it.
        if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i}],'dir')
            DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.img']);
            if isempty(DirMean)  % Also support .nii files.
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii.gz']);% Search .nii.gz and unzip;
                if length(DirMean)==1
                    gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                    delete([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name]);
                end
                DirMean=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
            end
            if ~isempty(DirMean)
                FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirMean(1).name,',1']}];
            end
        end
        
        fprintf('Reorienting Interactively After Coregistration for %s: \n',AutoDataProcessParameter.SubjectID{i});
        global DPARSFA_spm_image_Parameters
        DPARSFA_spm_image_Parameters.ReorientFileList=FileList;
        uiwait(DPARSFA_spm_image('init',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name]));
        mat=DPARSFA_spm_image_Parameters.ReorientMat;
        save([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1FunAfterCoregMat.mat'],'mat')
        clear global DPARSFA_spm_image_Parameters
        fprintf('Reorienting Interactively After Coregistration for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
        cd('..');
    end
    
    % Apply Reorient Mats (after T1-Fun coregistration) to functional images and/or the voxel-specific head motion files
    parfor i=1:AutoDataProcessParameter.SubjectNum
        % In case there exist reorient matrix (interactive reorient after T1-Fun coregistration)
        ReorientMat=eye(4);
        if exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats'])==7
            if exist([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1FunAfterCoregMat.mat'])==2
                ReorientMat_Interactively = load([AutoDataProcessParameter.DataProcessDir,filesep,'ReorientMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ReorientT1FunAfterCoregMat.mat']);
                ReorientMat=ReorientMat_Interactively.mat*ReorientMat;
            end
        end
        
        if ~all(all(ReorientMat==eye(4)))
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                %Apply to the functional images
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                DirImg=dir('*.img');
                if isempty(DirImg)  % Also support .nii files.
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('*.nii');
                end
                
                for j=1:length(DirImg)
                    OldMat = spm_get_space(DirImg(j).name);
                    spm_get_space(DirImg(j).name,ReorientMat*OldMat);
                end
                if length(DirImg)==1 % delete the .mat file generated by spm_get_space for 4D nii images
                    if exist([DirImg(j).name(1:end-4),'.mat'])==2
                        delete([DirImg(j).name(1:end-4),'.mat']);
                    end
                end
                
                %Apply to voxel-specific head motion files
                if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}],'dir'))
                    cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}]);
                    DirImg=dir('*.nii');
                    
                    for j=1:length(DirImg)
                        OldMat = spm_get_space(DirImg(j).name);
                        spm_get_space(DirImg(j).name,ReorientMat*OldMat);
                        if exist([DirImg(j).name(1:end-4),'.mat'])==2
                            delete([DirImg(j).name(1:end-4),'.mat']);
                        end
                    end
                end
                FileNameTemp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanTDvox',filesep,'MeanTDvox_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                if exist(FileNameTemp)==2
                    OldMat = spm_get_space(FileNameTemp);
                    spm_get_space(FileNameTemp,ReorientMat*OldMat);
                end
                FileNameTemp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'MeanVoxelSpecificHeadMotion_MeanFDvox',filesep,'MeanFDvox_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                if exist(FileNameTemp)==2
                    OldMat = spm_get_space(FileNameTemp);
                    spm_get_space(FileNameTemp,ReorientMat*OldMat);
                end
                
            end
        end
        
        fprintf('Apply Reorient Mats (after T1-Fun coregistration) to functional images for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
    end
    
end
if ~isempty(Error)
    disp(Error);
    return;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Smooth on functional data
if (AutoDataProcessParameter.IsSmooth>=1) && strcmpi(AutoDataProcessParameter.Smooth.Timing,'OnFunctionalData')
    if (AutoDataProcessParameter.IsSmooth==1)
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            FileList=[];
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}]);
                DirImg=dir('*.img');
                if isempty(DirImg)  % Also support .nii files. % Either in .nii.gz or in .nii
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('*.nii');
                end
                
                if length(DirImg)>1  %3D .img or .nii images.
                    if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                        Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    for j=1:length(DirImg)
                        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                    end
                else %4D .nii images
                    Nii  = nifti(DirImg(1).name);
                    if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                        Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
                    
                    
                end
            end
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Smooth.mat']);
            SPMJOB.jobs{1,1}.spatial{1,1}.smooth.data = FileList;
            SPMJOB.jobs{1,1}.spatial{1,1}.smooth.fwhm = AutoDataProcessParameter.Smooth.FWHM;
            if SPMversion==5
                spm_jobman('run',SPMJOB.jobs);
            elseif SPMversion==8  % SPM8 compatible.
                SPMJOB.jobs = spm_jobman('spm5tospm8',{SPMJOB.jobs});
                spm_jobman('run',SPMJOB.jobs{1});
            else
                uiwait(msgbox('The current SPM version is not supported by DPARSF. Please install SPM5 or SPM8 first.','Invalid SPM Version.'));
            end
            
            fprintf(['Smooth:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        
    elseif (AutoDataProcessParameter.IsSmooth==2)   % Smooth by DARTEL. The smoothing that is a part of the normalization to MNI space computes these average intensities from the original data, rather than the warped versions. When the data are warped, some voxels will grow and others will shrink. This will change the regional averages, with more weighting towards those voxels that have grows.
        
        parfor i=1:AutoDataProcessParameter.SubjectNum
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Dartel_NormaliseToMNI_FewSubjects.mat']);
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.fwhm=AutoDataProcessParameter.Smooth.FWHM;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.preserve=0;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.bb=AutoDataProcessParameter.Normalize.BoundingBox;
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.vox=AutoDataProcessParameter.Normalize.VoxSize;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'Template_6.*']);
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.template={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]};
            
            
            FileList=[];
            for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
                cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,AutoDataProcessParameter.SubjectID{i}]);
                DirImg=dir('*.img');
                if isempty(DirImg)  %Also support .nii files. % Either in .nii.gz or in .nii
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    DirImg=dir('*.nii');
                end
                
                if length(DirImg)>1  %3D .img or .nii images.
                    if AutoDataProcessParameter.TimePoints>0 && length(DirImg)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                        Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    for j=1:length(DirImg)
                        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(j).name]}];
                    end
                else %4D .nii images
                    Nii  = nifti(DirImg(1).name);
                    if AutoDataProcessParameter.TimePoints>0 && size(Nii.dat,4)~=AutoDataProcessParameter.TimePoints % Will not check if TimePoints set to 0.
                        Error=[Error;{['Error in Smooth: ',AutoDataProcessParameter.SubjectID{i}]}];
                    end
                    
                    FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]}];
                    
                    
                end
            end
            
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).images=FileList;
            
            DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
            SPMJOB.matlabbatch{1,1}.spm.tools.dartel.mni_norm.data.subj(1,1).flowfield={[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]};
            
            spm_jobman('run',SPMJOB.matlabbatch);
            fprintf(['Smooth by using DARTEL:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
        end
        
    end
    
    %Copy the Smoothed files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+S
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,AutoDataProcessParameter.SubjectID{i}])
            
            if (AutoDataProcessParameter.IsSmooth==1)
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'s*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,AutoDataProcessParameter.SubjectID{i}])
            elseif (AutoDataProcessParameter.IsSmooth==2) % If smoothed by DARTEL, then the smoothed files still under realign directory.
                movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName(1:end-1),filesep,AutoDataProcessParameter.SubjectID{i},filesep,'s*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'S',filesep,AutoDataProcessParameter.SubjectID{i}])
            end
            fprintf(['Moving Smoothed Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'S']; %Now StartingDirName is with new suffix 'S'
end
if ~isempty(Error)
    disp(Error);
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Detrend
% detrend is no longer needed if linear trend is included in nuisance regression. Keeping this function is for back compatibility
if (AutoDataProcessParameter.IsDetrend==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            rest_detrend([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], '_detrend');
        end
    end
    
    %Copy the Detrended files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+D
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'D',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_detrend',filesep,'*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'D',filesep,AutoDataProcessParameter.SubjectID{i}])
            
            rmdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_detrend']);
            fprintf(['Moving Dtrended Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'D']; %Now StartingDirName is with new suffix 'D'
end



% If don't need to Warp into original space, then check if the masks are appropriate and resample if not.

if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==0) && ((AutoDataProcessParameter.IsCalALFF==1)||( (AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterNormalizeFiltering')) )||(AutoDataProcessParameter.IsCalReHo==1)||(AutoDataProcessParameter.IsCalDegreeCentrality==1)||(AutoDataProcessParameter.IsCalFC==1)||(AutoDataProcessParameter.IsCalVMHC==1)||(AutoDataProcessParameter.IsCWAS==1))
    
    MasksName{1,1}=[ProgramPath,filesep,'Templates',filesep,'BrainMask_05_91x109x91.img'];
    MasksName{2,1}=[ProgramPath,filesep,'Templates',filesep,'CsfMask_07_91x109x91.img'];
    MasksName{3,1}=[ProgramPath,filesep,'Templates',filesep,'WhiteMask_09_91x109x91.img'];
    MasksName{4,1}=[ProgramPath,filesep,'Templates',filesep,'GreyMask_02_91x109x91.img'];
    
    if (isfield(AutoDataProcessParameter,'MaskFile')) && (~isempty(AutoDataProcessParameter.MaskFile)) && (~isequal(AutoDataProcessParameter.MaskFile, 'Default'))
        MasksName{5,1}=AutoDataProcessParameter.MaskFile;
    end
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks']);
    end
    
    RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.img']);
    if isempty(RefFile)  % Also support .nii.gz files.
        RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii.gz']);
    end
    if isempty(RefFile)  %Also support .nii files.
        RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii']);
    end
    RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,RefFile(1).name];
    [RefData,RefVox,RefHeader]=rest_readfile(RefFile,1);
    
    for iMask=1:length(MasksName)
        AMaskFilename = MasksName{iMask};
        fprintf('\nResample Masks (%s) to the resolution of functional images.\n',AMaskFilename);
        
        [pathstr, name, ext] = fileparts(AMaskFilename);
        ReslicedMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,'AllResampled_',name,'.nii'];
        
        y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
        
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Filter ('AfterNormalize')
if (AutoDataProcessParameter.IsFilter==1) && (strcmpi(AutoDataProcessParameter.Filter.Timing,'AfterNormalize'))
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            if AutoDataProcessParameter.TR==0  % Need to retrieve the TR information from the NIfTI images
                TR = AutoDataProcessParameter.TRSet(i,iFunSession)
            else
                TR = AutoDataProcessParameter.TR;
            end
            
            y_bandpass([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                TR, ...
                AutoDataProcessParameter.Filter.ALowPass_HighCutoff, ...
                AutoDataProcessParameter.Filter.AHighPass_LowCutoff, ...
                AutoDataProcessParameter.Filter.AAddMeanBack, ...
                ''); % Just don't use mask in filtering. %AutoDataProcessParameter.Filter.AMaskFilename);
        end
    end
    
    %Copy the Filtered files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+F
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'F',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_filtered',filesep,'*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'F',filesep,AutoDataProcessParameter.SubjectID{i}])
            
            rmdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_filtered']);
            fprintf(['Moving Filtered Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'F']; %Now StartingDirName is with new suffix 'F'
    
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % select covariate manually from the T1ImgCoreg                    % Huiyuan Huang,20140815
if (AutoDataProcessParameter.IsCovremove==1)
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'CovariateMats'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'CovariateMats']);
    end
    %  cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    for i=1:AutoDataProcessParameter.SubjectNum
        FileList=[];
        
        DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(DirT1ImgCoreg)  % Also support .nii files.
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
            if length(DirT1ImgCoreg)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
            end
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name,',1']}];
        
        
        
        fprintf('select covariate for %s: \n',AutoDataProcessParameter.SubjectID{i});
        
        global PreSurgMappProcessing_spm_image_Parameters
        PreSurgMappProcessing_spm_image_Parameters.tag=1;
        PreSurgMappProcessing_spm_image_Parameters.ReorientFileList=FileList;
        
        for j=1:20  % support for more covariate selecting,added by Huiyuan Huang 20140815
            
            
            uiwait(PreSurgMappProcessing_spm_image('init',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name]));
            if PreSurgMappProcessing_spm_image_Parameters.tag==0
                break
                
            end
            mat=PreSurgMappProcessing_spm_image_Parameters.ReorientMat;
            save([AutoDataProcessParameter.DataProcessDir,filesep,'CovariateMats',filesep,AutoDataProcessParameter.SubjectID{i},'_Covariate',int2str(j),'.mat'],'mat') % save each covariate
            %  clear global PreSurgMappProcessing_spm_image_Parameters
            fprintf('select covariate for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
            %  cd('..');
        end
    end
end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%If don't need to Warp into original space, then resample the other covariables mask
if (AutoDataProcessParameter.IsCovremove==1) && ((strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterNormalizeFiltering'))&&(AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==0))
    % Huiyuan Huang,20140815
    % select the covariate directly from T1Imgcoreg figure
    CovariateListtmp=dir([AutoDataProcessParameter.DataProcessDir,filesep,'CovariateMats']);
    CovariateList=CovariateListtmp(3:end);
    CovNum=size(CovariateList,1);
    CovSelected=cell(CovNum,1);
    for cc=1:CovNum
        load([AutoDataProcessParameter.DataProcessDir,filesep,'CovariateMats',filesep, CovariateList(cc,1).name]);
        CovSelected{cc,1}=['ROI Center(mm)=(',int2str(-mat(1,4)),', ',int2str(-mat(2,4)),', ',int2str(-mat(3,4)),'); Radius=6.00 mm.'];
    end
    
    AutoDataProcessParameter.Covremove.OtherCovariatesROI=CovSelected;
    
    if ~isempty(AutoDataProcessParameter.Covremove.OtherCovariatesROI)
        
        if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks'],'dir'))
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks']);
        end
        
        % Check if masks appropriate %This can be used as a function!!! ONLY FOR RESAMPLE
        OtherCovariatesROIForEachSubject=cell(AutoDataProcessParameter.SubjectNum,1);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            Suffix='OtherCovariateROI_'; %%!!! Change as in Function
            SubjectROI=AutoDataProcessParameter.Covremove.OtherCovariatesROI;%%!!! Change as in Fuction
            
            % Set the reference image
            RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.img']);
            if isempty(RefFile)  % Also support .nii.gz files.
                RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii.gz']);
            end
            if isempty(RefFile)  % Also support .nii files.
                RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii']);
            end
            RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{1},filesep,RefFile(1).name];
            [RefData,RefVox,RefHeader]=rest_readfile(RefFile,1);
            
            % Ball to mask
            for iROI=1:length(SubjectROI)
                if rest_SphereROI( 'IsBallDefinition', SubjectROI{iROI})
                    
                    ROIMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                    
                    rest_Y_SphereROI( 'BallDefinition2Mask' , SubjectROI{iROI}, size(RefData), RefVox, RefHeader, ROIMaskName);
                    
                    SubjectROI{iROI}=[ROIMaskName];
                end
            end
            
            % Check if the ROI mask is appropriate
            for iROI=1:length(SubjectROI)
                AMaskFilename=SubjectROI{iROI};
                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        [MaskData,MaskVox,MaskHeader]=rest_readfile(AMaskFilename);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',Suffix,AMaskFilename, AutoDataProcessParameter.SubjectID{i});
                            
                            ReslicedMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                            y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
                            SubjectROI{iROI}=ReslicedMaskName;
                        end
                    end
                end
            end
            
            
            % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Covariables_List:', then get the corresponded covariables file
            for iROI=1:length(SubjectROI)
                if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (strcmpi(ext, '.txt'))
                        fid = fopen(SubjectROI{iROI});
                        SeedTimeCourseList=textscan(fid,'%s','\n');
                        fclose(fid);
                        if strcmpi(SeedTimeCourseList{1}{1},'Covariables_List:')
                            SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                        end
                    end
                end
                
            end
            
            OtherCovariatesROIForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        end
        
        AutoDataProcessParameter.Covremove.OtherCovariatesROIForEachSubject = OtherCovariatesROIForEachSubject;
    end
end



%Remove the nuisance Covaribles ('AfterNormalizeFiltering')
if (AutoDataProcessParameter.IsCovremove==1) && (strcmpi(AutoDataProcessParameter.Covremove.Timing,'AfterNormalizeFiltering'))
    
    %Remove the Covariables
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        % parfor i=1:AutoDataProcessParameter.SubjectNum
        for i=1:AutoDataProcessParameter.SubjectNum
            
            CovariablesDef=[];
            
            %Polynomial trends
            %0: constant
            %1: constant + linear trend
            %2: constant + linear trend + quadratic trend.
            %3: constant + linear trend + quadratic trend + cubic trend.   ...
            
            CovariablesDef.polort = AutoDataProcessParameter.Covremove.PolynomialTrend;
            
            
            %Head Motion
            ImgCovModel = 1; %Default
            
            CovariablesDef.CovMat = [];
            
            if (AutoDataProcessParameter.Covremove.HeadMotion==1) %1: Use the current time point of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = Q1;
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==2) %2: Use the current time point and the previous time point of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi,..., Txi-1, Tyi-1, Tzi-1...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)]];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==3) %3: Use the current time point and their squares of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi,..., Txi^2, Tyi^2, Tzi^2...
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1,  Q1.^2];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion==4) %4: Use the Friston 24-parameter model: current time point, the previous time point and their squares of rigid-body 6 realign parameters. e.g., Txi, Tyi, Tzi, ..., Txi-1, Tyi-1, Tzi-1,... and their squares (total 24 items). Friston autoregressive model (Friston, K.J., Williams, S., Howard, R., Frackowiak, R.S., Turner, R., 1996. Movement-related effects in fMRI time-series. Magn Reson Med 35, 346-355.)
                DirRP=dir([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'rp*']);
                Q1=load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirRP.name]);
                CovariablesDef.CovMat = [Q1, [zeros(1,size(Q1,2));Q1(1:end-1,:)], Q1.^2, [zeros(1,size(Q1,2));Q1(1:end-1,:)].^2];
            elseif (AutoDataProcessParameter.Covremove.HeadMotion>=11) %11-14: Use the voxel-specific models. 14 is the voxel-specific 12 model.
                
                if AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1
                    %Use the voxel-specific head motion in original space.
                    
                    HMvoxDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion',filesep,AutoDataProcessParameter.SubjectID{i}];
                    
                    CovariablesDef.CovImgDir = {[HMvoxDir,filesep,'HMvox_X_4DVolume.nii'];[HMvoxDir,filesep,'HMvox_Y_4DVolume.nii'];[HMvoxDir,filesep,'HMvox_Z_4DVolume.nii']};
                    
                else
                    %Use the voxel-specific head motion in MNI space, need to normalize first.
                    TemplateDir_SubID = AutoDataProcessParameter.SubjectID{1};
                    SubjectID_Temp = AutoDataProcessParameter.SubjectID{i};
                    SourceDir_Temp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion'];
                    OutpurDir_Temp = [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotion','W'];
                    T1ImgNewSegmentDir = [AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment'];
                    DARTELTemplateFile = [AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii'];
                    IsSubDirectory = 1;
                    BoundingBox=AutoDataProcessParameter.Normalize.BoundingBox;
                    VoxSize=AutoDataProcessParameter.Normalize.VoxSize;
                    y_Normalize_WriteToMNI_DARTEL(SubjectID_Temp,SourceDir_Temp,OutpurDir_Temp,T1ImgNewSegmentDir,DARTELTemplateFile,IsSubDirectory,BoundingBox,VoxSize)
                    
                    % Set the normalized voxel-specific head motion
                    HMvoxDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'VoxelSpecificHeadMotionW',filesep,AutoDataProcessParameter.SubjectID{i}];
                    
                    CovariablesDef.CovImgDir = {[HMvoxDir,filesep,'wHMvox_X_4DVolume.nii'];[HMvoxDir,filesep,'wHMvox_Y_4DVolume.nii'];[HMvoxDir,filesep,'wHMvox_Z_4DVolume.nii']};
                    
                end
                
                ImgCovModel = AutoDataProcessParameter.Covremove.HeadMotion - 10;
            end
            
            
            %Head Motion "Scrubbing" Regressors: each bad time point is a separate regressor
            if (AutoDataProcessParameter.Covremove.IsHeadMotionScrubbingRegressors==1)
                
                % Use FD_Power or FD_Jenkinson
                FD = load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.FDType,'_',AutoDataProcessParameter.SubjectID{i},'.txt']);
                %FD = load([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter',filesep,AutoDataProcessParameter.SubjectID{i},filesep,FunSessionPrefixSet{iFunSession},'FD_Power_',AutoDataProcessParameter.SubjectID{i},'.txt']);
                
                TemporalMask=ones(length(FD),1);
                Index=find(FD > AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.FDThreshold);
                TemporalMask(Index)=0;
                IndexPrevious=Index;
                for iP=1:AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.PreviousPoints
                    IndexPrevious=IndexPrevious-1;
                    IndexPrevious=IndexPrevious(IndexPrevious>=1);
                    TemporalMask(IndexPrevious)=0;
                end
                IndexNext=Index;
                for iN=1:AutoDataProcessParameter.Covremove.HeadMotionScrubbingRegressors.LaterPoints
                    IndexNext=IndexNext+1;
                    IndexNext=IndexNext(IndexNext<=length(FD));
                    TemporalMask(IndexNext)=0;
                end
                
                BadTimePointsIndex = find(TemporalMask==0);
                BadTimePointsRegressor = zeros(length(FD),length(BadTimePointsIndex));
                for iBadTimePoints = 1:length(BadTimePointsIndex)
                    BadTimePointsRegressor(BadTimePointsIndex(iBadTimePoints),iBadTimePoints) = 1;
                end
                
                CovariablesDef.CovMat = [CovariablesDef.CovMat, BadTimePointsRegressor];
            end
            
            
            %Mask covariates
            if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1)
                MaskPrefix = AutoDataProcessParameter.SubjectID{i};
            else
                MaskPrefix = 'AllResampled';
            end
            
            SubjectCovariatesROI=[];
            if (AutoDataProcessParameter.Covremove.WholeBrain==1)
                SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,MaskPrefix,'_BrainMask_05_91x109x91.nii']}];
            end
            if (AutoDataProcessParameter.Covremove.CSF==1)
                SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,MaskPrefix,'_CsfMask_07_91x109x91.nii']}];
            end
            if (AutoDataProcessParameter.Covremove.WhiteMatter==1)
                SubjectCovariatesROI=[SubjectCovariatesROI;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,MaskPrefix,'_WhiteMask_09_91x109x91.nii']}];
            end
            
            % Add the other Covariate ROIs                % Huiyuan Huang,20140815
            
            
            if ~isempty(AutoDataProcessParameter.Covremove.OtherCovariatesROI)
                SubjectCovariatesROI=[SubjectCovariatesROI;AutoDataProcessParameter.Covremove.OtherCovariatesROIForEachSubject{i}];
            end
            
            
            %Extract Time course for the Mask covariates
            if ~isempty(SubjectCovariatesROI)
                if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs'],'dir'))
                    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs']);
                end
                
                y_ExtractROISignal([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], SubjectCovariatesROI, [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,AutoDataProcessParameter.SubjectID{i}], '', 1);
                
                CovariablesDef.ort_file=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'Covs',filesep,'ROISignals_',AutoDataProcessParameter.SubjectID{i},'.txt'];
            end
            
            
            %Regressing out the covariates
            fprintf('\nRegressing out covariates for subject %s %s.\n',AutoDataProcessParameter.SubjectID{i},FunSessionPrefixSet{iFunSession});
            y_RegressOutImgCovariates([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}],CovariablesDef,'_Covremoved','', ImgCovModel);
            
        end
        fprintf('\n');
    end
    
    
    %Copy the Covariates Removed files to DataProcessDir\{AutoDataProcessParameter.StartingDirName}+C
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        parfor i=1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'C',filesep,AutoDataProcessParameter.SubjectID{i}])
            movefile([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_Covremoved',filesep,'*'],[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,'C',filesep,AutoDataProcessParameter.SubjectID{i}])
            
            rmdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}, '_Covremoved']);
            fprintf(['Moving Coviables Removed Files:',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    AutoDataProcessParameter.StartingDirName=[AutoDataProcessParameter.StartingDirName,'C']; %Now StartingDirName is with new suffix 'C'
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% define ROIs manually from the T1ImgCoreg
% Huiyuan Huang 20140815
if (AutoDataProcessParameter.IsCalFC==1)
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'ROIMats'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'ROIMats']);
    end
    %  cd([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    for i=1:AutoDataProcessParameter.SubjectNum
        FileList=[];
        
        DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(DirT1ImgCoreg)  % Also support .nii files.
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
            if length(DirT1ImgCoreg)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name]);
            end
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        FileList=[FileList;{[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name,',1']}];
        
        
        
        fprintf('define ROI for %s: \n',AutoDataProcessParameter.SubjectID{i});
        
        global PreSurgMappProcessing_spm_image_ROI_Parameters
        PreSurgMappProcessing_spm_image_ROI_Parameters.tag=1;
        PreSurgMappProcessing_spm_image_ROI_Parameters.T1FileList=FileList;
        
        for jj=1:20  % support for more ROI selecting,added by Huiyuan Huang 20140815
            
            uiwait(PreSurgMappProcessing_spm_image_ROI('init',[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirT1ImgCoreg(1).name]));
            if  PreSurgMappProcessing_spm_image_ROI_Parameters.tag==0
                break
            end
            mat= PreSurgMappProcessing_spm_image_ROI_Parameters.ROIMat;
            save([AutoDataProcessParameter.DataProcessDir,filesep,'ROIMats',filesep,AutoDataProcessParameter.SubjectID{i},'_ROI',int2str(jj),'.mat'],'mat') % save each ROI
            %  clear global PreSurgMappProcessing_spm_image_Parameters
            fprintf('define ROI for %s: OK\n',AutoDataProcessParameter.SubjectID{i});
            %  cd('..');
        end
    end
end
% Huiyuan Huang,20140815
% define ROI directly from T1Imgcoreg figure
ROIListtmp=dir([AutoDataProcessParameter.DataProcessDir,filesep,'ROIMats']);
ROIList= ROIListtmp(3:end);
ROINum=size(ROIList,1);
ROISelected=cell(ROINum,1);
for rr=1:ROINum
    load([AutoDataProcessParameter.DataProcessDir,filesep,'ROIMats',filesep,ROIList(rr,1).name]);
    ROISelected{rr,1}=['ROI Center(mm)=(',int2str(-mat(1,4)),', ',int2str(-mat(2,4)),', ',int2str(-mat(3,4)),'); Radius=6.00 mm.'];
end

AutoDataProcessParameter.CalFC.ROIDef=ROISelected;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Generate the appropriate ROI masks
if (~isempty(AutoDataProcessParameter.CalFC.ROIDef)) || (AutoDataProcessParameter.IsDefineROIInteractively==1)
    if ~isfield(AutoDataProcessParameter,'ROINumber_DefinedInteractively')
        AutoDataProcessParameter.ROINumber_DefinedInteractively=0;
    end
    
    if ~(7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'Masks'],'dir'))
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'Masks']);
    end
    
    % Check if masks appropriate %This can be used as a function!!!
    ROIDefForEachSubject=cell(AutoDataProcessParameter.SubjectNum,1);
    parfor i=1:AutoDataProcessParameter.SubjectNum
        Suffix='FCROI_'; %%!!! Change as in Function
        SubjectROI=AutoDataProcessParameter.CalFC.ROIDef;%%!!! Change as in Fuction
        RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
        if isempty(RefFile)  % Also support .nii files.
            RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
        end
        if isempty(RefFile)  % Also support .nii files.
            RefFile=dir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii.gz']);
        end
        RefFile=[AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,RefFile(1).name];
        [RefData,RefVox,RefHeader]=rest_readfile(RefFile,1);
        % Ball to mask
        for iROI=1:length(SubjectROI)
            if rest_SphereROI( 'IsBallDefinition', SubjectROI{iROI})
                
                ROIMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                
                if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==0)
                    rest_Y_SphereROI( 'BallDefinition2Mask' , SubjectROI{iROI}, size(RefData), RefVox, RefHeader, ROIMaskName);
                else
                    [MNIData MNIVox MNIHeader]=rest_readfile([ProgramPath,filesep,'Templates',filesep,'aal.nii']);
                    rest_Y_SphereROI( 'BallDefinition2Mask' , SubjectROI{iROI}, size(MNIData), MNIVox, MNIHeader, ROIMaskName);
                end
                
                SubjectROI{iROI}=[ROIMaskName];
            end
        end
        
        
        if AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1
            %Need to warp masks
            
            % Check if have .txt file. Note: the txt files should be put the last of the ROI definition
            NeedWarpMaskNameSet=[];
            WarpedMaskNameSet=[];
            for iROI=1:length(SubjectROI)
                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        NeedWarpMaskNameSet=[NeedWarpMaskNameSet;{SubjectROI{iROI}}];
                        WarpedMaskNameSet=[WarpedMaskNameSet;{[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii']}];
                        
                        SubjectROI{iROI}=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                    end
                end
            end
            
            
            if (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
                % If is processed by New Segment and DARTEL
                
                TemplateDir_SubID=AutoDataProcessParameter.SubjectID{1};
                
                DARTELTemplateFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6.nii'];
                DARTELTemplateMatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,TemplateDir_SubID,filesep,'Template_6_2mni.mat'];
                
                DirImg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'u_*']);
                FlowFieldFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgNewSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,DirImg(1).name];
                
                
                y_WarpBackByDARTEL(NeedWarpMaskNameSet,WarpedMaskNameSet,RefFile,DARTELTemplateFilename,DARTELTemplateMatFilename,FlowFieldFilename,0);
                
                for iROI=1:length(NeedWarpMaskNameSet)
                    fprintf('\nWarp %s Mask (%s) for "%s" to individual space using DARTEL flow field (in T1ImgNewSegment) genereated by DARTEL.\n',Suffix,NeedWarpMaskNameSet{iROI}, AutoDataProcessParameter.SubjectID{i});
                end
                
            elseif (7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{1}],'dir'))
                % If is processed by unified segmentation
                
                MatFileDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*seg_inv_sn.mat']);
                MatFilename=[AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment',filesep,AutoDataProcessParameter.SubjectID{i},filesep,MatFileDir(1).name];
                
                for iROI=1:length(NeedWarpMaskNameSet)
                    y_NormalizeWrite(NeedWarpMaskNameSet{iROI},WarpedMaskNameSet{iROI},RefFile,MatFilename,0);
                    fprintf('\nWarp %s Mask (%s) for "%s" to individual space using *seg_inv_sn.mat (in T1ImgSegment) genereated by T1 image segmentation.\n',Suffix,NeedWarpMaskNameSet{iROI}, AutoDataProcessParameter.SubjectID{i});
                end
                
            end
            
        else %Do not need to warp masks but may need to resample
            
            % Check if the ROI mask is appropriate
            for iROI=1:length(SubjectROI)
                AMaskFilename=SubjectROI{iROI};
                if exist(SubjectROI{iROI},'file')==2
                    [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                    if (~strcmpi(ext, '.txt'))
                        [MaskData,MaskVox,MaskHeader]=rest_readfile(AMaskFilename);
                        if ~isequal(size(MaskData), size(RefData))
                            fprintf('\nReslice %s Mask (%s) for "%s" since the dimension of mask mismatched the dimension of the functional data.\n',Suffix,AMaskFilename, AutoDataProcessParameter.SubjectID{i});
                            
                            ReslicedMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
                            y_Reslice(AMaskFilename,ReslicedMaskName,RefVox,0, RefFile);
                            SubjectROI{iROI}=ReslicedMaskName;
                        end
                    end
                end
            end
            
        end
        
        % Check if the text file is a definition for multiple subjects. i.e., the first line is 'Seed_Time_Course_List:', then get the corresponded seed series file
        for iROI=1:length(SubjectROI)
            if (ischar(SubjectROI{iROI})) && (exist(SubjectROI{iROI},'file')==2)
                [pathstr, name, ext] = fileparts(SubjectROI{iROI});
                if (strcmpi(ext, '.txt'))
                    fid = fopen(SubjectROI{iROI});
                    SeedTimeCourseList=textscan(fid,'%s','\n');
                    fclose(fid);
                    if strcmpi(SeedTimeCourseList{1}{1},'Seed_Time_Course_List:')
                        SubjectROI{iROI}=SeedTimeCourseList{1}{i+1};
                    end
                end
            end
            
        end
        
        ROIDefForEachSubject{i}=SubjectROI; %%!!! Change as in Fuction
        
        % Process ROIs defined interactively
        % These files don't need to warp, cause they are defined in original space and mask was created in original space.
        Suffix='ROIDefinedInteractively_';
        for iROI=1:AutoDataProcessParameter.ROINumber_DefinedInteractively
            SubjectROI=rest_Y_SphereROI('ROIBall2Str', AutoDataProcessParameter.ROICenter_DefinedInteractively{i,iROI}, AutoDataProcessParameter.ROIRadius_DefinedInteractively(i,iROI));
            
            ROIMaskName=[AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,Suffix,num2str(iROI),'_',AutoDataProcessParameter.SubjectID{i},'.nii'];
            rest_Y_SphereROI( 'BallDefinition2Mask' , SubjectROI, size(RefData), RefVox, RefHeader, ROIMaskName);
            
            ROIDefForEachSubject{i}{length(AutoDataProcessParameter.CalFC.ROIDef)+iROI}=[ROIMaskName];
        end
        
    end
    
    AutoDataProcessParameter.CalFC.ROIDefForEachSubject = ROIDefForEachSubject;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Functional Connectivity Calculation (by Seed based Correlation Anlyasis)
if (AutoDataProcessParameter.IsCalFC==1)
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FC']);
        
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            % Get the appropriate mask
            if ~isempty(AutoDataProcessParameter.MaskFile)
                if (isequal(AutoDataProcessParameter.MaskFile, 'Default'))
                    MaskNameString = 'BrainMask_05_91x109x91';
                else
                    [pathstr, name, ext] = fileparts(AutoDataProcessParameter.MaskFile);
                    MaskNameString = name;
                end
                if (AutoDataProcessParameter.IsWarpMasksIntoIndividualSpace==1)
                    MaskPrefix = AutoDataProcessParameter.SubjectID{i};
                else
                    MaskPrefix = 'AllResampled';
                end
                AMaskFilename = [AutoDataProcessParameter.DataProcessDir,filesep,'Masks',filesep,MaskPrefix,'_',MaskNameString,'.nii'];
            else
                AMaskFilename='';
            end
            
            
            % Calculate Functional Connectivity by Seed based Correlation Anlyasis
            
            y_SCA([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},AutoDataProcessParameter.StartingDirName,filesep,AutoDataProcessParameter.SubjectID{i}], ...
                AutoDataProcessParameter.CalFC.ROIDefForEachSubject{i}, ...
                [AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'Results',filesep,'FC',filesep,'FCMap_',AutoDataProcessParameter.SubjectID{i}], ...
                AMaskFilename, ...
                AutoDataProcessParameter.CalFC.IsMultipleLabel);
            
            % Fisher's r to z transformation has been performed inside y_SCA
            
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Nii2NiftiPairs_ICA
if (AutoDataProcessParameter.IsCalICA==1)||(AutoDataProcessParameter.IsCaltaskactivation==1)
    %     if (~exist([AutoDataProcessParameter.DataProcessDir,filesep,'NiftiPairs','dir'])) % revised bu HHY in 20150602
    for iFunSession=1:AutoDataProcessParameter.FunctionalSessionNumber
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs']);
        ImgFileList ={};
        outname=([FunSessionPrefixSet{iFunSession},'NiftiPairs']);
        AllsubjectFoldertmp=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImgARS']);
        AllsubjectFolder=AllsubjectFoldertmp(3:end);
        for i=1:length(AllsubjectFolder)
            subjectFiletmp=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImgARS',filesep,AllsubjectFolder(i).name]);
            subjectFile=subjectFiletmp(3:end);
            for j=1:length(subjectFile)
                if strcmpi(subjectFile(j).name(end-3:end), '.nii')
                    ImgFileList=[ImgFileList; {[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImgARS',filesep,AllsubjectFolder(i).name,filesep,subjectFile(j).name(1:end-4),'.nii']}];
                end
            end
        end
        if size(subjectFile,1)<=2;
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs']);
            for i=1:length(ImgFileList)
                if size(AllsubjectFolder,1)>=1,
                    rest_waitbar((i-1)/length(ImgFileList)+0.01, ...
                        ImgFileList{i}, ...
                        'Computing','Parent');
                end
                [Path, fileN, extn] = fileparts(ImgFileList{i});
                
                IndexFilesep = strfind(ImgFileList{i}, filesep);
                if ~isempty(IndexFilesep)
                    DirNameTemp=ImgFileList{i}(IndexFilesep(end-1)+1:IndexFilesep(end)-1);
                    PO=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs',filesep,DirNameTemp,'_',outname,filesep,outname,'_',fileN,'.img'];
                    [s, mess, messid]=mkdir(fileparts(PO));
                else
                    PO=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs',filesep,outname,'_',fileN,'.img'];
                end
                rest_Nii2NiftiPairs(ImgFileList{i},PO);
            end
        end
        rest_waitbar;
        fprintf('Done ...\n');
    end
end



%%
%%%%%%%% Calculating rest ICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (AutoDataProcessParameter.IsCalICA==1)&&(AutoDataProcessParameter.IsCalrestICA==1)      % HHY 20150504
    iFunSession=1;
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA']);
    % construct the structure
    appConfig=struct();
    
    % select files
    % [dataList,dataLabels]=nic_rsdd_inputData();
    if exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs'],'dir')  %%%%%%%%%%%%%
        %             sublisttemp=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs']); %%%%%%%%%%%%%
        %             sublist=sublisttemp(3:end);
        for i = 1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA',filesep,AutoDataProcessParameter.SubjectID{i}]);
            outputDir=([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA',filesep,AutoDataProcessParameter.SubjectID{i}]);
            dataDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs',filesep,AutoDataProcessParameter.SubjectID{i},'_',FunSessionPrefixSet{iFunSession},'NiftiPairs'];
            dataList=cell(1,3);
            dataList{1,1}=dataDir;
            %                 dataList{1,2}=AutoDataProcessParameter.TimePoints;
            cd(dataDir);
            nifitipairDir=dir('*.img');
            pictureDir=char();
            val=char();
            for ff=1:length(nifitipairDir)
                pictureDir(ff,:)=[dataDir,filesep,nifitipairDir(ff).name];
                val=pictureDir;
            end
            dataList{1,2}=length(nifitipairDir);
            dataList{1,3}=struct('name',val);
            dataLabels=ones(1,1);
            
            appConfig.AppFileList=dataList;
            appConfig.AppSubjectLabels=dataLabels;
            
            % configure the paramters of PCA
            % -------------------------------
            dataReduction=struct();
            
            dataReduction.maskType=1;
            dataReduction.maskFile='';
            
            dataReduction.pcaStepNum=1;
            dataReduction.pcsNum=AutoDataProcessParameter.restICA.TNC;% the pcs number of the steps
            dataReduction.groupSize=4;
            
            dataReduction.samePCWithICA=1;
            dataReduction.scatter=struct('removeScatter',1,'scatterThreshold',0.8);
            appConfig.dataReduction=dataReduction;
            % -------------------------------end
            
            appConfig.outDir= outputDir;% output dir
            appConfig.isAutomaticEstimate=0;% automatic estimate the number of component
            appConfig.compNum=AutoDataProcessParameter.restICA.TNC; %The number of component
            appConfig.icaAlgorithm='Infomax';% the algorithm name
            appConfig.icaAlgorithmNo=1; % the index of ICA algorithm
            appConfig.randMode={0,1,0};%{Booststrap, RandInit, Multiple order}; 1:use, 0: unuse
            appConfig.runTimes=25; % runTimes
            appConfig.outPrefix='gc'; % predix
            appConfig.scaleType=2; % how to scale the result: 1:calibation, 2: z-score
            
            extParameters=struct('MultipleRun',1,'DataReductionStep',1,'RunClustering',1,'RunAggregating',1,'RunClibration',1,'RunDeleteFolder',1);% How to do every step
            
            % run analysis
            nic_rsdd_runAnalysis(appConfig,extParameters);
            
            % view the result
            view_gui(appConfig);
            
            
        end
    else
        %             sublisttemp=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImgARS',filesep,'*']);
        %             sublist=sublisttemp(3:end);
        for i = 1:AutoDataProcessParameter.SubjectNum
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA',filesep,AutoDataProcessParameter.SubjectID{i}]);
            outputDir=([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA',filesep,AutoDataProcessParameter.SubjectID{i}]);
            dataDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImgARS',filesep,AutoDataProcessParameter.SubjectID{i}];
            dataList=cell(1,3);
            dataList{1,1}=dataDir;
            %                 dataList{1,2}=AutoDataProcessParameter.TimePoints;
            cd(dataDir);
            nifitipairDir=dir('*.img');
            pictureDir=char();
            val=char();
            for ff=1:length(nifitipairDir)
                pictureDir(ff,:)=[dataDir,filesep,nifitipairDir(ff).name];
                val=pictureDir;
            end
            dataList{1,2}=length(nifitipairDir);
            dataList{1,3}=struct('name',val);
            dataLabels=ones(1,1);
            
            appConfig.AppFileList=dataList;
            appConfig.AppSubjectLabels=dataLabels;
            
            % configure the paramters of PCA
            % -------------------------------
            dataReduction=struct();
            
            dataReduction.maskType=1;
            dataReduction.maskFile='';
            
            dataReduction.pcaStepNum=1;
            dataReduction.pcsNum=AutoDataProcessParameter.restICA.TNC % the pcs number of the steps
            dataReduction.groupSize=4;
            
            dataReduction.samePCWithICA=1;
            dataReduction.scatter=struct('removeScatter',1,'scatterThreshold',0.8);
            appConfig.dataReduction=dataReduction;
            % -------------------------------end
            
            appConfig.outDir= outputDir;% output dir
            appConfig.isAutomaticEstimate=0;% automatic estimate the number of component
            appConfig.compNum=AutoDataProcessParameter.restICA.TNC; %The number of component
            appConfig.icaAlgorithm='Infomax';% the algorithm name
            appConfig.icaAlgorithmNo=1; % the index of ICA algorithm
            appConfig.randMode={0,1,0};%{Booststrap, RandInit, Multiple order}; 1:use, 0: unuse
            appConfig.runTimes=25; % runTimes
            appConfig.outPrefix='gc'; % predix
            appConfig.scaleType=2; % how to scale the result: 1:calibation, 2: z-score
            
            extParameters=struct('MultipleRun',1,'DataReductionStep',1,'RunClustering',1,'RunAggregating',1,'RunClibration',1,'RunDeleteFolder',1);% How to do every step
            
            % run analysis
            nic_rsdd_runAnalysis(appConfig,extParameters);
            
            % view the result
            view_gui(appConfig);
            
        end
    end
    
    
end



%%
%%%%%%%% Calculating task ICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (AutoDataProcessParameter.IsCalICA==1)&&(AutoDataProcessParameter.IsCaltaskICA==1)      % HHY 20150504
    for iFunSession=2:AutoDataProcessParameter.FunctionalSessionNumber
        mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA']);
        % construct the structure
        appConfig=struct();
        
        % select files
        % [dataList,dataLabels]=nic_rsdd_inputData();
        if exist([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs'],'dir')  %%%%%%%%%%%%%
            %             sublisttemp=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs']); %%%%%%%%%%%%%
            %             sublist=sublisttemp(3:end);
            for i = 1:AutoDataProcessParameter.SubjectNum
                mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA',filesep,AutoDataProcessParameter.SubjectID{i}]);
                outputDir=([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA',filesep,AutoDataProcessParameter.SubjectID{i}]);
                dataDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'NiftiPairs',filesep,AutoDataProcessParameter.SubjectID{i},'_',FunSessionPrefixSet{iFunSession},'NiftiPairs'];
                dataList=cell(1,3);
                dataList{1,1}=dataDir;
                %                 dataList{1,2}=AutoDataProcessParameter.TimePoints;
                cd(dataDir);
                nifitipairDir=dir('*.img');
                pictureDir=char();
                val=char();
                for ff=1:length(nifitipairDir)
                    pictureDir(ff,:)=[dataDir,filesep,nifitipairDir(ff).name];
                    val=pictureDir;
                end
                dataList{1,2}=length(nifitipairDir);
                dataList{1,3}=struct('name',val);
                dataLabels=ones(1,1);
                
                appConfig.AppFileList=dataList;
                appConfig.AppSubjectLabels=dataLabels;
                
                % configure the paramters of PCA
                % -------------------------------
                dataReduction=struct();
                
                dataReduction.maskType=1;
                dataReduction.maskFile='';
                
                dataReduction.pcaStepNum=1;
                dataReduction.pcsNum=AutoDataProcessParameter.taskICA.TNC;% the pcs number of the steps
                dataReduction.groupSize=4;
                
                dataReduction.samePCWithICA=1;
                dataReduction.scatter=struct('removeScatter',1,'scatterThreshold',0.8);
                appConfig.dataReduction=dataReduction;
                % -------------------------------end
                
                appConfig.outDir= outputDir;% output dir
                appConfig.isAutomaticEstimate=0;% automatic estimate the number of component
                appConfig.compNum=AutoDataProcessParameter.taskICA.TNC; %The number of component
                appConfig.icaAlgorithm='Infomax';% the algorithm name
                appConfig.icaAlgorithmNo=1; % the index of ICA algorithm
                appConfig.randMode={0,1,0};%{Booststrap, RandInit, Multiple order}; 1:use, 0: unuse
                appConfig.runTimes=25; % runTimes
                appConfig.outPrefix='gc'; % predix
                appConfig.scaleType=2; % how to scale the result: 1:calibation, 2: z-score
                
                extParameters=struct('MultipleRun',1,'DataReductionStep',1,'RunClustering',1,'RunAggregating',1,'RunClibration',1,'RunDeleteFolder',1);% How to do every step
                
                % run analysis
                nic_rsdd_runAnalysis(appConfig,extParameters);
                
                % view the result
                view_gui(appConfig);
                
                
            end
        else
            %             sublisttemp=dir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImgARS',filesep,'*']);
            %             sublist=sublisttemp(3:end);
            for i = 1:AutoDataProcessParameter.SubjectNum
                mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA',filesep,AutoDataProcessParameter.SubjectID{i}]);
                outputDir=([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'ICA',filesep,AutoDataProcessParameter.SubjectID{i}]);
                dataDir=[AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{iFunSession},'FunImgARS',filesep,AutoDataProcessParameter.SubjectID{i}];
                dataList=cell(1,3);
                dataList{1,1}=dataDir;
                %                 dataList{1,2}=AutoDataProcessParameter.TimePoints;
                cd(dataDir);
                nifitipairDir=dir('*.img');
                pictureDir=char();
                val=char();
                for ff=1:length(nifitipairDir)
                    pictureDir(ff,:)=[dataDir,filesep,nifitipairDir(ff).name];
                    val=pictureDir;
                end
                dataList{1,2}=length(nifitipairDir);
                dataList{1,3}=struct('name',val);
                dataLabels=ones(1,1);
                
                appConfig.AppFileList=dataList;
                appConfig.AppSubjectLabels=dataLabels;
                
                % configure the paramters of PCA
                % -------------------------------
                dataReduction=struct();
                
                dataReduction.maskType=1;
                dataReduction.maskFile='';
                
                dataReduction.pcaStepNum=1;
                dataReduction.pcsNum=AutoDataProcessParameter.taskICA.TNC; % the pcs number of the steps
                dataReduction.groupSize=4;
                
                dataReduction.samePCWithICA=1;
                dataReduction.scatter=struct('removeScatter',1,'scatterThreshold',0.8);
                appConfig.dataReduction=dataReduction;
                % -------------------------------end
                
                appConfig.outDir= outputDir;% output dir
                appConfig.isAutomaticEstimate=0;% automatic estimate the number of component
                appConfig.compNum=AutoDataProcessParameter.taskICA.TNC; %The number of component
                appConfig.icaAlgorithm='Infomax';% the algorithm name
                appConfig.icaAlgorithmNo=1; % the index of ICA algorithm
                appConfig.randMode={0,1,0};%{Booststrap, RandInit, Multiple order}; 1:use, 0: unuse
                appConfig.runTimes=25; % runTimes
                appConfig.outPrefix='gc'; % predix
                appConfig.scaleType=2; % how to scale the result: 1:calibation, 2: z-score
                
                extParameters=struct('MultipleRun',1,'DataReductionStep',1,'RunClustering',1,'RunAggregating',1,'RunClibration',1,'RunDeleteFolder',1);% How to do every step
                
                % run analysis
                nic_rsdd_runAnalysis(appConfig,extParameters);
                
                % view the result
                view_gui(appConfig);
                
            end
        end
    end
    
end

%% Added by HHY 20150604
%%%%%%% Automatic indentify task-related independent component %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (AutoDataProcessParameter.IsCaltaskactivation==1)&&(AutoDataProcessParameter.IsCaltaskICA==1)&&(AutoDataProcessParameter.taskcondition==1)
    Impulsefunction=zeros(1,AutoDataProcessParameter.TimePoints);
    if AutoDataProcessParameter.taskactivation.Duration1==0
        onset=AutoDataProcessParameter.taskactivation.Onset1';
        interval=0;
    else
        onset=AutoDataProcessParameter.taskactivation.Onset1';
        interval=AutoDataProcessParameter.taskactivation.Duration1-1;
    end
    
    for i=1:length(onset)
        Impulsefunction(onset(i):onset(i)+interval)=1;
    end
    
    
    
    [hrf,p] = spm_hrf(AutoDataProcessParameter.TR);
    RefTC= conv(Impulsefunction,hrf);
    RefTC= RefTC(1:AutoDataProcessParameter.TimePoints);
    RefTC= RefTC';
    
    if ~isempty(strfind(AutoDataProcessParameter.StartingDirName,'NiftiPairs'))
        cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{AutoDataProcessParameter.FunctionalSessionNumber},'ICA']);
        ICADir=([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{AutoDataProcessParameter.FunctionalSessionNumber},'ICA']);
        sublist=dir([ICADir,filesep,'*']);
        
        for   ss= 3:length(sublist)
            unzip([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_component_ica_s1_.zip'],[sublist(ss).name,filesep,'output']);
        end
        
        % Extract time course
        for ss=3:length(sublist)
            % PreSurgMappTCdir=dir([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_timecourses_ica_s1_.hdr']);
            [TC_allIC, TCHead] = rest_ReadNiftiImage([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_timecourses_ica_s1_.hdr']);
            AllSubjects_TC{ss-2,1}=TC_allIC;
            for i=1:size(TC_allIC,2);
                r=corrcoef(RefTC,TC_allIC(:,i));
                corrmat(i,1)=r(1,2);
            end
            
            temp = corrmat;
            [val ind]=sort(temp,'descend');
            %             The_biggest_r_taskIC(:,1)=ind(1);
            %             The_biggest_r_taskIC(:,2)=val(1);
            %             The_biggest_r_taskIC(:,3)=ind(2);
            %             The_biggest_r_taskIC(:,4)=val(2);
            %             The_biggest_r_taskIC(:,5)=ind(3);
            %             The_biggest_r_taskIC(:,6)=val(3);
            finalResult_r_taskTC=[ind val];
            AllSubjects_The_biggest_r_taskIC{ss-2,1}=finalResult_r_taskTC;
            
            cd(AutoDataProcessParameter.DataProcessDir);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{AutoDataProcessParameter.FunctionalSessionNumber},'task_related_component',filesep,sublist(ss).name]);
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{AutoDataProcessParameter.FunctionalSessionNumber},'task_related_component',filesep,sublist(ss).name]);
            save  finalResult_r_taskTC  finalResult_r_taskTC
            cd([AutoDataProcessParameter.DataProcessDir,filesep,FunSessionPrefixSet{AutoDataProcessParameter.FunctionalSessionNumber},'task_related_component']);
            save   AllSubjects_taskIC  AllSubjects_The_biggest_r_taskIC AllSubjects_TC
        end
        
        
    elseif AutoDataProcessParameter.FunctionalSessionNumber==1
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'ICA']);
        ICADir=([AutoDataProcessParameter.DataProcessDir,filesep,'ICA']);
        sublist=dir([ICADir,filesep,'*']);
        
        for   ss= 3:length(sublist)
            unzip([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_component_ica_s1_.zip'],[sublist(ss).name,filesep,'output']);
        end
        
        % Extract time course
        for ss=3:length(sublist)
            % PreSurgMappTCdir=dir([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_timecourses_ica_s1_.hdr']);
            [TC_allIC, TCHead] = rest_ReadNiftiImage([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_timecourses_ica_s1_.hdr']);
            AllSubjects_TC{ss-2,1}=TC_allIC;
            for i=1:size(TC_allIC,2);
                r=corrcoef(RefTC,TC_allIC(:,i));
                corrmat(i,1)=r(1,2);
            end
            
            temp = corrmat;
            [val ind]=sort(temp,'descend');
            finalResult_r_taskTC=[ind val];
            AllSubjects_The_biggest_r_taskIC{ss-2,1}=finalResult_r_taskTC;
            
            cd(AutoDataProcessParameter.DataProcessDir);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'task_related_component',filesep,sublist(ss).name]);
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'task_related_component',filesep,sublist(ss).name]);
            save  finalResult_r_taskTC  finalResult_r_taskTC
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'task_related_component']);
            save   AllSubjects_taskIC  AllSubjects_The_biggest_r_taskIC AllSubjects_TC
        end
        
        
    elseif AutoDataProcessParameter.FunctionalSessionNumber>1
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'S2_ICA']);
        ICADir=([AutoDataProcessParameter.DataProcessDir,filesep,'S2_ICA']);
        sublist=dir([ICADir,filesep,'*']);
        
        for   ss= 3:length(sublist)
            unzip([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_component_ica_s1_.zip'],[sublist(ss).name,filesep,'output']);
        end
        
        % Extract time course
        for ss=3:length(sublist)
            % PreSurgMappTCdir=dir([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_timecourses_ica_s1_.hdr']);
            [TC_allIC, TCHead] = rest_ReadNiftiImage([ICADir,filesep,sublist(ss).name,filesep,'output',filesep,'gc_sub001_timecourses_ica_s1_.hdr']);
            AllSubjects_TC{ss-2,1}=TC_allIC;
            for i=1:size(TC_allIC,2);
                r=corrcoef(RefTC,TC_allIC(:,i));
                corrmat(i,1)=r(1,2);
            end
            
            temp = corrmat;
            [val ind]=sort(temp,'descend');
            finalResult_r_taskTC=[ind val];
            AllSubjects_The_biggest_r_taskIC{ss-2,1}=finalResult_r_taskTC;
            
            cd(AutoDataProcessParameter.DataProcessDir);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'S2_task_related_component',filesep,sublist(ss).name]);
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'S2_task_related_component',filesep,sublist(ss).name]);
            save finalResult_r_taskTC  finalResult_r_taskTC
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'S2_task_related_component']);
            save   AllSubjects_taskIC  AllSubjects_The_biggest_r_taskIC AllSubjects_TC
        end
    end
    
end
%%
%%%%%%%%%%%%% Calculating DICI ICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% Segmentation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (AutoDataProcessParameter.IsSegment>=1)
    [ProgramPath, fileN, extn] = fileparts(which('PreSurgMappProcessing_main.m'));
    if AutoDataProcessParameter.IsSegment==1
        T1ImgSegmentDirectoryName = 'T1ImgSegment';
    elseif AutoDataProcessParameter.IsSegment==2
        T1ImgSegmentDirectoryName = 'T1ImgNewSegment';
    end
    if 7==exist([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1}],'dir')
        DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.img']);
        if isempty(DirT1ImgCoreg)  % Also support .nii files.
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii.gz']);
            if length(DirT1ImgCoreg)==1
                gunzip([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
                delete([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,DirImg(1).name]);
            end
            DirT1ImgCoreg=dir([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{1},filesep,'*.nii']);
        end
    else
        DirT1ImgCoreg=[];
    end
    if isempty(DirT1ImgCoreg)
        
        %Backup the T1 images to T1ImgSegment or T1ImgNewSegment
        % Check if co* image exist.
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{1}]);
        DirCo=dir('c*.img');
        if isempty(DirCo)
            DirCo=dir('c*.nii.gz');  % Search .nii.gz and unzip;
            if length(DirCo)==1
                gunzip(DirCo(1).name);
                delete(DirCo(1).name);
            end
            DirCo=dir('c*.nii');  % Also support .nii files.
        end
        if isempty(DirCo)
            DirImg=dir('*.img');
            if isempty(DirImg)  % Also support .nii files.
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                DirImg=dir('*.nii');
            end
            if length(DirImg)==1
                button = questdlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. Do you want to use the T1 image without co? Such as: ',DirImg(1).name,'?'],'No co* T1 image is found','Yes','No','Yes');
                if strcmpi(button,'Yes')
                    UseNoCoT1Image=1;
                else
                    return;
                end
            elseif length(DirImg)==0
                errordlg(['No T1 image has been found.'],'No T1 image has been found');
                return;
            else
                errordlg(['No co* T1 image (T1 image which is reoriented to the nearest orthogonal direction to ''canonical space'' and removed excess air surrounding the individual as well as parts of the neck below the cerebellum) is found. And there are too many T1 images detected in T1Img directory. Please determine which T1 image you want to use and delete the others from the T1Img directory, then re-run the analysis.'],'No co* T1 image is found');
                return;
            end
        else
            UseNoCoT1Image=0;
        end
        
        parfor i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1Img',filesep,AutoDataProcessParameter.SubjectID{i}]);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
            % Check in co* image exist.
            if UseNoCoT1Image==0
                DirImg=dir('c*.img');
                if ~isempty(DirImg)
                    copyfile('c*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                    copyfile('c*.img',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                else
                    DirImg=dir('c*.nii.gz');  % Search .nii.gz and unzip;
                    if length(DirImg)==1
                        gunzip(DirImg(1).name);
                        delete(DirImg(1).name);
                    end
                    copyfile('c*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                end
            else
                DirImg=dir('*.img');
                if ~isempty(DirImg)
                    copyfile('*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                    copyfile('*.img',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                else
                    DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                    if length(DirImg)>=1
                        for j=1:length(DirImg)
                            gunzip(DirImg(j).name);
                            delete(DirImg(j).name);
                        end
                    end
                    copyfile('*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                end
            end
            fprintf(['Copying T1 image Files from "T1Img" to',T1ImgSegmentDirectoryName,': ',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
        
        
    else  % T1ImgCoreg exists
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg']);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            cd([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgCoreg',filesep,AutoDataProcessParameter.SubjectID{i}]);
            mkdir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
            DirImg=dir('*.img');
            if ~isempty(DirImg)
                copyfile('*.hdr',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
                copyfile('*.img',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
            else
                DirImg=dir('*.nii.gz');  % Search .nii.gz and unzip;
                if length(DirImg)>=1
                    for j=1:length(DirImg)
                        gunzip(DirImg(j).name);
                        delete(DirImg(j).name);
                    end
                end
                copyfile('*.nii',[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i}])
            end
            cd('..');
            fprintf(['Copying coregistered T1 image Files from "T1ImgCoreg":',AutoDataProcessParameter.SubjectID{i},' OK']);
        end
        fprintf('\n');
    end
    
    if AutoDataProcessParameter.IsSegment==1  %Segment
        cd([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName]);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'Segment.mat']);
            SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(SourceDir)  % Also support .nii files.
                SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
            SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name];
            [SPMPath, fileN, extn] = fileparts(which('spm.m'));
            SPMJOB.jobs{1,1}.spatial{1,1}.preproc.opts.tpm={[SPMPath,filesep,'tpm',filesep,'grey.nii'];[SPMPath,filesep,'tpm',filesep,'white.nii'];[SPMPath,filesep,'tpm',filesep,'csf.nii']};
            SPMJOB.jobs{1,1}.spatial{1,1}.preproc.data={SourceFile};
            if strcmpi(AutoDataProcessParameter.Segment.AffineRegularisationInSegmentation,'mni')   % Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni).
                SPMJOB.jobs{1,1}.spatial{1,1}.preproc.opts.regtype='mni';
            else
                SPMJOB.jobs{1,1}.spatial{1,1}.preproc.opts.regtype='eastern';
            end
            T1SourceFileSet{i} = SourceFile;
            fprintf(['Segment Setup:',AutoDataProcessParameter.SubjectID{i},' OK']);
            
            fprintf('\n');
            if SPMversion==5
                spm_jobman('run',SPMJOB.jobs);
            elseif SPMversion==8  % SPM8 compatible.
                SPMJOB.jobs = spm_jobman('spm5tospm8',{SPMJOB.jobs});
                spm_jobman('run',SPMJOB.jobs{1});
            else
                uiwait(msgbox('The current SPM version is not supported by PresurgMap. Please install SPM5 or SPM8 first.','Invalid SPM Version.'));
                Error=[Error;{['Error in Segment: The current SPM version is not supported by PresurgMap. Please install SPM5 or SPM8 first.']}];
            end
            
        end
        
    elseif AutoDataProcessParameter.IsSegment==2  %New Segment in SPM8
        
        T1SourceFileSet = cell(AutoDataProcessParameter.SubjectNum,1); % Save to use in the step of DARTEL normalize to MNI
        cd([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName]);
        parfor i=1:AutoDataProcessParameter.SubjectNum
            
            SPMJOB = load([ProgramPath,filesep,'Jobmats',filesep,'NewSegment.mat']);
            [SPMPath, fileN, extn] = fileparts(which('spm.m'));
            for T1ImgSegmentDirectoryNameue=1:6
                SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.tissue(1,T1ImgSegmentDirectoryNameue).tpm{1,1}=[SPMPath,filesep,'toolbox',filesep,'Seg',filesep,'TPM.nii',',',num2str(T1ImgSegmentDirectoryNameue)];
                SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.tissue(1,T1ImgSegmentDirectoryNameue).warped = [0 0]; % Do not need warped results. Warp by DARTEL
            end
            if strcmpi(AutoDataProcessParameter.Segment.AffineRegularisationInSegmentation,'mni')   % Use different Affine Regularisation in Segmentation: East Asian brains (eastern) or European brains (mni).
                SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.warp.affreg='mni';
            else
                SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.warp.affreg='eastern';
            end
            
            SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.img']);
            if isempty(SourceDir)  % Also support .nii files.
                SourceDir=dir([AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*.nii']);
            end
            SourceFile=[AutoDataProcessParameter.DataProcessDir,filesep,T1ImgSegmentDirectoryName,filesep,AutoDataProcessParameter.SubjectID{i},filesep,SourceDir(1).name];
            
            SPMJOB.matlabbatch{1,1}.spm.tools.preproc8.channel.vols={SourceFile};
            T1SourceFileSet{i} = SourceFile;
            fprintf(['Segment Setup:',AutoDataProcessParameter.SubjectID{i},' OK\n']);
            spm_jobman('run',SPMJOB.matlabbatch);
        end
        
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Warp the standerd RSN templates(SMN/LN) into individual RSN templates
%HHY 20150508
homeHM = ([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
homeSegment = ([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment']);
mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'individual_RSN_template']);
homeDat = ([AutoDataProcessParameter.DataProcessDir,filesep,'individual_RSN_template']);
[ProgramPath, fileN, extn] = fileparts(which('PreSurgMappProcessing_main.m'));

for i =1:AutoDataProcessParameter.SubjectNum
    
    
    mkdir([homeDat,filesep,AutoDataProcessParameter.SubjectID{i}]);
    
    %-----------------------------------------------------------------------
    % Job configuration created by cfg_util (rev $Rev: 4252 $)
    %-----------------------------------------------------------------------
    snmatFile=dir([homeSegment,filesep,AutoDataProcessParameter.SubjectID{i},filesep, '*_seg_sn.mat']);
    meanFile = dir([ homeHM,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii']);
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = {[homeSegment,filesep,AutoDataProcessParameter.SubjectID{i},filesep, snmatFile.name]};
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox = [NaN NaN NaN];
    matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb = [NaN NaN NaN
        NaN NaN NaN];
    matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {[homeHM,filesep,AutoDataProcessParameter.SubjectID{i},filesep,meanFile.name,',1']};
    matlabbatch{1}.spm.util.defs.ofname = '';
    matlabbatch{1}.spm.util.defs.fnames = {
        [ProgramPath,filesep,'RSN_Templates',filesep,'groupICA55(21)_binary.img,1']
        [ProgramPath,filesep,'RSN_Templates',filesep,'PositiveBinaryMask_template_languageFDR001.img,1']};
    
    
    matlabbatch{1}.spm.util.defs.savedir.saveusr = {[homeDat,filesep,AutoDataProcessParameter.SubjectID{i}]};
    matlabbatch{1}.spm.util.defs.interp = 0;
    
    cd([homeDat,'/',AutoDataProcessParameter.SubjectID{i}]);
    save Deformation_template_to_individual_parameters
    
    % List of open inputs
    nrun = 1; % enter the number of runs here
    jobfile = {[AutoDataProcessParameter.DataProcessDir,filesep,'individual_RSN_template',filesep,AutoDataProcessParameter.SubjectID{i},filesep,'Deformation_template_to_individual_parameters.mat']};
    jobs = repmat(jobfile, 1, nrun);
    inputs = cell(0, nrun);
    for crun = 1:nrun
    end
    spm('defaults', 'FMRI');
    spm_jobman('serial', jobs, '', inputs{:});
    
end


%%  individual ICA %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (AutoDataProcessParameter.IsCalICA==1)&&(AutoDataProcessParameter.IsCalDICIICA==1)
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'DICI_ICA']);
    name = 'individualICA_rest_';
    tcn = [15:5:90];
    SmoothedDir=([AutoDataProcessParameter.DataProcessDir,filesep,'NiftiPairs']);
    ICADir=([AutoDataProcessParameter.DataProcessDir,filesep,'DICI_ICA']);
    
    %     sublisttemp=dir([SmoothedDir,filesep,'*']);
    %
    %     sublist=sublisttemp(3:end);
    for i = 1:AutoDataProcessParameter.SubjectNum
        
        mkdir([ICADir,'\',AutoDataProcessParameter.SubjectID{i}]);
        resultDir=([ICADir,'\',AutoDataProcessParameter.SubjectID{i}]);
        dataDir=([SmoothedDir,'\',AutoDataProcessParameter.SubjectID{i},'_NiftiPairs']);
        
        for tt =1:length(tcn)
            
            mkdir([resultDir,'\',name,num2str(tcn(tt))]);
            outDir=[resultDir,'\',name,num2str(tcn(tt))];
            dataDir=([SmoothedDir,'\',AutoDataProcessParameter.SubjectID{i},'_NiftiPairs']);
            
            
            % construct the structure
            appConfig=struct();
            
            % select files
            
            % [dList,dLabels]=nic_rsdd_inputData('initData',dataDir,{1});
            
            dataList=cell(1,3);
            dataList{1,1}=dataDir;
            %             dataList{1,2}=AutoDataProcessParameter.TimePoints;
            cd(dataDir);
            %         nifitipairDir=dir('NiftiPairs_*.img');
            nifitipairDir=dir('*.img');
            pictureDir=char();
            val=char();
            for ff=1:length(nifitipairDir)
                pictureDir(ff,:)=[dataDir,filesep,nifitipairDir(ff).name];
                val=pictureDir;
            end
            dataList{1,2}=length(nifitipairDir);
            dataList{1,3}=struct('name',val);
            dataLabels=ones(1,1);
            
            % [dList,dLabels]=nic_rsdd_inputData('initData',dataList,dataLabels);
            
            appConfig.AppFileList=dataList;
            appConfig.AppSubjectLabels=dataLabels;
            
            % configure the paramters of PCA
            % -------------------------------
            dataReduction=struct();
            
            dataReduction.maskType=1;
            dataReduction.maskFile='';
            
            dataReduction.pcaStepNum=1;
            dataReduction.pcsNum=tcn(tt);% the pcs number of the steps
            dataReduction.groupSize=4;
            
            dataReduction.samePCWithICA=1;
            dataReduction.scatter=struct('removeScatter',1,'scatterThreshold',0.8);
            appConfig.dataReduction=dataReduction;
            % -------------------------------end
            
            appConfig.outDir= outDir;% output dir
            appConfig.isAutomaticEstimate=0;% automatic estimate the number of component
            appConfig.compNum=tcn(tt); %The number of component
            appConfig.icaAlgorithm='Infomax';% the algorithm name
            appConfig.icaAlgorithmNo=1; % the indetcn of ICA algorithm
            appConfig.randMode={0,1,0};%{Booststrap, RandInit, Multiple order}; 1:use, 0: unuse
            appConfig.runTimes=25; % runTimes
            appConfig.outPrefix='gc'; % preditcn
            appConfig.scaleType=2; % how to scale the result: 1:calibation, 2: z-score
            
            etcntParameters=struct('MultipleRun',1,'DataReductionStep',1,'RunClustering',1,'RunAggregating',1,'RunClibration',1,'RunDeleteFolder',1);% How to do every step
            
            % run analysis
            nic_rsdd_runAnalysis(appConfig,etcntParameters);
            
            %         end
        end
    end
    
    
    %% Create individual brain mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if AutoDataProcessParameter.SliceTiming.SliceNumber==0
        AutoDataProcessParameter.SliceTiming.SliceNumber=43;
    end
    
    ICADir=([AutoDataProcessParameter.DataProcessDir,filesep,'DICI_ICA']);
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'individual_brainmask']);
    for i =1:AutoDataProcessParameter.SubjectNum
        unzip([ICADir,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'individualICA_rest_20',filesep,'output',filesep,'gc_sub001_component_ica_s1_.zip'],[ICADir,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'individualICA_rest_20',filesep,'output']);
    end
    for i =1:AutoDataProcessParameter.SubjectNum
        load ([ICADir,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'individualICA_rest_20',filesep,'gc_mask.mat']);
        a = zeros(64,64,AutoDataProcessParameter.SliceTiming.SliceNumber);
        a(mask_ind)=1;
        [data head]= rest_ReadNiftiImage([ICADir,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'individualICA_rest_20',filesep,'output',filesep,'gc_sub001_component_ica_s1_002.hdr']);
        
        
        rest_WriteNiftiImage(a,head,[AutoDataProcessParameter.DataProcessDir,filesep,'individual_brainmask',filesep,AutoDataProcessParameter.SubjectID{i},'_mask.img']);
    end
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Calculating DICI for sensorimotor network
    name = 'individualICA_rest_';
    tcn = [15:5:90];
    %     DICI_allsubject_SMN=cell(length(AutoDataProcessParameter.SubjectNum),1);
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'DICIresult']);
    
    
    for i =1:AutoDataProcessParameter.SubjectNum
        
        ICADir=([AutoDataProcessParameter.DataProcessDir,filesep,'DICI_ICA']);
        maskDir =([AutoDataProcessParameter.DataProcessDir,filesep,'individual_brainmask']);
        SMNDir=([AutoDataProcessParameter.DataProcessDir,filesep,'individual_RSN_template']);
        DICIresultDir= ([AutoDataProcessParameter.DataProcessDir,filesep,'DICIresult']);
        ICADir=([ICADir,'\',AutoDataProcessParameter.SubjectID{i}]);
        maskDir =([maskDir ,'\',AutoDataProcessParameter.SubjectID{i},'_mask.hdr']);
        SMNDir=([SMNDir ,'\',AutoDataProcessParameter.SubjectID{i},'\','wgroupICA55(21)_binary.hdr']); % ��
        DICIresultDir=([DICIresultDir ,'\',AutoDataProcessParameter.SubjectID{i},'_DICI_SMN']);
        
        
        
        % note: this binary mask is already intersected with MICA_brain_mask
        [dataSMN headSMN] = rest_ReadNiftiImage(SMNDir); %  individual PreSurgMapp directory
        
        % read brain mask file in MICA (MICA_brain_mask)
        [dataMask headMask] = rest_ReadNiftiImage(maskDir);  % individual brainmask
        
        for tt =1:length(tcn)
            
            homeDir =[ICADir,'\',name,num2str(tcn(tt))];
            
            cd([homeDir,'\','output']);
            mkdir('temp');
            unzip('gc_sub001_component_ICA_s1_.zip','temp\');
            cd('temp');
            a = dir('gc_sub001_component_ICA_s1_*.hdr');
            
            for aa = 1:length(a)
                [data head] = rest_ReadNiftiImage(a(aa,1).name);
                % only see positive IC value, put negative to 0. binary the ICA map
                temp = zeros(64,64,AutoDataProcessParameter.SliceTiming.SliceNumber); % different centre has different z!
                temp(find((data)>1.2)) = 1;
                
                % next will do cluster size thresholding
                [L Num] = bwlabeln(temp,18);
                for nn = 1:Num
                    clusterSizeAll(nn,1) = length(find(L==nn));
                end
                smallClusterID = find(clusterSizeAll<20); % cluster threshold set to be 20
                for bb = 1:length(smallClusterID)
                    temp(find(L==smallClusterID(bb)))=0;
                end
                data = temp;
                
                
                % 1. hit rate
                temp1 = length(find(data.*dataSMN))/length(find(dataSMN));
                
                % 2. faulse alarm rate
                temp = zeros(64,64,AutoDataProcessParameter.SliceTiming.SliceNumber);
                temp(find(dataSMN==0)) = 1;
                temp(find(dataMask==0)) = 0;
                temp2 = length(find(data.*temp))/length(find(temp));
                
                % 3. dprime calc
                gof = (icdf('Normal',temp1,0,1))-(icdf('Normal',temp2,0,1)); % dprime calc
                gof2(aa,1) = gof;
                clear temp*
                
            end
            
            diciAll{tt,1} = gof2;
            % cal first and second largest, and calc the difference between them
            temp = diciAll{tt,1};
            [val ind]=sort(temp,'descend');
            valAll(tt,1)=val(1);
            valAll(tt,2)=val(2);
            %         valAll(tt,3)=val(3);
            %         valAll(tt,4)=val(4);
            %         differenceAll(tt,1)= valAll(tt,1)-valAll(tt,2);
            %         differenceAll(tt,2)= valAll(tt,2)-valAll(tt,3);
            %         differenceAll(tt,3)= valAll(tt,3)-valAll(tt,4);
            indAll(tt,1)=ind(1);
            indAll(tt,2)=ind(2);
            %         indAll(tt,3)=ind(3);
            %         indAll(tt,4)=ind(4);
            
            clear val ind temp
            clear gof gof2
            cd ..
        end
        finalResult_SMN=[tcn' indAll(:,1) valAll(:,1) indAll(:,2) valAll(:,2)];
        %         DICI_allsubject_SMN{i,1}=finalResult_SMN;
        temp=finalResult_SMN(:,3);
        [value index]=sort(temp,'descend');
        
        ThebiggestDICI_SMN = finalResult_SMN(index(1),:);
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'DICIresult']);
        save([DICIresultDir], 'diciAll','finalResult_SMN', 'dataMask', 'dataSMN','ThebiggestDICI_SMN')
        
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Calculating DICI for language network
    name = 'individualICA_rest_';
    tcn = [15:5:90];
    %     DICI_allsubject_LN=cell(length(AutoDataProcessParameter.SubjectNum),1);
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'DICIresult']);
    
    
    for i =1:AutoDataProcessParameter.SubjectNum
        
        ICADir=([AutoDataProcessParameter.DataProcessDir,filesep,'DICI_ICA']);
        maskDir =([AutoDataProcessParameter.DataProcessDir,filesep,'individual_brainmask']);
        LNDir=([AutoDataProcessParameter.DataProcessDir,filesep,'individual_RSN_template']);
        DICIresultDir= ([AutoDataProcessParameter.DataProcessDir,filesep,'DICIresult']);
        ICADir=([ICADir,'\',AutoDataProcessParameter.SubjectID{i}]);
        maskDir =([maskDir ,'\',AutoDataProcessParameter.SubjectID{i},'_mask.hdr']);
        LNDir=([LNDir ,'\',AutoDataProcessParameter.SubjectID{i},'\','wPositiveBinaryMask_template_languageFDR001.hdr']);
        DICIresultDir=([DICIresultDir ,'\',AutoDataProcessParameter.SubjectID{i},'_DICI_Language']);
        
        % note: this binary mask is already intersected with MICA_brain_mask
        [dataLN headLN] = rest_ReadNiftiImage(LNDir); %  individual PreSurgMapp directory
        
        % read brain mask file in MICA (MICA_brain_mask)
        [dataMask headMask] = rest_ReadNiftiImage(maskDir);  % individual brainmask
        
        for tt =1:length(tcn)
            homeDir =[ICADir,'\',name,num2str(tcn(tt))];
            
            cd([homeDir,'\','output']);
            mkdir('temp');
            unzip('gc_sub001_component_ICA_s1_.zip','temp\');
            cd('temp');
            a = dir('gc_sub001_component_ICA_s1_*.hdr');
            
            for aa = 1:length(a)
                [data head] = rest_ReadNiftiImage(a(aa,1).name);
                % only see positive IC value, put negative to 0. binary the ICA map
                temp = zeros(64,64,AutoDataProcessParameter.SliceTiming.SliceNumber); % different centre has different z!
                temp(find((data)>1.2)) = 1;
                
                % next will do cluster size thresholding
                [L Num] = bwlabeln(temp,18);
                for nn = 1:Num
                    clusterSizeAll(nn,1) = length(find(L==nn));
                end
                smallClusterID = find(clusterSizeAll<20); % cluster threshold set to be 20
                for bb = 1:length(smallClusterID)
                    temp(find(L==smallClusterID(bb)))=0;
                end
                data = temp;
                
                
                % 1. hit rate
                temp1 = length(find(data.*dataLN))/length(find(dataLN));
                
                % 2. faulse alarm rate
                temp = zeros(64,64,AutoDataProcessParameter.SliceTiming.SliceNumber);
                temp(find(dataLN==0)) = 1;
                temp(find(dataMask==0)) = 0;
                temp2 = length(find(data.*temp))/length(find(temp));
                
                % 3. dprime calc
                gof = (icdf('Normal',temp1,0,1))-(icdf('Normal',temp2,0,1)); % dprime calc
                gof2(aa,1) = gof;
                clear temp*
                
            end
            
            diciAll{tt,1} = gof2;
            % cal first and second largest, and calc the difference between them
            temp = diciAll{tt,1};
            [val ind]=sort(temp,'descend');
            valAll(tt,1)=val(1);
            valAll(tt,2)=val(2);
            %         valAll(tt,3)=val(3);
            %         valAll(tt,4)=val(4);
            %         differenceAll(tt,1)= valAll(tt,1)-valAll(tt,2);
            %         differenceAll(tt,2)= valAll(tt,2)-valAll(tt,3);
            %         differenceAll(tt,3)= valAll(tt,3)-valAll(tt,4);
            indAll(tt,1)=ind(1);
            indAll(tt,2)=ind(2);
            %         indAll(tt,3)=ind(3);
            %         indAll(tt,4)=ind(4);
            
            clear val ind temp
            clear gof gof2
            cd ..
        end
        finalResult_LN=[tcn' indAll(:,1) valAll(:,1) indAll(:,2) valAll(:,2)];
        %         DICI_allsubject_Language{i,1}=finalResult_LN;
        temp=finalResult_LN(:,3);
        [value index]=sort(temp,'descend');
        
        ThebiggestDICI_LN = finalResult_LN(index(1),:);
        cd([AutoDataProcessParameter.DataProcessDir,filesep,'DICIresult']);
        save([DICIresultDir], 'diciAll','finalResult_LN', 'dataMask', 'dataLN','ThebiggestDICI_LN')
    end
    
    
end
%%%%%%%%%%%%%%%% Task activation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clear matlabbatch jobfile jobs
if (AutoDataProcessParameter.IsCaltaskactivation==1)&&(AutoDataProcessParameter.taskcondition==1)
    
    spm('defaults','fmri');
    spm_jobman('initcfg');
    
    % set home dir
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.taskname,'_activation']);
    homeStat =([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.taskname,'_activation']);
    homeHM = ([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    
    %     if AutoDataProcessParameter.FunctionalSessionNumber==1
    %         homeDat =([AutoDataProcessParameter.DataProcessDir,filesep,'NiftiPairs']);
    %     else
    if ~isempty(strfind(AutoDataProcessParameter.StartingDirName,'NiftiPairs'))                    % revised by HHY 20150603
        homeDat =([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    elseif AutoDataProcessParameter.FunctionalSessionNumber==1
        homeDat=([AutoDataProcessParameter.DataProcessDir,filesep,'NiftiPairs']);
    elseif AutoDataProcessParameter.FunctionalSessionNumber>1
        homeDat=([AutoDataProcessParameter.DataProcessDir,filesep,'S2_NiftiPairs']);
    end
    
    % get subName
    subNametemp = dir([homeDat,filesep,'*']);
    subName= subNametemp(3:end);
    
    %% loop for subject
    for subID =1:length(subName)
        %-----------------------------------------------------------------------
        % Job configuration created by cfg_util (rev $Rev: 4252 $)
        %-----------------------------------------------------------------------
        % batchID1 = 1+(subID-1)*3;  %% this is the 1st batch -- model specify
        mkdir([homeStat,'/',subName(subID,1).name,'/']);
        matlabbatch{1}.spm.stats.fmri_spec.dir{1,1} = [homeStat,'/',subName(subID,1).name,'/'];
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cell(AutoDataProcessParameter.TimePoints,1);  %% i.e.data have 236 time points!
        
        %% 2nd loop for data points
        for tp = 1:AutoDataProcessParameter.TimePoints
            data = dir([homeDat,'/',subName(subID,1).name,'/*img']);
            matlabbatch{1}.spm.stats.fmri_spec.sess.scans{tp,1} = [homeDat,'/',subName(subID,1).name,'/',data(tp,1).name,',1'];
        end
        
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = AutoDataProcessParameter.taskname;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = AutoDataProcessParameter.taskactivation.Onset1; %% load onset
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = AutoDataProcessParameter.taskactivation.Duration1;        % duration
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
        
        %% generate rp file's full path --> HMdata
        HMsubName(subID,1).name=subName(subID,1).name(1:end-14);
        temp = dir([homeHM,'/',HMsubName(subID,1).name,'/',FunSessionPrefixSet{iFunSession},'rp_*.txt']);
        HMdata = [homeHM,'/',HMsubName(subID,1).name,'/',temp(1,1).name];
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg{1,1} = HMdata;
        matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = Inf;
        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
        
        
        % batchID2 = 2 + (subID-1)*3;  %% this is the 2nd batch -- model estimation
        
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
        matlabbatch{2}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
        
        % batchID3 = 3 + (subID-1)*3;  %% this is the 3rd batch -- contrast
        
        matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep;
        matlabbatch{3}.spm.stats.con.spmmat(1).tname = 'Select SPM.mat';
        matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name = 'filter';
        matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
        matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name = 'strtype';
        matlabbatch{3}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
        matlabbatch{3}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
        matlabbatch{3}.spm.stats.con.spmmat(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1});
        matlabbatch{3}.spm.stats.con.spmmat(1).src_output = substruct('.','spmmat');
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = AutoDataProcessParameter.taskname;
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = 1;
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 0;
        
        %% clear temperary variables
        clear temp HMdata data
        cd([homeStat,'/',subName(subID,1).name,'/']);
        save batch_job
        
        % List of open inputs
        nrun = 1; % enter the number of runs here
        jobfile = {[homeStat,'/',subName(subID,1).name,'/','batch_job.mat']};
        jobs = repmat(jobfile, 1, nrun);
        inputs = cell(0, nrun);
        for crun = 1:nrun
        end
        spm('defaults', 'FMRI');
        spm_jobman('serial', jobs, '', inputs{:});
        
    end
end



%% add two taskconditon on 2016.0915
if (AutoDataProcessParameter.IsCaltaskactivation==1)&&(AutoDataProcessParameter.taskcondition==2)
    
    spm('defaults','fmri');
    spm_jobman('initcfg');
    
    % set home dir
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.taskname,'_activation']);
    homeStat =([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.taskname,'_activation']);
    homeHM = ([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    
    if ~isempty(strfind(AutoDataProcessParameter.StartingDirName,'NiftiPairs'))                    % revised by HHY 20150603
        homeDat =([AutoDataProcessParameter.DataProcessDir,filesep,AutoDataProcessParameter.StartingDirName]);
    elseif AutoDataProcessParameter.FunctionalSessionNumber==1
        homeDat=([AutoDataProcessParameter.DataProcessDir,filesep,'NiftiPairs']);
    elseif AutoDataProcessParameter.FunctionalSessionNumber>1
        homeDat=([AutoDataProcessParameter.DataProcessDir,filesep,'S2_NiftiPairs']);
    end
    
    % get subName
    subNametemp = dir([homeDat,filesep,'*']);
    subName= subNametemp(3:end);
    
    %% loop for subject
    for subID = 1:length(subName)
        %-----------------------------------------------------------------------
        % Job configuration created by cfg_util (rev $Rev: 4252 $)
        %-----------------------------------------------------------------------
%         batchID1 = 1+(subID-1)*3;  %% this is the 1st batch -- model specify
        mkdir([homeStat,'/',subName(subID,1).name,'/']);
        matlabbatch{1}.spm.stats.fmri_spec.dir{1,1} = [homeStat,'/',subName(subID,1).name,'/'];
        matlabbatch{1}.spm.stats.fmri_spec.timing.units = 'scans';
        matlabbatch{1}.spm.stats.fmri_spec.timing.RT = 2;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t = 16;
        matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
        matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cell(AutoDataProcessParameter.TimePoints,1);  %% i.e.data have 236 time points!
        
        
        %% 2nd loop for data points
        for tp = 1:AutoDataProcessParameter.TimePoints
            data = dir([homeDat,'/',subName(subID,1).name,'/*img']);
            matlabbatch{1}.spm.stats.fmri_spec.sess.scans{tp,1} = [homeDat,'/',subName(subID,1).name,'/',data(tp,1).name,',1'];
        end
        
        % condition 1
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).name = 'cond1';
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).onset = AutoDataProcessParameter.taskactivation.Onset1;  %% load cond1 onset
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).duration = AutoDataProcessParameter.taskactivation.Duration1;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(1).pmod = struct('name', {}, 'param', {}, 'poly', {});
        
        % condition 2
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).name = 'cond2';
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).onset = AutoDataProcessParameter.taskactivation.Onset2;  %% load cond2 onset
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).duration =AutoDataProcessParameter.taskactivation.Duration2;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).tmod = 0;
        matlabbatch{1}.spm.stats.fmri_spec.sess.cond(2).pmod = struct('name', {}, 'param', {}, 'poly', {});
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi = {''};
        matlabbatch{1}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
        
        %% generate rp file's full path --> HMdata
        HMsubName(subID,1).name=subName(subID,1).name(1:end-14);
        temp = dir([homeHM,'/',HMsubName(subID,1).name,'/',FunSessionPrefixSet{iFunSession},'rp_*.txt']);  
        HMdata = [homeHM,'/',HMsubName(subID,1).name,'/',temp(1,1).name];
        matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg{1,1} = HMdata;
        matlabbatch{1}.spm.stats.fmri_spec.sess.hpf = Inf;
        matlabbatch{1}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
        matlabbatch{1}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
        matlabbatch{1}.spm.stats.fmri_spec.volt = 1;
        matlabbatch{1}.spm.stats.fmri_spec.global = 'None';
        matlabbatch{1}.spm.stats.fmri_spec.mask = {''};
        matlabbatch{1}.spm.stats.fmri_spec.cvi = 'AR(1)';
        
        
%         batchID2 = 2 + (subID-1)*3;  %% this is the 2nd batch -- model estimation
        matlabbatch{2}.spm.stats.fmri_est.spmmat{1,1} = [homeStat,'/',subName(subID,1).name,'/SPM.mat'];
        matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
        
        
%         batchID3 = 3 + (subID-1)*3;  %% this is the 3rd batch -- contrast
        matlabbatch{3}.spm.stats.con.spmmat{1,1} = [homeStat,'/',subName(subID,1).name,'/SPM.mat'];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.name = 'cond1';
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.convec = [1 0];
        matlabbatch{3}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.name = 'cond2';
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.convec = [0 1];
        matlabbatch{3}.spm.stats.con.consess{2}.tcon.sessrep = 'none';
        matlabbatch{3}.spm.stats.con.delete = 0;
        
       %% clear temperary variables
        clear temp HMdata data
        cd([homeStat,'/',subName(subID,1).name,'/']);
        save batch_job
        
        % List of open inputs
        nrun = 1; % enter the number of runs here
        jobfile = {[homeStat,'/',subName(subID,1).name,'/','batch_job.mat']};
        jobs = repmat(jobfile, 1, nrun);
        inputs = cell(0, nrun);
        for crun = 1:nrun
        end
        spm('defaults', 'FMRI');
        spm_jobman('serial', jobs, '', inputs{:});
        
    end    
end


if ~isempty(Error)
    disp(Error);
    return;
end


rest_waitbar;  % Close the rest waitbar after all the calculation.
