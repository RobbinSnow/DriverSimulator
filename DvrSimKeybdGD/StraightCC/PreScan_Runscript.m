%% ExperimentRamp_Runscript
% step 1: set the PreScan Scene Struct: Run.Settings ={'SlopeAngle', [0,5,10,15,20,25,30]}
% step 2: start CarSim and check dataset valid
% step 3: read the experiment description, get the string and change to array: testcase='CCC={30-30,60-60,90-90,120-120};ACC={60-60,30-120,120-30};
% step 4: use for loop to set the dos command string
% step 5: run the dos command
% step 6; save data to Excel
% step 7: close experiment and prepare for python call another script

%% init
% PreScan project name
mdlName = 'StraightCC_cs';
% make sure previous settings are ignored.
clear Results Run;
myDictionaryDesignData;% load SFunction datadictionary
MotorPara;% Load EP21 motor data

%% step 1: set the PreScan Scene Struct
% parameters needed to be changed in PreScan
Run.Settings = {'SlopeAngle', 0};

%% step 2: start CarSim and check dataset valid
disp('starting CarSim...')
h = actxserver('CarSim.Application');% get the  handle of CarSim Application
if h.DataSetExists('CarSim Run Control','EP21_ADAS_SIL','EP21_ADAS')&&h.DataSetExists('Procedures','FlatGround','EP21_ADAS_SIL')% if dataset exit? 
    CarSimFlag = 1;
    h.Gotolibrary('CarSim Run Control','EP21_ADAS_SIL','EP21_ADAS');% exit,then go to the CarSim SIL Dataset
    h.Gotolibrary('Procedures','FlatGround','EP21_ADAS_SIL');
    h.GoHome();
    disp('success loading CarSim Application Data');
    disp('PreScan initializing...');
else
    CarSimFlag = 0;
    disp('No Refrence Dataset in  CarSim, please check CarSim dataset and library');
end

%% step 3: read the testcase description txt, get the string and change to array
% model=prescan.experiment.readDataModels();% get PreScan data model API
f = fopen('Testcases.txt');
testcase = textscan(f,'%s');
fclose(f);
testcaseCell = testcase{1};
CCCFlag = 0;CCCArray = [];% CCC tested?
ACCFlag = 0;Array = [];% ACC tested?
LKAFlag = 0;LKAArray = [];% LKA tested?
% testcase='CCC={30-30,60-60,90-90,120-120};ACC={60-60,30-120,120-30};';
for i = 1:length(testcaseCell)
    testcaseString = testcaseCell{i};
    if ~isempty(regexp(testcaseString,'CCC', 'once'))
        CCCFlag = 1;
        CCCArray = String2Number(testcaseString);
    else if ~isempty(regexp(testcaseString,'ACC', 'once'))
            ACCFlag = 1;
            Array = String2Number(testcaseString);
            else if ~isempty(regexp(testcaseString,'LKA', 'once'))
                LKAFlag = 1;
                LKAArray = String2Number(testcaseString);
                end
        end
    end
end
CCCCaseNo = length(CCCArray)/2;
CCCCasei = 1;
ACCCaseNo = length(Array)/2;
ACCCasei = 1;
LKACaseNo = length(LKAArray)/2;
LKACasei = 1;
TestcaseNo = CCCCaseNo + ACCCaseNo + LKACaseNo;

%% step 4: use for-loop to set the dos command string
% disp('Setting-up variables...');
% disp('------------------------');
ExeName = 'PreScan.CLI.exe';
ExperimentName = 'StraightCC';
MainExperiment = pwd;
ExperimentDir = [pwd '\..'];
% ResultsDir = [MainExperiment '\Results\ExperimentRamp_' sprintf('%04.0f%02.0f%02.0f_%02.0f%02.0f%02.0f',clock)];

