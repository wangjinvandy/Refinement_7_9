%%%This script takes me about 24 minutes to create the matched age&gender
%%%template. It calls the afni function in the final step to create a mask
%%%for it, which is used in the preprocessing scripts (coreg_check). So
%%%make sure when you run it, load the afni. Make sure the com and ARESLab
%%%is put under toolbox of spm12.
%written by Jin Wang 5/2/2019

%define your demographic parameters from your project
%age in months
age=[84 84 84 84 85 85 85 85 86 86 86 86 87 87 87 87 88 88 88 88 89 89 89 89 90 90 90 90 91 91 91 91 92 92 92 92 93 93 93 93 ...
    94 94 94 94 95 95 95 95 96 96 96 96 97 97 97 97 98 98 98 98 99 99 99 99 100 100 100 100 101 101 101 101 102 102 102 102 ...
    103 103 103 103 104 104 104 104 105 105 105 105 106 106 106 106 107 107 107 107 108 108 108 108 109 109 109 109 110 110 110 110 ...
    111 111 111 111 112 112 112 112 113 113 113 113 114 114 114 114 115 115 115 115 116 116 116 116 117 117 117 117 118 118 118 118 ...
    119 119 119 119 120 120 120 120 121 121 121 121 122 122 122 122 123 123 123 123 124 124 124 124 125 125 125 125 126 126 126 126];
fprintf('the number of subjects"s age you put in is %d\n',size(age,2));
%gender, 0 male, 1 female.
gender=[1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 ...
    1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 ...
    1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 ...
    1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0  1 1 0 0 1 1 0 0  1 1 0 0 ...
    1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0 1 1 0 0];
fprintf('the number of subjects"s gender you put in is %d\n',size(gender,2)); 
numsubjects=172;
out='/dors/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/temlates_cerebroMatic';
addpath(genpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12_elp'));
mat='/dors/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/templates_cerebroMatic/files/com_parameters_unified_segmentation/mw_com_info.mat';


%%%%%%%%%%%%%%%%%%%%%do not modify this%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%test the input 
field=repmat(3,1, numsubjects);
if size(age,2)~=numsubjects || size(gender,2)~=numsubjects
    error('your input is wrong')
end

%The parameters needed to run the mw_com_gen.m, all of the followings are
%default numbers. You shouldn't modify them unless you know what you want.
x=load(mat);
domean=1;
smo=-2;
sanlm=0;
mrf=0;
outfile=2;
predicts_n=[];
num=numsubjects;
predicts_n(1,:)=age;
predicts_n(2,:)=gender;
predicts_n(3,:)=field;
predicts_n(4,:)=ones(1, num) .* (min(x.predicts_o(4,:)) + eps); % it seems this weights value will always be 13.3375;

%run the mw_com_gen function to generate pediatric template using already
%estiamted unified segmentation.mat file downloaded from
%https://www.medizin.uni-tuebingen.de/kinder/en/research/neuroimaging/software/
mw_com_gen(mat, predicts_n, domean, smo, sanlm, mrf, out, outfile);

%make a mask for T1 template, this is an AFNI command, so you need to make
%sure you have loaded the AFNI
%cd(out)
system(['3dcalc -a mw_com_T1* -expr "step(a)" -prefix mask_ICV.nii'])

