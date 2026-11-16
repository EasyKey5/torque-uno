%% linearise_bldc
%
% Estimates the inner plant frequency response (voltage command -> wheel
% speed) of my_bldc_controller, compares it with an averaged model and
% tunes the inner speed PI on the averaged model.
%
% Exact linearisation (linearize / Model Linearizer "Linearize") returns
% zero for this model: the sector relational operators and the PWM
% comparator have zero derivative, so the path from duty to speed is cut.
% Frequency response estimation (FRE) simulates the model instead.
%
% Linearisation points are saved in the model:
%   Controller/Unit Delay output - open-loop input (PID cut, held at op)
%   Sensor port 2 (speed, rpm)   - output measurement
%
% The inverter is driven directly by unipolar PWM, so the voltage across
% the conducting phase pair is d*Vin = the voltage command (the 1/Vin gain
% cancels the bus voltage).

clear

mdl = 'my_bldc_controller';
load_system(mdl);
blk = [mdl '/BLDC Motor with Speed Control'];
mws = get_param(mdl, 'ModelWorkspace');

%% Temporary model settings (restored at the end)
% Hold the attitude reference at 0 so the wheel sits on the bias speed
refBlk = [mdl '/Constant'];
refOld = get_param(refBlk, 'Value');
restoreRef = onCleanup(@() set_param(refBlk, 'Value', refOld));
set_param(refBlk, 'Value', '0');

% FRE needs the input point (Unit Delay, inherits the PID rate) and the
% output point (speed, Simscape rate) at the test signal rate. The PID is
% cut by the input point, so running it at Ts_sim doesn't change the
% measured plant
pidBlk = [blk '/Controller/PID Controller'];
Ts = str2double(get_param(pidBlk, 'SampleTime'));
TsSim = getVariable(mws, 'Ts_sim');
restorePid = onCleanup(@() set_param(pidBlk, 'SampleTime', num2str(Ts)));
set_param(pidBlk, 'SampleTime', 'Ts_sim');

%% Operating point
% Snapshot once the inner loop has settled on the bias speed
tSnapshot = 0.3;
op = findop(mdl, tSnapshot);

%% Frequency response estimation
io = getlinio(mdl);

% Commutation ripple is at 6 x electrical frequency (200 Hz at 2000 rpm),
% so stay well below it
fTest = [2 5 10 20 50];                     % Hz
in = frest.createFixedTsSinestream(TsSim, 2*pi*fTest);
in.Amplitude = 0.3;                         % V, op is ~1.2 V
in.NumPeriods = 5;
in.SettlingPeriods = 2;

sysFre = frestimate(mdl, op, io, in);
clear restoreRef restorePid                 % put the model back

%% Averaged model
% Six-step BLDC treated as a DC motor across two conducting phases, driven
% by the averaged PWM voltage. The wheel spins relative to the body, so
% the motor sees Jw and Jb in series. States: motor current, relative
% speed (rad/s). Output in rpm to match the Sensor block.
psiM = getVariable(mws, 'psi_m');
Jw = getVariable(mws, 'J_flywheel') + getVariable(mws, 'J_rotor');
Jb = getVariable(mws, 'J_body');
J = Jw*Jb/(Jw + Jb);
B = getVariable(mws, 'B_rotor');

bldc = [blk '/BLDC'];
Rm = 2*str2double(get_param(bldc, 'Rs'));                   % 2 x Rs
Lm = 2*str2double(get_param(bldc, 'Ld'))*1e-3;              % 2 x Ld (mH)
% Kt = T / conducting-phase current, measured from simlog at psi_m = 0.004 Wb
% (0.0058 N*m/A); assumed to scale linearly with psi_m
Ke = 1.45*psiM;                                             % V*s/rad = N*m/A

A = [-Rm/Lm  -Ke/Lm
      Ke/J   -B/J];
sysAvg = ss(A, [1/Lm; 0], [0 60/(2*pi)], 0);
sysAvg.InputName = 'Voltage command (V)';
sysAvg.OutputName = 'Speed (rpm)';

%% Compare
[magFre, phFre] = bode(sysFre, 2*pi*fTest);
[magAvg, phAvg] = bode(sysAvg, 2*pi*fTest);
fprintf('%6s %12s %10s %12s %10s\n', 'f (Hz)', '|G| FRE', 'ph FRE', '|G| avg', 'ph avg');
fprintf('%6.1f %12.4f %10.1f %12.4f %10.1f\n', ...
    [fTest; squeeze(magFre)'; squeeze(phFre)'; squeeze(magAvg)'; squeeze(phAvg)']);

figure
bode(sysAvg, {2*pi*0.1, 2*pi*1000})
hold on
bode(sysFre, 'ro')
legend('Averaged model', 'FRE (Simscape model)')
grid on

%% Inner PI tuning
% Discrete PI at Ts with the Controller's Unit Delay. 10 Hz crossover keeps
% the loop well below the commutation ripple
Gd = c2d(sysAvg, Ts) * tf(1, [1 0], Ts);
fc = 10;                                    % Hz
[Cin, info] = pidtune(Gd, 'PI', 2*pi*fc);
fprintf('Inner PI: P = %.4g, I = %.4g (phase margin %.1f deg)\n', ...
    Cin.Kp, Cin.Ki, info.PhaseMargin);

save('linearisation_results.mat', 'sysFre', 'sysAvg', 'op', 'fTest', 'Cin');
