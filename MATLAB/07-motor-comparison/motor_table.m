function M = motor_table()
%MOTOR_TABLE Datasheet values for each candidate motor.
%   Electrical values are the datasheet's phase-to-phase (terminal) figures,
%   used directly in the averaged model's equivalent circuit:
%       V = R*i + L*di/dt + Kt*w,   torque = Kt*i
%   Fields marked in "assumed" are not published and are estimates.
%
%   id        valid MATLAB name, used for the model copy
%   rpmCase   top-speed case the motor is run in (sets wheel inertia and cap)
%   Kt        torque constant, N*m/A          R   terminal resistance, ohm
%   L         terminal inductance, H          Jr  rotor inertia, kg*m^2
%   I0, n0    no-load current (A) at no-load speed (rpm), for friction
%   Irated    continuous current rating, A    price   GBP, one motor

M = struct('id', {}, 'name', {}, 'rpmCase', {}, 'Kt', {}, 'R', {}, 'L', {}, ...
    'Jr', {}, 'I0', {}, 'n0', {}, 'C0', {}, 'Bv', {}, 'Irated', {}, 'price', {}, ...
    'supplier', {}, 'assumed', {});

% Faulhaber 2232S012BX4: friction given directly (C0 0.46 mN*m, Cv 1.1e-4 mN*m/rpm)
M(end+1) = entry('faulhaber_2232S012BX4', 'Faulhaber 2232S012BX4', 3000, 17.0e-3, 3.5, 115e-6, ...
    5.1e-7, 0.072, 6700, 0.46e-3, 1.1e-7*60/(2*pi), 1.0, 213.44, 'RS 873-4818', "");
M(end+1) = entry('maxon_EC20flat_351006', 'maxon EC 20 flat 351006', 3000, 8.82e-3, 3.54, 0.424e-3, ...
    5.1e-7, 0.0683, 9430, NaN, NaN, 0.974, 105.43, 'maxon UK shop', "");
M(end+1) = entry('maxon_EC20flat_351007', 'maxon EC 20 flat 351007', 3000, 11.8e-3, 7.45, 0.754e-3, ...
    5.1e-7, 0.0511, 9380, NaN, NaN, 0.655, 125.26, 'RS 774-0525', "");
M(end+1) = entry('faulhaber_2214S012BXTR', 'Faulhaber 2214S012BXT R', 3000, 17.0e-3, 6.95, 884e-6, ...
    3.3e-7, 0.039, 6500, NaN, NaN, 0.66, 160.20, 'RS 184-6933', "");
M(end+1) = entry('faulhaber_2214S006BXTR', 'Faulhaber 2214S006BXT R', 6000, 9.58e-3, 2.42, 271e-6, ...
    3.3e-7, 0.062, 5740, NaN, NaN, 1.18, 160.20, 'RS 184-6932', "");
M(end+1) = entry('dfrobot_FIT1034', 'DFRobot FIT1034', 1500, 9.549/220, 5.1, 2.8e-3, ...
    4e-6, 0.07, 2640, NaN, NaN, 0.8, 21, 'Grobotronics (about EUR 24.90)', ...
    "rotor inertia, no-load current, rated current");
M(end+1) = entry('iflight_GM2804', 'iFlight iPower GM2804', 600, 9.549/168, 9.0, 2.8e-3, ...
    4e-6, 0.09, 1687, NaN, NaN, 0.8, 33.00, 'iFlight EU', ...
    "Kv (from no-load speed), inductance, rotor inertia");
M(end+1) = entry('mercury_DM3505EC', 'Mercury DM3505EC', 600, 80e-3, 6.34, 1.08e-3, ...
    5.6e-6, 0.04, 1404, NaN, NaN, 1.1, 40, 'SparkFun ROB-27478 (about USD 49.95)', ...
    "no-load current");
end

function e = entry(id, name, rpmCase, Kt, R, L, Jr, I0, n0, C0, Bv, Irated, price, supplier, assumed)
% Where the datasheet gives only a no-load current, split the no-load
% friction torque Kt*I0 into 40% constant and 60% proportional to speed,
% the same split as the Faulhaber 2232 datasheet figures.
if isnan(C0)
    T0 = Kt * I0;
    C0 = 0.4 * T0;
    Bv = 0.6 * T0 / (n0 * 2*pi/60);
end
e = struct('id', id, 'name', name, 'rpmCase', rpmCase, 'Kt', Kt, 'R', R, 'L', L, ...
    'Jr', Jr, 'I0', I0, 'n0', n0, 'C0', C0, 'Bv', Bv, 'Irated', Irated, ...
    'price', price, 'supplier', supplier, 'assumed', assumed);
end
