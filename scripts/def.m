%t = tempdir
%clear all;
setenv('TMP','/data2/neugebauer/tmp');

addpath('fieldtrip', 'fieldtrip/fieldtrip-master', 'beamformer_toolbox', 'toolboxesAndScripts/NIFTI_20100819/' , 'beamformer_toolbox/g2','beamformer_toolbox/connectivity/', 'beamformer_toolbox/linspecer' , 'beamformer_toolbox/subs', 'beamformer_toolbox/subs/plot','beamformer_toolbox/dualcore', 'beamformer_toolbox/information');
addpath('toolboxesAndScripts/rudy Moddemeijer entropy/');
ft_defaults;
format long g
clc;