%% Second level analysis
%currently I only write the one sample t test and
%regression analysis, which are the two mostly used. 
%Jin Wang 3/19/2019

addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/typical_data_analysis/4secondlevel')); % the path of your scripts
spm_path='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/typical_data_analysis/spm12_elp'; %the path of spm
addpath(genpath(spm_path));

%define your data path
data=struct();
root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/preprocessed';  %your project path
subjects={'5414' '5005' '5161' '5388' '5393' '5400' '5008' '5009' '5011' '5015' '5018' '5020' '5022' '5024' '5025' '5029' '5032' '5034' '5048' '5054' '5055' '5058' '5069' '5070' '5074' '5091' '5103' '5104' '5109' '5121' '5125' '5126' '5136' '5140' '5149' '5151' '5153' '5157' '5158' '5162' '5163' '5166' '5211' '5215' '5226' '5231' '5233' '5258' '5307' '5312' '5317' '5365' '5367' '5369' '5406' '5445'};
out_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/secondlevel_onesampleT';

% find the data. If you follow the data structure and naming convention in
% the walkthrough, you won't need to change this part
global CCN;
CCN.session='ses*';
CCN.func_pattern='ses*';
analysis_folder='analysis';
model_deweight='deweight';

% choose your analysis method
test=1; %1 one-sample t test, 2 mutiple regression analysis

% if you have covariates in your second level modeling
cov=0; % 1 if you have covariates or 0 if you do not have covariates

% Ignore these following lines if you do not have covariates. 
% You do not need to comment the following information out if you put cov=0
% because it won't be read in the analysis. Only when you put
%cov=1, the following covariates will be read in the analysis.

% define your covariates of control for your one-sample t test. Or define your covariates of interest for your multiple regression
% analysis if you have covariates. 
cov_num=1; %number of your covariates
%you can define as many covariates as you want by adding name and values. 
name{1}='';
val{1}=[]; %this should be the same number as your subject numbers
% name{2}='';
% val{2}=[];

%%%%%%%%%%%%%%%%%%%%%%should not edit below %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

%Start to analyze the data from here
    
%load the contrast file path for each subject
scan=[];
for i=1:length(subjects)
deweight_spm=[root '/' subjects{i} '/' analysis_folder '/' model_deweight '/SPM.mat'];
deweight_p=fileparts(deweight_spm);
load(deweight_spm);
contrast_names=[];
scan_files=[];
for ii=1:length(SPM.xCon)
    contrast_names{ii,1}=SPM.xCon(ii).name;
    scan_files{ii,1}=[deweight_p '/' SPM.xCon(ii).Vcon.fname];
end
contrast{i}=contrast_names;
scan{i}=scan_files;
end
scans=[];
for i=1:length(scan{1})
    for j=1:length(subjects)
        scans{i}{j,1}=[scan{j}{i} ',1'];
    end
end

%make output folder for each contrast
if ~exist(out_dir)
    mkdir(out_dir);
end
cd(out_dir);
for ii=1:length(contrast{1})
    out_dirs{ii}=[out_dir '/' contrast{1}{ii}];
    if ~exist(out_dirs{ii})
        mkdir(out_dirs{ii}); 
    end
end

%covariates 
%pass the covariates to a struct
if cov==1
    covariates.name=name;
    for i=1:cov_num
     values{i}=transpose(val{i});
    end
    covariates.values=values;
else
    covariates={};
end

if test==1 % one-sample t test
    onesample_t(out_dirs,scans,covariates);
    
elseif test==2 %multiple regression analysis
    multiple_regression(out_dirs,scans,covariates);
   
end



