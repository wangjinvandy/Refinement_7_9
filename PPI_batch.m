function gPPI_batch
%%This is the script that can run general PPI analysis. It will model all
%%the conditions in the GLM. You can have experimental contrasts either
%%within run(session) or across runs(session). To run this, make sure your
%%preprocessed functonal data are expanded.

% Parameter Structure/File Containing Parameter Structure with the following fields:
addpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PhonReading_7_9/scripts_bids/gPPI/PPPIv13');
addpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12_elp');
subjects={};
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PhonReading_7_9/data_bids.xlsx';
if isempty(subjects)
    M=readtable(data_info);
    subjects=M.subjects;
end
root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PhonReading_7_9/preproc_bids';
model_dir='analysis_T2/deweight';
VOIref='indiv_mask'; %or group_mask
seedregion='IFG_oper_onset_t2'; %IFG_oper_onset_t1 IFG_oper_rhyme_t2 IFG_oper_rhyme_t2
ROI_folder='IFG_oper_ROIs'; 
ROI_name='IFG_oper_onset_vs_perc_T2_p1_k100_roi.nii'; % IFG_oper_onset_t1_p1_k100_roi.nii IFG_oper_rhyme_t2_p1_k100_roi.nii IFG_oper_rhyme_t2_p1_k100_roi.nii
conditions={'1' 'P_O' 'P_R' 'P_SC' 'P_U'};
%   conditions: In the generalized condition-specific PPI, you should specify the conditions to
%               include in the analyses, but put a 0 or 1 in front of them to specify if
%               they must exist in all sessions.
%               For the traditional PPI, the conditions must appear in all runs to make the proper
%               contrast weighting, so no number is needed.
%               For the general PPI, the task has to occur in at least 1 run, which is
%               why you have the option. Default is that it does not have to occur in each run.
%               Examples:
%                P.Tasks = { '1' 'condition1' 'condition2'} %must exist in all sessions
%                P.Tasks = { '0' 'condition1' 'condition2'} %does not need to exist in all sessions
contrasts{1}={'P_O' 'P_SC'};
%contrasts{1}={'P_R' 'P_SC'};
%    contrasts: You should specify your interested contrast here. You can
%               specify as many contrast as you want.
%               Examples:
%               contrasts{1}={'onset' 'perc'}; If you want a contrast of onset_minus_perc.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%should not edit below%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for num=2:length(subjects)
    %    subject: the subject number
    P.subject=subjects{num};
    %    directory: either the first-level SPM.mat directory, or if you are
    %               only estimating a PPI model, then the first-level PPI
    %               directory.
    P.directory=[root '/' subjects{num} '/' model_dir];
    cd(P.directory);
    %          VOI: name of VOI file ('.nii', '.img', '.mat'). Checks for
    %               file before executing program. If you use a .mat file,
    %               it should be 3 columns containing the ijk voxel
    %               indices OR be a VOI.mat file from SPM.
    switch VOIref
        case 'indiv_mask'
            P.VOI=[root '/' ROI_folder '/'  subjects{num} '/' ROI_name];
        case 'group_mask'
            P.VOI=[root '/' ROI_folder '/' ROI_name];
    end
    
    %               **This can also be a structure. If it is a structure, there
    %               are three/four fields:
    %               VOI:    name of the VOI file ('.nii', '.img')
    %               masks:  a cell array of statistic images ('.nii', '.img') to threshold to
    %                       define subject specific ROI. Must be NxM array
    %                       (e.g. use {}) where N is either 1 or the number of sessions and M is the number of statistical
    %                       images to use to define subject specific ROI.
    %               thresh: an NxM matrix of thresholds (e.g. use []) where N is either 1 or the number of sessions and
    %                       M is the number of statistical images to threshold;
    %                       thresholds should be the statistic value (e.g. 3)
    %                       and not the significance (e.g. .05). These must
    %                       line up with the image names in the masks field.
    %               exact:  if set to 1, will find a cluster of size VOImin; VOImin must be greater than 0;
    %                       default is empty; anything other than 1 will cause this
    %                       option to be ignored.
    %               **NOTE: Using the exact option will only use the first
    %                       image in the masks field. Peak_nii.m must be in the
    %                       MATLAB path.
    %               **NOTE: each session must use the same number of images to
    %                       define the subject specific ROI.
    %               **NOTE: if N=1, then the same ROI will be used for each
    %                       session. This is recommended.
    %       Region: name of output file(s), reqires two names for analysis
    %               with two VOI, regions should be separated by a space
    %               inside the ' '. Output directory will be Region. (if 2 regions,
    %               then the two regions will be separated by a _ in the directory name.
    P.Region=['VOI_' seedregion '_gPPI'];
    %     contrast: contrast to adjust for. Adjustments remove the effect
    %               of the null space of the contrast. Set to 0 for no adjustment. Set to a
    %               number, if you know the contrast number. Set to a contrast name, if you
    %               know the name. The default is: 'Omnibus F-test for PPI Analyses'.
    P.contrast=0;
    %     analysis: specifies psychophysiological interaction ('psy');
    %               physiophysiological interaction ('phys'); or psychophysiophysiological
    %               interactions ('psyphy').
    P.analysis='psy';
    %      extract: specifies the method of ROI extraction, eigenvariate ('eig')
    %               or mean ('mean')
    P.extract='eig';
    %       method: specifies traditional SPM PPI ('trad') or generalized
    %               condition-specific PPI ('cond')
    P.method='cond';
    %     equalroi: specifies the ROIs must be the same size in all subjects
    %               NOTE: default=1 (true); set to 0 to lift the restriction
    P.equalroi=1;
    %       FLmask: specifies that the ROI should be restricted using the
    %               mask.img from the 1L statistics. NOTE: default=0.
    P.FLmask=0;
    %         VOI2: name of 2nd VOI for physiophysiological interactions ('.nii', '.img', '.mat'). Checks for
    %               file before executing program. If you use a .mat file,
    %               it should be 3 columns containing the ijk voxel
    %               indices OR be a VOI.mat file from SPM.
    %               **This can also be a structure. If it is a structure, there
    %               are three/four fields:
    %               VOI:    name of the VOI file ('.nii', '.img')
    %               masks:  a cell array of statistic images ('.nii', '.img') to threshold to
    %                       define subject specific ROI. Must be NxM array
    %                       (e.g. use {}) where N is either 1 or the number of sessions and M is the number of statistical
    %                       images to use to define subject specific ROI.
    %               thresh: an NxM matrix of thresholds (e.g. use []) where N is either 1 or the number of sessions and
    %                       M is the number of statistical images to threshold;
    %                       thresholds should be the statistic value (e.g. 3)
    %                       and not the significance (e.g. .05).These must
    %                       line up with the image names in the masks field.
    %               exact:  if set to 1, will find a cluster of size VOImin; VOImin must be greater than 0;
    %                       default is empty; anything other than 1 will cause this
    %                       option to be ignored.
    %               **NOTE: Using the exact option will only use the first
    %                       image in the masks field. Peak_nii.m must be in the
    %                       MATLAB path.
    %               **NOTE: each session must use the same number of images to
    %                       define the subject specific ROI.
    %               **NOTE: if N=1, then the same ROI will be used for each
    %                       session. This is recommended.
    %      Weights: for traditional PPI, you must specify weight vector for
    %               each task.
    P.Weights=[];
    %        Tasks: In the generalized condition-specific PPI, you should specify the tasks to
    %               include in the analyses, but put a 0 or 1 in front of them to specify if
    %               they must exist in all sessions.
    %               For the trad. approach the task must appear in all runs to make the proper
    %               contrast weighting, so no number is needed.
    %               For the cond. approach the task has to occur in at least 1 run, which is
    %               why you have the option. Default is that it does not have to occur in each run.
    %               Examples:
    %                P.Tasks = { '1' 'task1' 'task2' 'task3' 'task4' 'task5' 'task6'} %must exist in all sessions
    %                P.Tasks = { '0' 'task1' 'task2' 'task3' 'task4' 'task5' 'task6'} %does not need to exist in all sessions
    %               NOTE: In traditional PPI, specify the tasks that go with the weights.
    P.Tasks=conditions;
    %     Estimate: specifies whether or not to estimate the PPI design. 1 means to
    %               esimate the design, 2 means to estimate the design from already created
    %               regressors (must be of the OUT structure), 0 means not to
    %               estimate. Default is set to 1, so it will estimate.
    P.Estimate =1;
    %CompContrasts: 0 not to estimate any contrasts;
    %               1 to estimate contrasts;
    %               2 to only use PPI txt file for 1st level (not recommended);
    %               3 to only use PPI txt file for 1st level and estimate contrasts (not recommended);
    %               2&3 are not recommended as they potentially do not include
    %               all tasks effects in the mode. Use at your own risk.
    %               3 can not weight the contrasts based on the number of
    %               trials
    %               Default is 0.
    P.CompContrasts =1;
    %    Contrasts: cell array of tasks to create contrasts to evaluate OR it is a structure
    %               with fields Left and Right that specify the tasks on each
    %               side of the equation.
    %                 left: tasks on left side of equation or 'none'
    %                 right: tasks on right side of equation or 'none'
    %                 Weighted: from Weighted above, default is 0.
    %                 STAT: 'T' or 'F'
    %                 c: contrast vector from createVec, automatically
    %                    generated
    %                 name: name of contrast, will be defined if left blank
    %                 Prefix: prefix to the task name (optional), can be used
    %                         to select each run
    %                 Contrail: suffix after task name (e.g. parametric
    %                           modulators, different basis function)
    %                 MinEvents: must be specified and must be 1 or greater,
    %                            this tells the program how many events you need to form a
    %                            contrast. If there are fewer events, the contrast is not
    %                            created.
    %                 MinEventsPer: optional. This tells the program how many events per trial type you need to form a
    %                               contrast. If there are fewer events, the contrast is not
    %                               created. Default is MinEvents/number of
    %                               trial type in the contrast.
    %               **If left blank and CompContrasts=1, then it defines all
    %               possible T contrasts for task components and across runs.
    for i=1:length(contrasts)
        P.Contrasts(i).left=contrasts{i}(1);
        P.Contrasts(i).right=contrasts{i}(2);
        P.Contrasts(i).STAT='T';
        P.Contrasts(i).Weitghted=0;
        P.Contrasts(i).MinEvents=5;
        P.Contrasts(i).name=[contrasts{i}{1} '_minus_' contrasts{i}{2}];
    end
    %    Weighted:  Default is not to weight tasks by number of trials (0); to
    %               change this, specify which tasks should be weighted by trials.
    %               If you want to weight trials, then specify a duration longer
    %               than your events. If you have a mixed block event related
    %               design, then you can average your events based on number of
    %               trials and the blocks won't be averaged IF Weighted is set
    %               to be a number that is shorter than the block duration and
    %               longer than your events.
    %   SPMver:     SPM version used to create SPM.mat files at the first
    %               level.
    %   maskdir:    location of mask to use (optional)
    %   VOImin:     sets the minimum VOI size
    
    PPPI(P);
end


end