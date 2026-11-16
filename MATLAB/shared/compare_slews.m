function T = compare_slews(files, labels, outPng, thetaRef)
%COMPARE_SLEWS Plot and tabulate slew results saved by run_slew.
%   T = compare_slews(files, labels, outPng, thetaRef) overlays the runs in
%   FILES (string array of .mat files), labelled LABELS, saves the figure to
%   OUTPNG and returns a table of metrics. THETAREF is the target angle in
%   radians (default -pi/2).

arguments
    files (1,:) string
    labels (1,:) string
    outPng (1,1) string
    thetaRef (1,1) double = -pi/2
end

% Forward six-step pairs: current through the conducting pair is
% (i_high - i_low)/2, one row per 60 degree sector.
W = [0.5 0 -0.5; 0 0.5 -0.5; -0.5 0.5 0; -0.5 0 0.5; 0 -0.5 0.5; 0.5 -0.5 0];

n = numel(files);
cols = lines(n);
fig = figure('Visible', 'off', 'Position', [100 100 1100 1250], 'Color', 'w');
tl = tiledlayout(fig, 5, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
ax = gobjects(5, 1);
for k = 1:5, ax(k) = nexttile(tl); hold(ax(k), 'on'); grid(ax(k), 'on'); end

metrics = cell(n, 1);
for i = 1:n
    r = load(files(i));
    p = r.params;
    Rs = 2;                                   % ohm per phase (BLDC block)
    if isfield(p, 'Rs'), Rs = p.Rs; end

    % Body angle
    t = r.Body_angle.t; y = r.Body_angle.y(:);
    plot(ax(1), t, rad2deg(y), 'Color', cols(i,:), 'LineWidth', 1.4, 'DisplayName', labels(i));
    iOut = find(abs(y - thetaRef) > deg2rad(1), 1, 'last');
    m.settle_s = t(min(iOut + 1, numel(t)));
    m.overshoot_pct = max(0, max(sign(thetaRef)*(y - thetaRef))) / abs(thetaRef) * 100;
    m.final_error_deg = rad2deg(y(end) - thetaRef);

    % Wheel speed and its command
    plot(ax(2), r.Rotor_Speed.t, r.Rotor_Speed.y(:), 'Color', cols(i,:), 'LineWidth', 1.4, ...
        'DisplayName', labels(i) + " wheel speed");
    stairs(ax(2), r.cmd_vel.t, r.cmd_vel.y(:), '--', 'Color', cols(i,:), 'LineWidth', 0.9, ...
        'DisplayName', labels(i) + " command");
    m.peak_speed_rpm = max(abs(r.Rotor_Speed.y(:)));

    % Motor current: pair current averaged over one PWM period
    I = r.Iabc.y; if size(I, 1) == 3 && size(I, 2) ~= 3, I = I.'; end
    ti = r.Iabc.t;
    th = interp1(r.Theta.t, r.Theta.y(:), ti, 'previous', 'extrap');
    sec = min(6, max(1, ceil(th/60)));
    iPair = sum(W(sec, :) .* I, 2);
    nAvg = max(1, round(1/(p.f_pwm * median(diff(ti)))));
    iAvg = movmean(iPair, nAvg);
    plot(ax(3), ti, iAvg, 'Color', cols(i,:), 'LineWidth', 1.1, 'DisplayName', labels(i) + " measured");
    if isfield(r, 'I_ref')
        plot(ax(3), r.I_ref.t, r.I_ref.y(:), ':', 'Color', 'k', 'LineWidth', 1.0, ...
            'DisplayName', labels(i) + " demand");
    end
    m.peak_current_A = max(abs(iAvg));
    m.peak_phase_A = max(abs(I(:)));
    m.rms_phase_A = sqrt(mean(I(:).^2));               % rms over all three phases
    pcu = Rs * sum(I.^2, 2);
    m.copper_J = trapz(ti, pcu);

    % Applied voltage
    plot(ax(4), r.duty.t, r.duty.y(:) * p.Vin, 'Color', cols(i,:), 'LineWidth', 1.0, 'DisplayName', labels(i));
    m.peak_volts = max(abs(r.duty.y(:))) * p.Vin;

    % Motor torque
    if isfield(r, 'sl_electrical_torque')
        tq = r.sl_electrical_torque;
        nT = max(1, round(1/(p.f_pwm * median(diff(tq.t)))));
        plot(ax(5), tq.t, movmean(tq.y(:), nT)*1e3, 'Color', cols(i,:), 'LineWidth', 1.1, 'DisplayName', labels(i));
        m.peak_torque_mNm = max(abs(movmean(tq.y(:), nT)))*1e3;
        sel = tq.t > 0.1 & tq.t < 0.4;
        selI = ti > 0.1 & ti < 0.4;
        m.Kt_mNm_per_A = mean(tq.y(sel)) / mean(iAvg(selI)) * 1e3;
    else
        m.peak_torque_mNm = NaN; m.Kt_mNm_per_A = NaN;
    end
    m.wall_clock_s = r.wallClock;
    metrics{i} = m;

    if i == 1
        yline(ax(1), rad2deg(thetaRef), 'k--', 'HandleVisibility', 'off');
        yline(ax(1), rad2deg(thetaRef) + [-1 1], 'k:', 'HandleVisibility', 'off');
        if isfield(p, 'w_max'), yline(ax(2), [-1 1]*p.w_max, 'r:', 'HandleVisibility', 'off'); end
        if isfield(p, 'I_max'), yline(ax(3), [-1 1]*p.I_max, 'r:', 'HandleVisibility', 'off'); end
        yline(ax(4), [-1 1]*p.Dmax*p.Vin, 'r:', 'HandleVisibility', 'off');
    end
end

ylabel(ax(1), 'Body angle (deg)');        title(ax(1), 'Body angle (dashed: target, dotted: \pm1\circ)');
ylabel(ax(2), 'Wheel speed (rpm)');       title(ax(2), 'Wheel speed relative to body (dashed: command)');
ylabel(ax(3), 'Motor current (A)');       title(ax(3), 'Motor current, averaged over one PWM period (dotted: demand)');
ylabel(ax(4), 'Applied voltage (V)');     title(ax(4), 'Average voltage applied to the motor (duty \times supply)');
ylabel(ax(5), 'Motor torque (mN\cdotm)'); title(ax(5), 'Motor torque, averaged over one PWM period');
xlabel(ax(5), 'Time (s)');
for k = 1:5, legend(ax(k), 'Location', 'eastoutside', 'Box', 'off'); end
linkaxes(ax, 'x');
exportgraphics(fig, outPng, 'Resolution', 150);
close(fig);

T = struct2table([metrics{:}]);
T.Properties.RowNames = cellstr(labels);
end
