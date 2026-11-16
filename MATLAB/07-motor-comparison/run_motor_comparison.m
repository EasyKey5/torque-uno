function T = run_motor_comparison(Vin)
%RUN_MOTOR_COMPARISON Make a model copy per motor, run a 90 degree slew on
%each and save results, figures and a metrics table.
%   T = run_motor_comparison(Vin) uses a supply of VIN volts (default 9, the
%   empty-pack worst case). Outputs go to models/ and results/ beside this
%   file. The base model rw_averaged.slx is not changed.

arguments
    Vin (1,1) double = 9
end

here = fileparts(mfilename('fullpath'));
modelDir = fullfile(here, 'models');
resDir = fullfile(here, 'results');
if ~isfolder(modelDir), mkdir(modelDir); end
if ~isfolder(resDir), mkdir(resDir); end

M = motor_table();
thetaRef = -pi/2;
Dmax = 0.95;
runs = cell(numel(M), 1);
rows = cell(numel(M), 1);

for i = 1:numel(M)
    m = M(i);
    p = motor_params(m, Vin);
    mdl = "motor_" + m.id;
    dst = fullfile(modelDir, mdl + ".slx");

    % Copy of the simulation for this motor, with its values saved inside.
    if bdIsLoaded(mdl), close_system(mdl, 0); end
    copyfile(fullfile(here, 'rw_averaged.slx'), dst);
    load_system(dst);
    mw = get_param(mdl, 'ModelWorkspace');
    f = fieldnames(p);
    for k = 1:numel(f), assignin(mw, f{k}, p.(f{k})); end
    save_system(mdl);

    si = Simulink.SimulationInput(mdl);
    si = si.setModelParameter('ReturnWorkspaceOutputs', 'on');
    si = si.setModelParameter('StopTime', '6');
    out = sim(si);
    close_system(mdl, 0);

    lo = out.logsout;
    g = @(n) lo.get(n).Values;
    r.t = g('I_meas').Time;
    r.i = g('I_meas').Data(:);
    r.v = interp1(g('V_motor').Time, g('V_motor').Data(:), r.t, 'previous', 'extrap');
    r.w = interp1(g('Rotor_Speed').Time, g('Rotor_Speed').Data(:), r.t, 'previous', 'extrap');
    r.th = interp1(g('Body_angle').Time, g('Body_angle').Data(:), r.t, 'linear', 'extrap');
    r.iref = interp1(g('I_ref').Time, g('I_ref').Data(:), r.t, 'previous', 'extrap');
    r.name = m.name; r.p = p; r.m = m;
    runs{i} = r;

    iOut = find(abs(r.th - thetaRef) > deg2rad(1), 1, 'last');
    pe = r.v .* r.i;                              % electrical power into the motor
    slew = r.t <= 4;
    row.Motor = string(m.name);
    row.SpeedCase_rpm = m.rpmCase;
    row.Price_GBP = m.price;
    row.Settle_s = r.t(min(iOut + 1, numel(r.t)));
    row.Overshoot_pct = max(0, max(sign(thetaRef)*(r.th - thetaRef))) / abs(thetaRef) * 100;
    row.FinalError_deg = rad2deg(r.th(end) - thetaRef);
    row.PeakSpeed_rpm = max(abs(r.w));
    row.SpeedUsed_pct = row.PeakSpeed_rpm / m.rpmCase * 100;
    row.PeakCurrent_A = max(abs(r.i));
    row.CurrentUsed_pct = row.PeakCurrent_A / m.Irated * 100;
    row.PeakVolts_V = max(abs(r.v));
    row.VoltsUsed_pct = row.PeakVolts_V / (Dmax * Vin) * 100;
    row.CopperLoss_J = trapz(r.t(slew), m.R * r.i(slew).^2);
    row.EnergyIn_J = trapz(r.t(slew), max(pe(slew), 0));
    row.PeakPower_W = max(pe);
    row.MeanPower_W = row.EnergyIn_J / 4;
    row.HoldPower_W = mean(max(pe(r.t > 5), 0));
    row.Assumed = string(m.assumed);
    rows{i} = row;
    fprintf('%-26s settle %.2f s, peak %.0f rpm, %.2f A, %.2f V\n', m.name, ...
        row.Settle_s, row.PeakSpeed_rpm, row.PeakCurrent_A, row.PeakVolts_V);
