clear

mdl = 'my_bldc_controller';
load_system(mdl)
mws = get_param(mdl, 'ModelWorkspace');
here = fileparts(mfilename('fullpath'));
load(fullfile(here, 'linearisation_results.mat'), 'sysAvg')  % inner plant: volts -> wheel rpm (run linearise_bldc first)

% inner speed PI, gains read from the model
innerPid = [mdl '/BLDC Motor with Speed Control/Controller/PID Controller'];
Cin = pid(str2double(get_param(innerPid, 'P')), str2double(get_param(innerPid, 'I')));
Tspeed = feedback(Cin*sysAvg, 1);              % wheel cmd (rpm) -> wheel speed (rpm)

Jw = getVariable(mws, 'J_flywheel') + getVariable(mws, 'J_rotor');
Jb = getVariable(mws, 'J_body');

% outer PID output (rpm) -> body angle (rad). Sum1's minus cancels the
% momentum-exchange minus, so the plant gain is positive
Ts = str2double(get_param([mdl '/PID Controller'], 'SampleTime'));
G  = (2*pi/60) * Jw/(Jb + Jw) * Tspeed * tf(1, [1 0]);
Gd = c2d(G, Ts) * tf(1, [1 0], Ts);            % outer rate + the outer Unit Delay

pidTuner(Gd, 'PD')        % or 'P' / 'PID'
