function res = run_slew(mdl, outFile, stopTime)
%RUN_SLEW Run one slew of a reaction-wheel model and save decimated results.
%   res = run_slew(mdl, outFile, stopTime) loads the model MDL (it is not
%   modified on disk), turns on decimated logging of the body angle, speed
%   command, wheel speed, duty, phase currents and motor torque, runs it for
%   STOPTIME seconds and saves the results struct RES to OUTFILE.
%
%   Meant for "matlab -batch" so long runs do not block the desktop session.

arguments
    mdl (1,1) string
    outFile (1,1) string
    stopTime (1,1) double = 5
end

dec = 10;                           % keep every 10th solver step (20 us)
load_system(mdl);
cleanup = onCleanup(@() close_system(mdl, 0));

% Keep the build cache out of the project folder so a batch run and the
% desktop session never fight over slprj.
cacheDir = fullfile(tempdir, "rw_slew_cache_" + mdl);
if ~isfolder(cacheDir), mkdir(cacheDir); end
Simulink.fileGenControl('set', 'CacheFolder', cacheDir, 'CodeGenFolder', cacheDir);

% Decimate every signal that is already logged, and drop the two wide
% switching signals that are not needed here.
ports = find_system(mdl, 'FindAll', 'on', 'MatchFilter', @Simulink.match.activeVariants, ...
    'LookUnderMasks', 'all', 'FollowLinks', 'on', 'type', 'port', 'DataLogging', 'on');
for k = 1:numel(ports)
    ln = get_param(ports(k), 'Line');
    nm = "";
    if ln ~= -1, nm = string(get_param(ln, 'Name')); end
    if any(nm == ["switchPattern", "Phase Voltages"])
        set_param(ports(k), 'DataLogging', 'off');
    elseif nm == "cmd_vel"
        % Outer-loop signal: already slow, so keep every sample.
    else
        set_param(ports(k), 'DataLoggingDecimateData', 'on', ...
            'DataLoggingDecimation', num2str(dec));
    end
end

% Log the three phase currents from the inverter's existing current sensor.
inv = find_system(mdl, 'MatchFilter', @Simulink.match.activeVariants, ...
    'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'BlockType', 'Scope', 'Name', 'Three-phase currents');
if ~isempty(inv)
    ph = get_param(inv{1}, 'PortHandles');
    ln = get_param(ph.Inport(1), 'Line');
    src = get_param(ln, 'SrcPortHandle');
    set_param(src, 'DataLogging', 'on', 'DataLoggingNameMode', 'Custom', ...
        'DataLoggingName', 'Iabc', 'DataLoggingDecimateData', 'on', ...
        'DataLoggingDecimation', num2str(dec));
end

% Log the motor block's internal variables (torque) through Simscape.
bldc = find_system(mdl, 'MatchFilter', @Simulink.match.activeVariants, ...
    'LookUnderMasks', 'all', 'FollowLinks', 'on', ...
    'BlockType', 'SimscapeBlock', 'Name', 'BLDC');
set_param(mdl, 'SimscapeLogType', 'local', 'SimscapeLogDecimation', dec, ...
    'SimscapeLogName', 'simlog', 'SimscapeLogLimitData', 'off');
if ~isempty(bldc), set_param(bldc{1}, 'LogSimulationData', 'on'); end

si = Simulink.SimulationInput(mdl);
si = si.setModelParameter('StopTime', num2str(stopTime));
si = si.setModelParameter('ReturnWorkspaceOutputs', 'on');
si = si.setModelParameter('SignalLogging', 'on');
t0 = tic;
out = sim(si);
res.wallClock = toc(t0);
res.model = mdl;
res.stopTime = stopTime;

lo = out.logsout;
names = string(lo.getElementNames);
for k = 1:numel(names)
    v = lo.get(names(k)).Values;
    f = matlab.lang.makeValidName(names(k));
    res.(f).t = v.Time;
    res.(f).y = squeeze(v.Data);
    if size(res.(f).y, 1) ~= numel(v.Time), res.(f).y = res.(f).y.'; end
end

% Motor torque from the Simscape log, if the block exposes it.
try
    node = simscape.logging.findNode(out.simlog, bldc{1});
    kids = string(node.childIds);
    res.simlogVars = kids;
    cand = kids(contains(kids, "torque", 'IgnoreCase', true));
    for k = 1:numel(cand)
        s = node.(cand(k)).series;
        res.("sl_" + cand(k)).t = s.time;
        res.("sl_" + cand(k)).y = s.values;
        res.("sl_" + cand(k)).unit = string(s.unit);
    end
catch err
    res.simlogError = string(err.message);
end

% Workspace values, so the results file records what was simulated.
mw = get_param(mdl, 'ModelWorkspace');
w = mw.whos;
for k = 1:numel(w)
    val = getVariable(mw, w(k).name);
    if isnumeric(val) && isscalar(val), res.params.(w(k).name) = val; end
end

save(outFile, '-struct', 'res', '-v7.3');
fprintf('run_slew: %s, %.1f s simulated in %.0f s wall clock -> %s\n', ...
    mdl, stopTime, res.wallClock, outFile);
end
