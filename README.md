# PreSurgMapp
PreSurgMapp is a toolbox for pipelined processing dedicated to individualized presurgical mapping of eloquent functional areas based on multimodal functional MRI.

The current release is PreSurgMapp v2.0.

Set up and Start:

1. Simply add the path to MATLAB just like SPM.

2. Enter "PreSurgMapp" in MATLAB command window (no quotation marks).


New Features of PreSurgMapp v2.0

1. An input box for user to adjust the level of smoothing (FWHM) is added.

2. Provide three types of individual-level ICA analyses for users to choose. For task fMRI, Traditional ICA (task) can be used. For rs-fMRI, both Traditional ICA (rest) and ICA with DICI (rest) can be used. There is a difference between Traditional ICA (rest) and ICA with DICI (rest), Traditional ICA (rest) is intended for users who have a strong hypothesis on the pattern of the target component and want to set the number of components by themself (i.e., 50), while ICA with DICI (rest) will be fully-automatic as long as the user have a template at hand. It uses multiple settings of the number of components and utilizes an automatic component identification method based on discriminability-index. All the components from multiple ICA runs with multiple number of component settings are ranked and the best component. Thus, the identification of target component will be less biased, and the problem of inconsistency due to the preset number of components can be avoided. 

3. For ICA with DICI (rest), a set of commonly used templates, e.g., sensorimotor, language, etc. are provided for convenience. 
4. Support task activation analysis with more than one condition (two conditions).

5. More parameter templates are added (incuding  "Calculate Traditional ICA (rest) only",  "Calculate Traditional ICA (task) only", "Calculate ICA with DICI (rest) only" and  "Calculate Task activation only").

6. The processing steps can be freely skipped or combined.	


Help and Bug Report:

Please refer to http://www.restfmri.net.

Copyright(c) 2014; GNU GENERAL PUBLIC LICENSE
Zhejiang Key Laboratory for Research in Assessment of Cognitive Impairments,Center for Cognition and Brain Disorder, Hangzhou Normal University, China
Mail to Author:  Hui-Yuan Huang < missy139@163.com>
-----------------------------------------------------------
Citing Information:
Zhang H., Jia W.B., Liao W., Zang Y.F., 2013. Automatic component identification method based on normalized sensitivity/specificity measurement. OHBM 2013. Seattle, US.

Acknowledgement:
Several processing functions in PreSurgMapp v2.0 was modified from SPM8, REST (Song et al., 2009), DPARSF (Yan and Zang et al., 2010) and MICA (Zhang et al., 2010).


