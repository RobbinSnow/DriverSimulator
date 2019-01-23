function msfcn_ACC_PlotSpeed(block)
setup(block);
%endfunction

function setup( block )


%% define number of input and output ports
block.NumInputPorts  = 7;
block.NumOutputPorts = 1;


%% port properties
block.SetPreCompInpPortInfoToDynamic;
block.SetPreCompOutPortInfoToDynamic;

block.InputPort(1).Complexity = 'real'; % engine
block.InputPort(1).DataTypeId = 0; %real
block.InputPort(1).SamplingMode = 'Sample';
block.InputPort(1).Dimensions = 1;

block.InputPort(2).Complexity = 'real'; % velocity
block.InputPort(2).DataTypeId = 0; %real
block.InputPort(2).SamplingMode = 'Sample';
block.InputPort(2).Dimensions = 1;

block.InputPort(3).Complexity = 'real'; % brake
block.InputPort(3).DataTypeId = 0; %real
block.InputPort(3).SamplingMode = 'Sample';

block.InputPort(4).Complexity = 'real'; % throttle
block.InputPort(4).DataTypeId = 0; %real
block.InputPort(4).SamplingMode = 'Sample';

block.InputPort(5).Complexity = 'real'; % HWT flag
block.InputPort(5).DataTypeId = -1; %inherited
block.InputPort(5).SamplingMode = 'Sample';

block.InputPort(6).Complexity = 'real'; % HWT percentage
block.InputPort(6).DataTypeId = -1; %inherited
block.InputPort(6).SamplingMode = 'Sample';

block.InputPort(7).Complexity = 'real'; % lead car velocity
block.InputPort(7).DataTypeId = 0; %real
block.InputPort(7).SamplingMode = 'Sample';

block.OutputPort(1).Complexity = 'real'; % ACC button
block.OutputPort(1).DataTypeId = 0; %real
block.OutputPort(1).SamplingMode = 'Sample';
block.OutputPort(1).Dimensions   = 1;

%% Register parameters
block.NumDialogPrms     = 2;
dfreq = block.DialogPrm(1).Data;

%% block sample time
block.SampleTimes = [1/dfreq 0];

%% register methods
block.RegBlockMethod('PostPropagationSetup', @DoPostPropSetup);
block.RegBlockMethod('Start', @Start);
block.RegBlockMethod('Outputs', @Outputs);

%% Block runs on TLC in accelerator mode.
block.SetAccelRunOnTLC(true);
%endfunction

function DoPostPropSetup( block )
    block.NumDworks = 1;
	block.Dwork(1).Name = 'handles';
	block.Dwork(1).Dimensions = 11;
	block.Dwork(1).DatatypeID = 0;
	block.Dwork(1).Complexity = 'Real';  
%endfunction

function Start(block)

block.OutputPort(1).Data = 1;
if block.DialogPrm(2).Data % Display switch ON / OFF
    try%#ok<TRYNC>
        close (ACC_PlotSpeed)
    end
    
    h_dlg        = ACC_PlotSpeed;
    h_speed      = findobj(h_dlg, 'Tag', 'text_speed');
    h_engine     = findobj(h_dlg, 'Tag', 'text_engine_speed');
    h_brake      = findobj(h_dlg, 'Tag', 'text_brake');
    h_throttle   = findobj(h_dlg, 'Tag', 'text_throttle');
    h_acc_panel  = findobj(h_dlg, 'Tag', 'acc_panel');
    h_acc_button = findobj(h_dlg, 'Tag', 'acc_button');
    h_hwt_text   = findobj(h_dlg, 'Tag', 'hwt_text');
    h_text_lead  = findobj(h_dlg, 'Tag', 'text_lead');
    h_lead_text  = findobj(h_dlg, 'Tag', 'lead_text');
    h_lead_text2 = findobj(h_dlg, 'Tag', 'lead_text2');
    
    block.Dwork(1).Data = [double(h_dlg) double(h_speed) double(h_engine) double(h_brake) double(h_throttle) double(h_acc_panel)...
        double(h_acc_button) double(h_hwt_text) double(h_text_lead) double(h_lead_text) double(h_lead_text2)];
    %endfunction Start
