%%
%This script was created by Professor Baxter Rogeres (VUIIS), but is heavily modified based on our lab pipeline by Jin Wang 3/7/2019 
%(1)  realignment to mean, reslice the mean. 
%(2) segment anatomical image to TPM template. We get a deformation file "y_filename" and this is used in normalisation step to normalize all the 
%    functional data and the mean functional data. 
%(3) Then we make a skull-striped anatomical T1 (based on segmentation) and coregister mean functional data (and all other functional data) to the anatomical T1. 
%(4) Smoothing. 
%(5) Art_global. It calls the realignmentfile (the rp_*.txt) to do the interpolation. This step identifies the bad volumes(by setting scan-to-scan movement 
%    mv_thresh =1.5mm and global signal intensity deviation Percent_thresh= 4 percent, any volumes movement to reference volume, which is the mean, >5mm) and repair 
%    them with interpolation. This step uses art-repair art_global.m function (the subfunctions within it are art_repairvol, which does repairment, and art_climvmnt, which identifies volumes movment to reference.
%(6) We use check_reg.m to see how well the meanfunctional data was normalized to template by visual check.
%(7) collapse all the 3d files into 4d files for saving space. You can decide whether you want to delete the product of not later.
%Before you run this script, you should make sure that your data structure is as expected.


global CCN;
addpath(genpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/scripts/typical_data_analysis')); %This is the code path
spm_path='/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/scripts/typical_data_analysis/spm12_elp'; %This is your spm path
tpm=' /dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/scripts/typical_data_analysis/ELP_7_105Template/mw_com_prior_Age_0105.nii'; %This is your template path
addpath(genpath(spm_path));
root='/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia'; %This is your project folder
subjects={'5414' '5005' '5161' '5388' '5393' '5400' '5008' '5009' '5011' '5015' '5018' '5020' '5022' '5024' '5025' '5029' '5032' '5034' '5048' '5054' '5055' '5058' '5069' '5070' '5074' '5091' '5103' '5104' '5109' '5121' '5125' '5126' '5136' '5140' '5149' '5151' '5153' '5157' '5158' '5162' '5163' '5166' '5211' '5215' '5226' '5231' '5233' '5258' '5307' '5312' '5317' '5365' '5367' '5369' '5406' '5445'};

CCN.preprocessed_folder='preprocessed'; %This is your data folder needs to be preprocessed
CCN.session='ses-9'; %This is the time point you want to analyze. If you have two time points, do the preprocessing one time point at a time by changing ses-T1 to ses-T2.
CCN.func_folder='ses-9_*'; % This is your functional folder name 
CCN.func_pattern='task*.nii'; %This is your functional data name
CCN.anat_pattern='ses-9_T1w*.nii'; %This is your anat data name


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%shouldn't be modified below%%%%%%%%%%%%%%%
% Initialize
%addpath(spm_path);
spm('defaults','fmri');
spm_jobman('initcfg');
spm_figure('Create','Graphics','Graphics');

% Dependency and sanity checks
if verLessThan('matlab','R2013a')
    error('Matlab version is %s but R2013a or higher is required',version)
end

req_spm_ver = 'SPM12 (6225)';
spm_ver = spm('version');
if ~strcmp( spm_ver,req_spm_ver )
    error('SPM version is %s but %s is required',spm_ver,req_spm_ver)
end
try 
%Start to preprocess data from here
for i=1:length(subjects)
    fprintf('work on subject %s\n', subjects{i});
    CCN.subj_folder=[root '/' CCN.preprocessed_folder '/' subjects{i}];
    out_path=[CCN.subj_folder '/' CCN.session];
    CCN.func_f='[subj_folder]/[session]/func/[func_folder]/';
    func_f=expand_path(CCN.func_f);
    for m=1:length(func_f)
        func_file{m}=expand_path([func_f{m} '[func_pattern]']);
    end
    CCN.anat='[subj_folder]/[session]/anat/[anat_pattern]';
    anat_file=char(expand_path(CCN.anat));
    
    %expand 4d functional data to 3d data
    func_vols=cell(length(func_file),1);
    for x=1:length(func_file)
        hdr = load_nii_hdr( char(func_file{x}) );
        nscan = hdr.dime.dim(5);
        expand_nii_scan(char(func_file{x}),1:nscan)
        [func_p,func_n] = fileparts(char(func_file{x}));
        func_vols{x}=cellstr(spm_select('ExtFPList',func_p, [func_n '_0.*\.nii$']));
    end
    
    % % Processing params
    % params = struct( ...
    %     'tr', tr, ...
    %     'dropvols', dropvols, ...
    %     'slorder', slorder ...
    %     );
    %
    % % Drop volumes
    % dfunc_file = drop_volumes(func_file,params);
    %
    % % Slice timing correction
    % afunc_file = slice_timing_correction(dfunc_file,params);
    
    % Motion correction
    %[rfunc_file,meanfunc_file,rp_file] = realignment(afunc_file,filt_f, out_path);
    [rfunc_file,meanfunc_file,rp_file] = realignment(func_vols, out_path);
    
    % Copy rp file to output directory
    for y=1:length(rp_file)
        copyfile(rp_file{y},out_path)
    end
    
    %Segmentation, it will write a deformation file "y_"filename.
    [deformation,seg_files]=segmentation(anat_file,tpm);
    
    %Make a no-skull T1 image from segmented product(combine
    %grey,white,csf as a mask and then apply it to T1).
    mask=mkmask(seg_files);
    anat_nn='T1_ns';
    anat_ns=no_skull(anat_file,mask,anat_nn);
    
    % Coregister to T1
    % [cmeanfunc_file,cfunc_file] = coregister( ...
    %     meanfunc_file, anat_file, filt_a, rfunc_file, out_path, 'no');
    [cmeanfunc_file,cfunc_file] = coregister( ...
        meanfunc_file, anat_ns, rfunc_file, out_path, 'no');

    %Normalise, it will add a w to the files
    %[wfunc_file]=normalise(cfunc_file,deformation);
    [wfunc_file,wfuncmean_file]=normalise(cfunc_file,deformation,cmeanfunc_file);
    
    % Spatial smoothing
    fwhm=6;
    swfunc_file = smoothing(wfunc_file,fwhm);
    
    %Art_global (identify bad volumes and repair them using interpolation), it
    %will add a v to the files. In this art_global_jin, the
    %art_clipmvmt is the movement of all images to reference.
    Percent_thresh= 4; %global signal intensity change
    mv_thresh =1.5; % scan-to-scan movement
    MVMTTHRESHOLD=5; % movement to reference,see in art_clipmvmt
    
    for ii=1:length(swfunc_file)
        swfunc_list=[];
        for jj=1:length(swfunc_file{ii})
            swfunc_list{jj}=erase(swfunc_file{ii}{jj},',1');
        end 
        art_global_jin(char(swfunc_list),rp_file{ii},4,1,Percent_thresh,mv_thresh,MVMTTHRESHOLD);
    end
    
    
    for ii=1:length(swfunc_file)
        for jj=1:length(swfunc_file{ii})
            [swfile_p,swfile_n,swfile_e]=fileparts(swfunc_file{ii}{jj});
            vswfunc_file{ii,1}{jj,:}=[swfile_p '/' insertBefore(swfile_n,1,'v') swfile_e];
        end
    end
    % Coreg check
    coreg_check(wfuncmean_file, out_path, tpm);
    
    % collapse the intermediate files
    collapse_files={wfunc_file swfunc_file vswfunc_file};
    for ii=1:length(func_vols)
        for jj=1:length(func_vols{ii})
            func_to_go=erase(func_vols{ii}{jj},",1");
            delete(func_to_go);
        end
    end
    
    for ii=1:length(collapse_files)
        for jj=1:length(collapse_files{ii})
            [func_path,func_name]=fileparts(collapse_files{ii}{jj}{1});
            func_to_collapse=erase(func_name,"_0001");
            cd(func_path);
            collapse_nii_scan([func_to_collapse '*'],func_to_collapse,func_path)
            for mm=1:length(collapse_files{ii}{jj})
                func_to_delete=erase(collapse_files{ii}{jj}{mm},",1");
                delete(func_to_delete);
            end
        end
        
    end
end
catch e
     rethrow(e)
    %display the errors
end
