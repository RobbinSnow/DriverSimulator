function SimPreScan(RunModel)        
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
    sim(RunModel, [0 10]);
    save_system(RunModel);
    close_system(RunModel);
end