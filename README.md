# Refinement_7_9
This is the code for paper Wang, J., Pines, J., Joanisse, M., & Booth, J. R. (2021). Reciprocal relations between reading skill and the neural basis of phonological awareness in 7-to 9-year-old children. NeuroImage, 236, 118083. 

Most of the codes needed for this paper are the same as the scaffolding_5_7 repository. https://github.com/wangjinvandy/Scaffolding_5_7 So here I only included the main codes that are different. All the subfunctions are the same as Scaffolding_5_7.

#Preprocessing:
main_phon.m is the code for preprocessing.

#Firstlevel:
firstlevel.m is the code for firstlevel modeling and estimation as well as getting contrast maps.

#Secondlevel: 
secondlevel.m is the code for getting a group level one-sample t test map for each contrast. onesample_t.m is the subfunction for secondlevel.m.

#TPM template:
mkpdtemplate_ELP3.m is the code to make a pediatric template aged from 7 years old to 10.5 years old. 