end

T = struct2table([rows{:}]);
tag = sprintf('%gV', Vin);
writetable(T, fullfile(resDir, "motor_metrics_" + tag + ".csv"));
save(fullfile(resDir, "motor_runs_" + tag + ".mat"), 'runs', 'T', '-v7.3');
plot_motor_comparison(runs, T, Vin, resDir, tag);
end

function plot_motor_comparison(runs, T, Vin, resDir, tag)
n = numel(runs);
cols = turbo(n + 1); cols = cols(1:n, :);
names = string(T.Motor);

% Figure 1: time histories
fig = figure('Visible', 'off', 'Position', [100 100 1150 1300], 'Color', 'w');
tl = tiledlayout(fig, 5, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
titles = ["Body angle (dashed: -90\circ target)", ...
    "Wheel speed as a share of each motor's speed cap", ...
    "Motor current", "Voltage applied to the motor (dotted: " + sprintf('%.2f', 0.95*Vin) + " V available)", ...
    "Electrical power into the motor"];
ylabels = ["Angle (deg)", "Speed (% of cap)", "Current (A)", "Voltage (V)", "Power (W)"];
for k = 1:5
    ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
    for i = 1:n
        r = runs{i};
        d = 1:20:numel(r.t);
        switch k
            case 1, y = rad2deg(r.th);
            case 2, y = r.w / r.m.rpmCase * 100;
            case 3, y = r.i;
            case 4, y = r.v;
            case 5, y = r.v .* r.i;
        end
        plot(ax, r.t(d), y(d), 'Color', cols(i, :), 'LineWidth', 1.3, 'DisplayName', names(i));
    end
    if k == 1, yline(ax, -90, 'k--', 'HandleVisibility', 'off'); end
    if k == 4, yline(ax, [-1 1]*0.95*Vin, 'r:', 'HandleVisibility', 'off'); end
    title(ax, titles(k)); ylabel(ax, ylabels(k));
    if k == 1, legend(ax, 'Location', 'eastoutside', 'Box', 'off'); end
    if k == 5, xlabel(ax, 'Time (s)'); end
end
exportgraphics(fig, fullfile(resDir, "slew_traces_" + tag + ".png"), 'Resolution', 150);
close(fig);

% Figure 2: headline numbers per motor
fig = figure('Visible', 'off', 'Position', [100 100 1150 900], 'Color', 'w');
tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
vals = {T.VoltsUsed_pct, T.CurrentUsed_pct, T.EnergyIn_J, T.Price_GBP};
ttl = ["Peak voltage used (% of " + sprintf('%.2f', 0.95*Vin) + " V available)", ...
    "Peak current (% of the motor's continuous rating)", ...
    "Electrical energy for the slew (J, first 4 s)", "Motor price (GBP)"];
for k = 1:4
    ax = nexttile(tl);
    b = barh(ax, vals{k}, 'FaceColor', 'flat'); b.CData = cols;
    set(ax, 'YTick', 1:n, 'YTickLabel', names, 'YDir', 'reverse'); grid(ax, 'on');
    title(ax, ttl(k));
    if k <= 2, xline(ax, 100, 'r:'); end
    for i = 1:n
        text(ax, vals{k}(i), i, sprintf(' %.3g', vals{k}(i)), 'VerticalAlignment', 'middle', 'FontSize', 9);
    end
    xlim(ax, [0, max(max(vals{k})*1.18, 1)]);
end
exportgraphics(fig, fullfile(resDir, "motor_summary_" + tag + ".png"), 'Resolution', 150);
close(fig);
end
