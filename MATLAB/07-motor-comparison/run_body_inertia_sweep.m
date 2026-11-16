function T = run_body_inertia_sweep(Jlist, ids, Vin)
%RUN_BODY_INERTIA_SWEEP Repeat the 90 degree slew for a range of body
%inertias on the shortlisted motors.
%   T = run_body_inertia_sweep(Jlist, ids, Vin) runs each motor in IDS (ids
%   from motor_table) at each body inertia in JLIST (kg*m^2) from a VIN volt
%   supply. The gains are re-derived for each inertia (motor_params). The
%   saved model copies in models/ are not changed: values are passed as
%   SimulationInput variables. Results go to results/.

arguments
    Jlist (1,:) double = [0.0008 0.0015 0.002 0.004]
    ids (1,:) string = ["maxon_EC20flat_351006" "dfrobot_FIT1034" "mercury_DM3505EC"]
    Vin (1,1) double = 9
end

here = fileparts(mfilename('fullpath'));
modelDir = fullfile(here, 'models');
resDir = fullfile(here, 'results');
M = motor_table();
thetaRef = -pi/2;
Dmax = 0.95;
rows = {};
runs = {};

for id = ids
    m = M(string({M.id}) == id);
    mdl = "motor_" + m.id;
    load_system(fullfile(modelDir, mdl + ".slx"));
    for Jb = Jlist
        p = motor_params(m, Vin, Jb);
        si = Simulink.SimulationInput(mdl);
        si = si.setModelParameter('ReturnWorkspaceOutputs', 'on', 'StopTime', '6');
        f = fieldnames(p);
        for k = 1:numel(f)
            si = si.setVariable(f{k}, p.(f{k}), 'Workspace', mdl);
        end
        out = sim(si);

        lo = out.logsout;
        g = @(n) lo.get(n).Values;
        r.t = g('I_meas').Time;
        r.i = g('I_meas').Data(:);
        r.v = interp1(g('V_motor').Time, g('V_motor').Data(:), r.t, 'previous', 'extrap');
        r.w = interp1(g('Rotor_Speed').Time, g('Rotor_Speed').Data(:), r.t, 'previous', 'extrap');
        r.th = interp1(g('Body_angle').Time, g('Body_angle').Data(:), r.t, 'linear', 'extrap');
        r.name = m.name; r.Jb = Jb; r.m = m;
        runs{end+1} = r; %#ok<AGROW>

        iOut = find(abs(r.th - thetaRef) > deg2rad(1), 1, 'last');
        slew = r.t <= 4;
        pe = r.v .* r.i;
        row.Motor = string(m.name);
        row.J_body = Jb;
        row.Settle_s = r.t(min(iOut + 1, numel(r.t)));
        row.Overshoot_pct = max(0, max(sign(thetaRef)*(r.th - thetaRef))) / abs(thetaRef) * 100;
        row.PeakSpeed_rpm = max(abs(r.w));
        row.SpeedUsed_pct = row.PeakSpeed_rpm / m.rpmCase * 100;
        row.FinalSpeed_pct = abs(r.w(end)) / m.rpmCase * 100;
        row.PeakCurrent_A = max(abs(r.i));
        row.CurrentUsed_pct = row.PeakCurrent_A / m.Irated * 100;
        row.PeakVolts_V = max(abs(r.v));
        row.VoltsUsed_pct = row.PeakVolts_V / (Dmax * Vin) * 100;
        row.EnergyIn_J = trapz(r.t(slew), max(pe(slew), 0));
        rows{end+1} = row; %#ok<AGROW>
        fprintf('%-26s J=%.4f settle %.2f s, peak %.0f rpm (%.0f%%), %.2f A, %.2f V\n', ...
            m.name, Jb, row.Settle_s, row.PeakSpeed_rpm, row.SpeedUsed_pct, ...
            row.PeakCurrent_A, row.PeakVolts_V);
    end
    close_system(mdl, 0);
end

T = struct2table([rows{:}]);
writetable(T, fullfile(resDir, "body_inertia_sweep.csv"));
save(fullfile(resDir, "body_inertia_sweep.mat"), 'runs', 'T', '-v7.3');
plot_sweep(T, ids, M, Jlist, resDir);
end

function plot_sweep(T, ids, M, Jlist, resDir)
fig = figure('Visible', 'off', 'Position', [100 100 1150 800], 'Color', 'w');
tl = tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
cols = lines(numel(ids));
ys = ["SpeedUsed_pct" "CurrentUsed_pct" "VoltsUsed_pct" "EnergyIn_J"];
ttl = ["Peak wheel speed (% of cap)" "Peak current (% of continuous rating)" ...
    "Peak voltage (% of 8.55 V available)" "Electrical energy for the slew (J, first 4 s)"];
for k = 1:4
    ax = nexttile(tl); hold(ax, 'on'); grid(ax, 'on');
    for i = 1:numel(ids)
        name = string(M(string({M.id}) == ids(i)).name);
        s = T(T.Motor == name, :);
        plot(ax, s.J_body * 1e3, s.(ys(k)), '-o', 'Color', cols(i, :), ...
            'LineWidth', 1.4, 'DisplayName', name);
    end
    if k <= 3, yline(ax, 100, 'r:', 'HandleVisibility', 'off'); end
    xline(ax, [0.8 1.5], 'k--', 'HandleVisibility', 'off');
    title(ax, ttl(k)); xlabel(ax, 'Body inertia (g\cdotm^2 = 10^{-3} kg\cdotm^2)');
    xlim(ax, [0, max(Jlist) * 1e3 * 1.05]);
    if k == 1, legend(ax, 'Location', 'northwest', 'Box', 'off'); end
end
title(tl, 'Effect of body inertia on the 90\circ slew (dashed: frame estimate range)');
exportgraphics(fig, fullfile(resDir, "body_inertia_sweep.png"), 'Resolution', 150);
close(fig);
end
