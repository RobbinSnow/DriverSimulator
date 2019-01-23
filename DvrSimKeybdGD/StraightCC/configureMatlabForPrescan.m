currentFolder=pwd;
prescanInstallationFolder='E:\Program Files\PreScan\PreScan_8.4.0';
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