% Number of simulations for each scenario
SceneNo = length(Run.Settings{2});
% Number of beams on the TIS sensor (as defined in the Experiment Editor).
% NumBeams = 3;
% Results(NrOfRuns).Data = []; % Preallocate results structure.
% disp(['Scheduling ' num2str(NrOfRuns) ' simulations...']);
% disp('-------------------------');
myDictionaryDesignData % loading datadictionary
if CarSimFlag&&(CCCFlag||ACCFlag||LKAFlag)% if CarSim OK and Testcases OK  
    for i = 1:SceneNo
        disp(['Scene: ' num2str(i) '/' num2str(SceneNo)]);
        RunModel='StraightCC_cs';
        Command = ExeName;
        Command = [Command ' -load ' '"' MainExperiment '"'];
        tag = Run.Settings{1};
        val = num2str(Run.Settings{2}(i), '%50.50g');
        Command = [Command ' -set ' tag '=' val];
        Settings(end+1) = cellstr([tag ' = ' val]);
        Command = [Command ' -realignPaths'];
        Command = [Command ' -build'];    
        Command = [Command ' -close'];
        %%
        % Execute the command (creates altered PreScan experiment).
%------------------------------------------------------------------------        
        CCCCasei = 1;
        while CCCCasei<=CCCCaseNo
            disp('Now CCC is under test...');
            ADASID=1;%ADAS test ID,1 for normal CCC
            V0=CCCArray(2*CCCCasei-1);%init Spd for CCC
            disp(strcat('CCC init Spd is:',num2str(V0)));
            V1=CCCArray(2*CCCCasei);%final Spd for CCC
            disp(strcat('CCC final Spd is:',num2str(V1)));
            CCCDuration=5;%time interval between Spd change demands
            
            VPIDIn=CCCArray(2*CCCCasei-1);% init Vx of testcase, for PID controller before DCU come into force
            VToleranceIn = 1;% Vx Error Tolerance in kph
            VDurationIn = 2;% Vx steady time in PID controller in sec
            VAccuracyIn = 0.8;% Vx Accuracy in VDuration time in percent         
            
            disp('CarSim sending to MATLAB');
            h.Gotolibrary('Procedures','FlatGround','EP21_ADAS_SIL');% CarSim goto the specified library
            h.Unlock();% CarSim unlock dataset           
            h.Yellow('*SPEED',num2str(VPIDIn));% set init Vx in CarSim
            h.GoHome();% CarSim goto homepage
            h.RunButtonClick(2);% click CarSim send to Simulink button, to generate the refreshed simfile
            configureMatlabForPrescan;
            dos(Command);% use dos command to control PreScan: load parse build close......
            % for more dos commands, using dos to open PreScan to see the
            % function reference help
%             SimPreScan(RunModel);
            disp('PreScan Simulink model regenerating...')
            open_system(RunModel);
            % Regenerate compilation sheet.
            regenButtonHandle = find_system(RunModel, 'FindAll', 'on', 'type', 'annotation','text','Regenerate');
            regenButtonCallbackText = get_param(regenButtonHandle,'ClickFcn');
            eval(regenButtonCallbackText);
            % Determine simulation start and end times (avoid infinite durations).
            activeConfig = getActiveConfigSet(RunModel);
            startTime = str2double(get_param(activeConfig, 'StartTime'));
            endTime = str2double(get_param(activeConfig, 'StopTime'));
            duration = endTime - startTime;
            if (duration == Inf)
                endTime = startTime + 60;
            end
            % Simulate the new model.
            disp('PreScan Simulink model running...')
            sim(RunModel, [0 5]);
            save_system(RunModel);
            close_system(RunModel);
            
            filename=strcat('E:\EP21ADASSiLAT\Report\Data\01CCC\CCC',num2str(i*CCCCaseNo-CCCCaseNo+CCCCasei,'%03i'),'StraightSlope',num2str(val),'%Spd',num2str(CCCArray(2*CCCCasei-1)),'.xlsx');
            colname = {'Time','ACCReqSt','ACCReqVa','ACCSysSt','AEBReqSt','AEBReqVa','AEBSysSt','AVz','Ax','Ay','CanclSw','DisDecSw','DisIncSw','LockedID','LockedVx','LockedX','LockedY','MemSpd','OnSw','RsmSw','SetSpd','SetSw','SpdDecSw','SpdIncSw','Steer_SW','StrAV_SW','ToqReqSt','ToqReqVa','T_Stamp','Vx'};
            M = [Time,ACCReqSt,ACCReqVa,ACCSysSt,AEBReqSt,AEBReqVa,AEBSysSt,AVz,Ax,Ay,CanclSw,DisDecSw,DisIncSw,LockedID,LockedVx,LockedX,LockedY,MemSpd,OnSw,RsmSw,SetSpd,SetSw,SpdDecSw,SpdIncSw,Steer_SW,StrAV_SW,ToqReqSt,ToqReqVa,T_Stamp,Vx];
            xlswrite(filename,colname,1);
            xlswrite(filename,M,1,'A2');
            CCCCasei = CCCCasei + 1;
        end
