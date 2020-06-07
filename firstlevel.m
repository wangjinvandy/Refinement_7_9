%% First level analysis, written by Jin Wang 3/15/2019
% You should define your conditions, onsets, duration, TR.
% The repaired images will be deweighted from 1 to 0.01 in the first level 
% estimation (we changed the art_redo.m, which uses art_deweight.txt as default to deweight the scans to art_redo_jin.txt, which we uses the art_repaired.txt to deweight scans).
% The difference between art_deiweghted.txt and art_repaired.txt is to the
% former one is more wide spread. It not only mark the scans which was repaired to be deweighted, but also scans around it to be deweighted.
% The 6 movement parameters we got from realignment is added into the model regressors to remove the small motion effects on data.


addpath(genpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/scripts/typical_data_analysis')); % the path of your scripts
spm_path='/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia/scripts/typical_data_analysis/spm12_elp'; %the path of spm
addpath(genpath(spm_path));

%define your data path
root='/dors/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/scaffolding_7_9_Julia';  %your project path
subjects={'5414' '5005' '5161' '5388' '5393' '5400' '5008' '5009' '5011' '5015' '5018' '5020' '5022' '5024' '5025' '5029' '5032' '5034' '5048' '5054' '5055' '5058' '5069' '5070' '5074' '5091' '5103' '5104' '5109' '5121' '5125' '5126' '5136' '5140' '5149' '5151' '5153' '5157' '5158' '5162' '5163' '5166' '5211' '5215' '5226' '5231' '5233' '5258' '5307' '5312' '5317' '5365' '5367' '5369' '5406' '5445'};
    
%%Usually you do not need to modify them if you follow the rule of the folder structure convention in the walkthrough
global CCN
CCN.session='ses*'; % the time points you want to analyze 
CCN.func_pattern='ses*'; % the name of your functional folders
analysis_folder='analysis'; % the name of your first level modeling folder
model_deweight='deweight'; % the deweigthed modeling folder, it will be inside of your analysis folder
CCN.preprocessed='preprocessed'; % your data folder
CCN.file='vs6_wtask*bold.nii'; % the name of your preprocessed data (4d)
CCN.files='vs6_wtask*bold_0*'; % the name of your preprocessed data (3d) expanded one.
CCN.rpfile='rp_*.txt'; %the movement files



%%define your task conditions, onsets
%Phon task, each run should have its own condition defined to be run.
conditions{1}={'rhyme' 'onset' 'unrelated' 'perc'};
conditions{2}={'rhyme' 'onset' 'unrelated' 'perc'};
conditions{3}={'rhyme' 'onset' 'unrelated' 'perc'};
conditions{4}={'rhyme' 'onset' 'unrelated' 'perc'};

%load onsets files, be aware of the sequence, it should be consistent with
%your conditions
a=load('/dors/gpc/JamesBooth/JBooth-Lab/BDL/ELP/batches/onsets/phon_1_rhyme.txt');
b=load('/dors/gpc/JamesBooth/JBooth-Lab/BDL/ELP/batches/onsets/phon_1_onset.txt');
c=load('/dors/gpc/JamesBooth/JBooth-Lab/BDL/ELP/batches/onsets/phon_1_unrel.txt');
d=load('/dors/gpc/JamesBooth/JBooth-Lab/BDL/ELP/batches/onsets/phon_1_perc.txt');
e=load('/dors/gpc/JamesBooth/JBooth-Lab/BDL/ELP/batches/onsets/phon_2_rhyme.txt');
f=load('/dors/gpc/JamesBooth/JBooth-Lab/BDL/ELP/batches/onsets/phon_2_onset.txt');
g=load('/dors/gpc/JamesBooth/JBooth-Lab/BDL/ELP/batches/onsets/phon_2_unrel.txt');
h=load('/dors/gpc/JamesBooth/JBooth-Lab/BDL/ELP/batches/onsets/phon_2_perc.txt');
onsets{1}(:,1)=a;
onsets{1}(:,2)=b;
onsets{1}(:,3)=c;
onsets{1}(:,4)=d;
onsets{2}(:,1)=e;
onsets{2}(:,2)=f;
onsets{2}(:,3)=g;
onsets{2}(:,4)=h;
onsets{3}(:,1)=a;
onsets{3}(:,2)=b;
onsets{3}(:,3)=c;
onsets{3}(:,4)=d;
onsets{4}(:,1)=e;
onsets{4}(:,2)=f;
onsets{4}(:,3)=g;
onsets{4}(:,4)=h;

%duration
dur=0;

%TR
TR=1.25;

%define your contrasts, make sure your contrasts and your weights should be
%matched.
contrasts={'onset_vs_perc_T1' ...
    'rhyme_vs_perc_T1' ...
    'expt_vs_perc_T1' ...
    'onset_vs_perc_T2' ...
    'rhyme_vs_perc_T2' ...
    'expt_vs_perc_T2'};
onset_vs_per=[0 1 0 -1];
rhyme_vs_per=[1 0 0 -1];
expt_vs_perc=[1 1 1 -3];

%adjust the contrast by adding six 0s into the end of each session
rp_w=zeros(1,6);
empty=zeros(1,10);
weights={[onset_vs_per rp_w onset_vs_per rp_w empty empty]...
    [rhyme_vs_per rp_w rhyme_vs_per rp_w empty empty] ...
    [expt_vs_perc rp_w expt_vs_perc rp_w empty empty] ...
    [empty empty onset_vs_per rp_w onset_vs_per rp_w] ...
    [empty empty rhyme_vs_per rp_w rhyme_vs_per rp_w] ...
    [empty empty expt_vs_perc rp_w expt_vs_perc rp_w]};

%%%%%%%%%%%%%%%%%%%%%%%%Do not edit below here%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check if you define your contrasts in a correct way
if length(weights)~=length(contrasts)
    error('the contrasts and the weights are not matched');
end

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
for i=1:length(subjects)
    fprintf('work on subject %s', subjects{i});
    CCN.subject=[root '/' CCN.preprocessed '/' subjects{i}];
    %specify the outpath,create one if it does not exist
    out_path=[CCN.subject '/' analysis_folder];
    if ~exist(out_path)
        mkdir(out_path)
    end
    
    %specify the deweighting spm folder, create one if it does not exist
    model_deweight_path=[out_path '/' model_deweight];
    if exist(model_deweight_path,'dir')~=7
        mkdir(model_deweight_path)
    end
    
    %find folders in func
    CCN.functional_dirs='[subject]/[session]/func/[func_pattern]/';
    functional_dirs=expand_path(CCN.functional_dirs);
    
    %load 6 movement parameters
    mv=[];
    rp_file=expand_path([CCN.functional_dirs '[rpfile]']);
    for i=1:length(rp_file)
        rp=load(rp_file{i});
        mv{i}=rp;
    end
    data.mv=mv;
    
    %load the functional data
    swfunc=[];
    P=[];
    for j=1:length(functional_dirs)
        P{j}=char(expand_path([functional_dirs{j} '[files]']));
        if isempty(P{j}) % if there is no expanded data, then expand the preprocessed data
            file=expand_path([functional_dirs{j} '[file]']);
            hdr = load_nii_hdr(char(file));
            nscan = hdr.dime.dim(5);
            expand_nii_scan(char(file),1:nscan);
            P{j}=char(expand_path([functional_dirs{j} '[files]']));
        end
        for ii=1:length(P{j})
            swfunc{j}(ii,:)=[P{j}(ii,:) ',1'];
        end
    end
    data.swfunc=swfunc;
    
    %pass the experimental design information to data
    data.conditions=conditions;
    data.onsets=onsets;
    data.dur=dur;
    
    %run the firstlevel modeling and estimation (with deweighting)
    mat=firstlevel(data, out_path, TR, model_deweight_path);
    origmat=[out_path '/SPM.mat'];
    %run the contrasts
    contrast(origmat,contrasts,weights);
    contrast(mat,contrasts,weights);
    
end