end


function Outputs(block)
h_speed      = block.Dwork(1).Data( 2);
h_engine     = block.Dwork(1).Data( 3);
h_brake      = block.Dwork(1).Data( 4);
h_throttle   = block.Dwork(1).Data( 5);
h_acc_panel  = block.Dwork(1).Data( 6);
h_acc_button = block.Dwork(1).Data( 7);
h_hwt_text   = block.Dwork(1).Data( 8);
h_text_lead  = block.Dwork(1).Data( 9);
h_lead_text  = block.Dwork(1).Data(10);
h_lead_text2 = block.Dwork(1).Data(11);

% Setting Strings on gui
set(h_engine,   'String', num2str(block.InputPort(1).Data));
set(h_speed,    'String', num2str(block.InputPort(2).Data));
set(h_brake,    'String', num2str(block.InputPort(3).Data));
set(h_throttle, 'String', num2str(block.InputPort(4).Data));

if logical(get(h_acc_button,'Value'))
    
    % Show right text on button
    set(h_acc_button,'String','ACC OFF ');
    
    % Highlighting panel and showing lead car speed, if potentially dangerous object is noticed
    if logical(block.InputPort(7).Data) || logical(block.InputPort(5).Data)
        set(h_acc_panel, 'ForegroundColor', [0 0.5 0]);
        set(h_text_lead, 'ForegroundColor', [0 0 0]);
        set(h_text_lead, 'String',num2str(block.InputPort(7).Data));
        set(h_lead_text, 'ForegroundColor', [0 0 0]);
        set(h_lead_text2,'ForegroundColor', [0 0 0]);
    else
        set(h_acc_panel, 'ForegroundColor',[0 0 0]);
        set(h_text_lead, 'ForegroundColor', [0.902 0.902 0.902]);
        set(h_text_lead, 'String','___');
        set(h_lead_text, 'ForegroundColor', [0.902 0.902 0.902]);
        set(h_lead_text2,'ForegroundColor', [0.902 0.902 0.902]);
    end
    
    % If HWT flag is high, show 'HWT' string and change the other colors
    if logical(block.InputPort(5).Data) && block.InputPort(6).Data
        set(h_hwt_text, 'ForegroundColor',[1 0 0]);
        set(h_acc_panel,'ForegroundColor',[1 0 0]);
        set(h_acc_panel,'ShadowColor',[1 0 0]);
        set(h_acc_panel,'HighlightColor',[1 0 0]);
    else
        set(h_hwt_text, 'ForegroundColor',[0.902 0.902 0.902]);
        set(h_acc_panel,'ShadowColor',    [0.5 0.5 0.5]);
        set(h_acc_panel,'HighlightColor', [0.502 0.502 0.502]);
    end
    
else
    % Show right text on the button
    set(h_acc_button,'String','ACC ON');
    
    
    % Hide ACC panel
    set(h_acc_panel, 'ForegroundColor',[0.502 0.502 0.502]);
    set(h_acc_panel, 'HighlightColor', [0.502 0.502 0.502]);
    set(h_acc_panel, 'ShadowColor',    [0.5 0.5 0.5]);
    set(h_hwt_text,  'ForegroundColor',[0.902 0.902 0.902]);
    set(h_text_lead,  'ForegroundColor', [0.902 0.902 0.902]);
    set(h_text_lead,  'String','___');
    set(h_lead_text, 'ForegroundColor', [0.902 0.902 0.902]);
    set(h_lead_text2,'ForegroundColor', [0.902 0.902 0.902]);
    
end

block.OutputPort(1).Data = get(h_acc_button,'Value');

%endfunction Outputs
