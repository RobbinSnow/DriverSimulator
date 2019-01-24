function [] = configureMatlabForPrescan(prescanInstallationFolder)
%configureMatlabForPrescan
%
%This function configure MATLAB for prescan.
%Usage: 
%1)start a windows Command Prompt
%2)call matlab with the following command:
%<path to the matlab exe> -r "cd <folder where the
%configureMatlabForPrescan is located> configureMatlabForPrescan('<prescanInstallationFolder>')"
%
%Example:
%e:\Program_Files\MATLAB\R2015b\bin\matlab.exe  -r "cd e:\3_RealTimeDev\6_Support\TAwithPythonOrMatlab\Experiment_4OneMatlab;  configureMatlabForPrescan('E:\Program_Files\PreScan\PreScan_8.5.0_official')"
%
       
if nargin < 1
    try
    error();
    catch
        disp(sprintf('ERROR!!!\nPlease give as input to the function the Prescan installation folder like:\nconfigureMatlabForPrescan(''C:/Program Files/PreScan/PreScan_8.4.0'')'));
        return
    end
end

currentFolder=pwd;

prescanInstallationFolderExist=7==exist(prescanInstallationFolder,'dir');
if ~prescanInstallationFolderExist
    error(sprintf('PreScan installation Folder does not exist.\nPlease give the correct path to the PreScan installation folder like:\nC:/Program Files/PreScan/PreScan_8.4.0'));
end
%Configure MATLAB for prescan
setenv('PRESCAN',prescanInstallationFolder);
setenv('PATH',[getenv('PRESCAN') '\bin;' getenv('PATH')]);
setenv('PYTHONPATH',[getenv('PYTHONPATH') ';' getenv('PRESCAN') '\bin\python27.zip'] );
cd(getenv('PRESCAN'));
prescan_startup();

%%Start prescan. First check if prescan is already running
[~,tasks] = system('tasklist/fi "imagename eq PreScanStart.exe"');
if isempty(strfind(tasks,'PreScanStart'))
	system([getenv('PRESCAN') '\bin\PreScanStart.exe &'])
end

cd(currentFolder);

end %End function