%------------------------------------------------------------------------        
%         ACCCasei=1;
%         while ACCCasei<=ACCCaseNo
% 
%         end
%------------------------------------------------------------------------        
%         ACCCasei=1;
%         while LKACasei<=LKACaseNo
% 
%         end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
%         errorCode = dos(Command);
%         if errorCode ~= 0
%             disp(['Failed to perform command: ' Command]);
%             continue;
%         end

        % Navigate to new experiment.
%         cd(ResultDir);
        
%         Results(i).Data = simout;

        % Store current settings to file.
%         fileID = fopen([ResultDir '\settings.txt'],'wt');
%         for line=1:length(Settings)
%             fprintf(fileID, '%s\n',char(Settings(line)));
%         end
%         fclose(fileID);

        % Store results to file.
%         ResultFileDir = [ResultDir '\Results\'];
%         [mkDirStatus,mkDirMessage,mkDirMessageid] = mkdir(ResultFileDir);
%         resultFileName = [ResultFileDir 'simout.mat'];
%         save(resultFileName,'simout');

        %Close the experiment

    end
else
    disp('No Testcases Required')
end

%% Clear CarSim handle
clear h

%% Create figure to plot results in.
% figWidth = 0.8;
% figHeight = 0.5;
% figX = 0.05;
% figY = 1.0-figHeight-0.1;
% resultImg=figure(...
%     'Visible', 'off',...
%     'Units','normalized',...
%     'Position',[figX figY figWidth figHeight],...
%     ...%'Menubar', 'none',...
%     'Name', 'TIS Beam hitcounts',...
%     'NumberTitle', 'off'...
% );
% 
% for i = 1:NrOfRuns
%     runResult = Results(i).Data;
%     
%     % Skip non-existant results.
%     if isempty(runResult)
%         continue;
%     end
%     
%     % Add results to the figure.
%     detectedRows = find(runResult(:,2));        
%     subplot(1, NrOfRuns, i);
%     hist(runResult(detectedRows,1), 1:1:NumBeams);
%     set(findobj(gca,'Type','patch'),'FaceColor','r');
%     histTitle = ['Run ' num2str(i, '%03i')];
%     title(histTitle,'FontName','FixedWidth');
%     xlabel('Beam ID');
%     ylabel('');
% end
% 
% % Show the figure
% set(resultImg, 'Visible', 'on');
% 
% %% Load main experiment to restore experiment repository
% cd(MainExperiment);
% Command = ExeName;
% Command = [Command ' -load ' '"' MainExperiment '"' ' -close'];
% dos(Command);
% 
% %% Clean up workspace
% clear Command ExeName ExperimentDir ExperimentName MainExperiment NumBeams ResultDir ResultFileDir RunModel RunName activeConfig detectedRows duration endTime startTime errorCode figHeight figWidth figX figY fileID i j line regenButtonCallbackText regenButtonHandle resultFileName runResult simout tag val Settings tout;
