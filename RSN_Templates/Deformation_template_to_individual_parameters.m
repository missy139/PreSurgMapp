function Deformation_template_to_individual_parameters(AutoDataProcessParameter)


    homeHM = ([AutoDataProcessParameter.DataProcessDir,filesep,'RealignParameter']);
    homeSegment = ([AutoDataProcessParameter.DataProcessDir,filesep,'T1ImgSegment']);
    mkdir([AutoDataProcessParameter.DataProcessDir,filesep,'individual_RSN_template']);
    homeDat = ([AutoDataProcessParameter.DataProcessDir,filesep,'individual_RSN_template']);
    mkdir([homeDat,filesep,AutoDataProcessParameter.SubjectID{i}]);
    [ProgramPath, fileN, extn] = fileparts(which('TumorProcessing_main.m'));
%-----------------------------------------------------------------------
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%-----------------------------------------------------------------------
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.matname = {[homeSegment,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'*_sn.mat' ]};
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.vox = [NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.inv.comp{1}.sn2def.bb = [NaN NaN NaN
                                                              NaN NaN NaN];
matlabbatch{1}.spm.util.defs.comp{1}.inv.space = {[homeHM,filesep,AutoDataProcessParameter.SubjectID{i},filesep,'mean*.nii,1']};
matlabbatch{1}.spm.util.defs.ofname = '';
matlabbatch{1}.spm.util.defs.fnames = {
                                       [ProgramPath,filesep,'RSN_Templates',filesep,'groupICA55(21)_binary.img,1']
                                       [ProgramPath,filesep,'RSN_Templates',filesep,'groupICA45_langauge_binary.img,1']};

                                
matlabbatch{1}.spm.util.defs.savedir.saveusr = {[homeDat,filesep,AutoDataProcessParameter.SubjectID{i}]};
matlabbatch{1}.spm.util.defs.interp = 1;

cd([homeDat,'/',AutoDataProcessParameter.SubjectID{i}]);
save Deformation_template_to_individual_parameters
