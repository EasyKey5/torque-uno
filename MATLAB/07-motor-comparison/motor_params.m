function p = motor_params(m, Vin, J_body)
%MOTOR_PARAMS Model-workspace values for one motor from motor_table.
%   p = motor_params(m, Vin) returns every variable the averaged model needs
%   for motor M (one element of motor_table) on a supply of VIN volts.
%   p = motor_params(m, Vin, J_body) also sets the body inertia (default
%   0.002 kg*m^2). The gains are re-derived for that inertia.
%
%   The controller gains are derived from the motor values so every motor
%   gets loops of the same speed:
%     current loop  1 kHz crossover   Kp = L*wc,  Ki = R*wc
%     speed loop    54.5 rad/s, PI zero at 36.3 rad/s (as the original model)
%     position loop 17 rad/s, Ki/Kp = 2.44 (as the original model)

arguments
    m (1,1) struct
    Vin (1,1) double = 9
    J_body (1,1) double = 0.002     % kg*m^2, body and turntable inertia
end

H = 7.54e-3;                        % N*m*s, wheel momentum target
wMax = m.rpmCase * 2*pi/60;
Jw = H / wMax;                      % total wheel inertia for this speed case

p.Vin = Vin;
p.R_motor = m.R;
p.L_motor = m.L;
p.Kt_motor = m.Kt;
p.J_rotor = m.Jr;
p.J_flywheel = Jw - m.Jr;
p.J_body = J_body;
p.T_col_motor = m.C0;
p.T_brk_motor = 1.2 * m.C0;
p.B_motor = m.Bv;
p.w_max = m.rpmCase;
p.I_max = 1.5;                      % A, firmware current limit
p.Ts_sim = 2.5e-5;                  % s, 40 kHz
p.Ts_inner = 2.5e-5;

wcI = 2*pi*1000;
p.Kp_current = m.L * wcI;
p.Ki_current = m.R * wcI;

Jred = Jw * J_body / (Jw + J_body); % inertia the motor torque works against
rpmPerAmpSec = (60/(2*pi)) * m.Kt / Jred;
p.Kp_speed = 54.5 / rpmPerAmpSec;
p.Ki_speed = 36.3 * p.Kp_speed;

k = Jw / (J_body + Jw) * 2*pi/60;   % body rate (rad/s) per rpm of wheel speed
p.Kp_pos = 17.03 / k;
p.Ki_pos = 2.441 * p.Kp_pos;
end
