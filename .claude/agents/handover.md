# Torque-Uno handover

**Date:** 3 November 2026
**From:** Claude Code (Opus 5.5)
**For:** the agent taking over this project in a new harness
**User:** Tama Harrison, BEng student (ELEC340, University of Liverpool). Supervisor: Dr Kai Hoettges.

Torque-Uno is a single-axis CubeSat reaction wheel: a body on a low-friction turntable, rotated by a BLDC-driven flywheel. It uses a custom PCB and an ESP32-S3, and is modelled in MATLAB/Simulink first. The brief is in `AGENTS.md`.

**How far to trust this document**
- **Checked on 3 Nov:** anything marked "checked" was read from the files or the loaded Simulink model that day.
- **From history:** everything else comes from earlier session transcripts. Re-check it before relying on it.
- **Tracked changes:** the repo has no commits, so there is no history to diff against.

---

## 1. Read this first

1. **Current state:** only the project plan, risk assessment, turntable design and a Simulink motor and attitude model have been worked on. The repo has no schematic, PCB, firmware, body CAD or mass budget (checked). Ask Tama whether any of this exists elsewhere.
2. **The first simulation is gone.** `sim/` produced the wheel sizing and most of the requirement results, but it is no longer in the repo or anywhere in the home folder outside `~/Library` (checked). Nothing was ever committed, so git can't restore it. See section 5.
3. **The current model doesn't reflect the design.** It meets the slew targets (CTR-02 and CTR-03), but it breaks the 600 rpm limit, leaves out turntable friction, and has no gyro or FOC. See section 7.
4. **`MATLAB/linearise_bldc.m` will fail if run.** It refers to a block that no longer exists (section 7, item 8).
5. **Don't write assessed prose.** See section 2.

**Nearest deadlines**

| Date | Item |
|---|---|
| 9 Nov 2026 | 1U or 1.5U decision (plan WP3), needed before PCB layout |
| 22 Nov 2026 | Project Update 1 with supervisor (marked) |
| 14 Dec 2026 | Crowdfunding pitch |
| 21 Feb 2027 | Project Update 2 (marked) |
| 10 Mar 2027 | Abstract |
| 16/17 Mar 2027 | Bench inspection |
| 14 Apr 2027 | Final report |

WP1 was due to finish around 1 Nov with the flywheel and motor chosen, and WP2, WP3 and WP4 all start from that. The repo shows no selected motor, so the project may be slightly behind plan. Confirm this with Tama.

---

## 2. Working rules

### Academic integrity (hard rule)
- **Assessed writing is AI Tier 2.** You may draft calculations, tables, code, structure and bullet facts. Tama writes all report prose.
- **Project work is Tier 3.** Code, simulation, sizing and analysis are permitted.
- **This has already come up.** Tama once asked for scope and objectives paragraphs to reword. The agent declined and gave example paragraphs about a different project (a weather station).
- **Check each assessment's own terms.** They are in the marking descriptors, for example "Progress Updates" is Tier 2.

### How Tama likes to work
- **Check means check.** "Check my model" or "have I done this right?" means inspect and report only. Earlier agents tested fixes on temporary copies and edited the real model only after "make the required changes".
- **Review before editing.** For document reviews, Tama has asked for the errors to be listed before anything changes.
- **Keep it rough.** Tama pushed back on over-detailed plans: 2 or 3 tasks per work package, and mostly 1-week estimates.
- **Explain things.** Tama often asks how something works before changing it. The plan's skills audit lists FOC experience as none.
- **Spelling and tools:** British English ("linearise"). Tama writes in Org mode with Doom Emacs.

### Decisions Tama has made (don't reopen without cause)

| Decision | Reason |
|---|---|
| Single axis, 1U target on a bearing turntable | Project scope; 1.5U is the agreed fallback |
| Onboard protected 3S 18650 pack, no slip ring | Tama is uneasy about slip rings; wireless link with watchdog instead |
| Gyro only, no electronic ground-truth sensor | Space realism; overhead camera and protractor ring are for verification only |
| ESP32-S3 module, single microcontroller, all-in-one 2-layer PCB | Tama knows ESP32 and wants one MCU; voltage-mode FOC means the weak ADC is acceptable |
| Gimbal BLDC with own driver and magnetic encoder | Requirement ELE-02 |
| PID baseline; LQR and magnetorquer as stretch goals | STR-01, STR-02 |
| 600 rpm firmware speed limit | SFT-04; reduces flywheel burst hazard |
| Aluminium enclosure; no acrylic or polycarbonate; aluminium or brass flywheel | SFT-05, SFT-06 |
| Averaged drive for simulations, keeping the buck "for later" | Stated on 26 Oct, but the buck was later removed (section 4) |
| Direct PWM of the inverter, four-quadrant | Replaced the buck-fed, one-direction drive on 27 Oct |

---

## 3. Repo map

```
torque-uno/
├── AGENTS.md                     Brief and Tier 2 rule
├── .claude/agents/matlab-sim.md  Old simulation subagent (out of date, section 7 item 12)
├── MATLAB/
│   ├── my_bldc_controller.slx    ★ Current model (last saved 31 Oct 13:15)
│   ├── my_bldc_controller.before-buck.slx
│   ├── my_bldc_controller.before-realistic-params.slx
│   ├── my_bldc_controller.before-unipolar-pwm.slx
│   ├── my_bldc_controller.slx.original
│   ├── linearise_bldc.m          Frequency response estimate + inner PI tuning (broken)
│   ├── outer_loop_lineariser.m   Outer plant, opens pidTuner
│   ├── linearisation_results.mat From 27 Oct, 2000 rpm bias: out of date
│   ├── linearisation.mat         Old Model Linearizer session: ignore
│   ├── animateRotorPosition.m    MathWorks tutorial animation, adapted
│   └── images/, slprj/, *.slxc   Tutorial images and build artefacts
├── cad/reaction-wheel-turntable.fs   Onshape FeatureScript for the turntable
└── docs/
    ├── requirements.org          Requirement register (out of date, section 7 item 11)
    ├── risk-assessment.org       Working draft (out of date, section 7 item 10)
    ├── bearing-turntable-spec.md Original turntable brief
    ├── workshop-drawing-checklist.md  ★ Current turntable dimensions
    ├── Project-Plan/             Org source, Makefile, pandoc filters, bib, Gantt, signed-off RA PDF
    └── Final Plan/               Torque-Uno-Project-Plan.docx (22 Oct), project-plan.docx (20 Oct)
```

**Outside the repo**
- **Canvas export:** `../202627-ELEC340---BEng-Project-2026-Oct-01_16-29-53-131/viewer/files/`. It holds the timeline, marking descriptors, plan guidance, and the Fabrication and Component Request forms. `AGENTS.md` wrongly implies it's inside the repo.
- **MathWorks tutorial the model grew from:** `~/Code/matlab/matlab-m-drive/` ("How to Design Motor Controllers Using Simscape Electrical"). Treat as read-only.
- **Onshape turntable:** https://cad.onshape.com/documents/4ab8a2bf285eadcbacd331b1/w/8f6b427f0a75376b5c33c0e9/e/2325c33bb7dc90f3c4a9841b
- **Git:** branch `main`, remote `https://github.com/EasyKey5/torque-uno`. No commits, no `.gitignore`, everything untracked.

---

## 4. What has been done

| Date (2026) | Work | Outcome |
|---|---|---|
| 1–9 Oct | Scoping | Key decisions above; risk assessment drafted; brief saved to `AGENTS.md` |
| 5–6 Oct | Turntable | Spec written; modelled in Onshape; design fixes recorded in the `.fs` header and checklist |
| 6 Oct | First simulation | `matlab-sim` subagent built `sim/` with a core-Simulink model (section 5) |
| 13 Oct | Requirements | Register audited and reset to CTR/PHY/PWR/THM/ELE/SFT/SIM/STR IDs; wheel limit set to 600 rpm |
| 16–22 Oct | Project plan | Work packages, Gantt, scope and objective skeletons, IEEE citations, reviews; PHY-01/02 changed to allow 1.5U |
| 24–25 Oct | Motor jitter | Rotor rocked because of wrong sector scaling and alignment; fixed with Pole Pairs = 1, Offset = 90°, `mod` instead of `rem`, PI limit with anti-windup |
| 25 Oct | MATLAB tools | MATLAB MCP server fixed by adding `--matlab-root` |
| 25–26 Oct | Buck converter | Tutorial buck added; bus oscillated up to 1182 V from a 500 V input, caused by an undamped 15.9 Hz LC resonance |
| 26 Oct | Linearisation | Exact linearisation returns zero through the switching logic, so frequency response estimation (FRE) was adopted |
| 26 Oct | Realistic parameters | CubeSat-scale motor and wheel values; averaged buck variant; Backward Euler local solver |
| 26–27 Oct | Attitude loop | Outer loop added around the speed loop; fixed inconsistent initial conditions and a double sign flip causing positive feedback |
| 27 Oct | Four-quadrant drive | Direct unipolar PWM with synchronous freewheel and reverse tables; fixed about 600 A shoot-through; verified 2000 → −994 rpm |
| 27 Oct | Retune | `f_pwm` lowered to 5 kHz; inner PI retuned to 10 Hz crossover; FRE gain about 6% above the averaged model, phase within about 1° |
| 27–30 Oct | Speed Profiler | Trapezoidal reference added so the inner loop stops saturating |
| 30 Oct | Last session | Explained how to measure overshoot and settling time |
| 31 Oct | Tama's own edits (assumed) | Model saved after the last agent session, see below |

**Edits made after the last agent session (checked; no transcript covers them, so they appear to be Tama's)**
- Added a `w_bias` variable, now 0. It drives the Bias speed block and the BLDC and Rotor Inertia initial speeds, so the wheel runs at zero bias.
- Changed `theta_ref` from `pi/2` to `-pi/2`.
- Added a `body_angle` Scope.

**The project plan**
- **Build:** run `make` in `docs/Project-Plan/` (pandoc with Lua filters). Citations use `-d ieee`, which depends on global config (section 8).
- **Submission status unknown:** the due date was 18 Oct, but edits and reviews continued to 22 Oct. Ask Tama.
- **Assessor field:** `Final Plan/Torque-Uno-Project-Plan.docx` still shows "Project Assessor: ........" (checked).
- **Risk assessment:** `docs/Project-Plan/risk-assessment-2026-10-13.pdf` reads "Approved by Supervisor" (checked).

---

## 5. The missing `sim/` folder

**What happened:** `sim/` was present and in use up to at least 19 Oct, when `sim/params.m` was last read. I found no command in the transcripts that moved or deleted it. Its files don't turn up in a search of the home folder outside `~/Library`. Ask Tama before rebuilding it; a copy may exist on a cloud drive or another machine, or in `~/Library`, which I didn't search.

**What was in it:** `params.m`, `build_model.m` (generated `rw_single_axis.slx`), `tune_pid.m`, `run_all.m`, `lib/`, `scenarios/`, `tests/` (including a momentum-conservation test), `results/requirements.md` and a README.

**Recovering it:** partial text survives in Claude Code transcripts under `~/.claude/projects/`, in both the `-Users-tama-Documents-University-ELEC340-torque-uno` and `-Users-tama-Code-torque-uno` folders:
- `sim/README.md` was printed on 16 Oct.
- The first 80 or so lines of `params.m` were printed on 19 Oct.
- The results table was printed on 13 Oct.
- The original code may be recoverable from session `678dfc1c` or its subagent logs. I didn't try this.

**Design it reached** (a core-Simulink model with a voltage-mode FOC approximation, Karnopp friction and a gyro model; 1 ms controller)

| Parameter | Value | Status |
|---|---|---|
| Flywheel | Brass disc Ø75 × 4.5 mm, 171 g, Jw = 1.2e-4 kg·m² | Sized by sweep |
| Speed limit | 600 rpm; 7.5 mN·m·s; 0.24 J stored | Sized; matches SFT-04 |
| Minimum motor torque | 8 mN·m | Sized |
| Body inertia | 2.01e-3 kg·m² (1.2 kg uniform cube plus hub) | Estimate |
| Turntable friction | 1.0 mN·m Coulomb, 1.2 mN·m breakaway, 5e-6 N·m·s/rad viscous | Estimate |
| Motor | Gimbal class: 100 rpm/V, 5 Ω, 2 mH, 1.5 A | Placeholder |
| Gyro | ICM-42688-P class, ±250 °/s, 1 kHz | Placeholder |
| PID | Kp 0.0611 N·m/rad, Ki 0.0615, Kd 0.0150, N 314 rad/s; 59° phase margin | Tuned |

**Results on 13 Oct.** These are not reproducible now and don't describe the current model.

| ID | Target | Result |
|---|---|---|
| CTR-01 | ±1° for 60 s | 0.11° true error; estimate 0.63° off truth; drifts 0.011 °/s |
| CTR-02 | < 5 s | 2.65 s |
| CTR-03 | < 10% | 4.3% |
| CTR-04 | < 3 s | 0.43 / 0.50 / 0.52 s at 20 / 30 / 40 °/s |
| CTR-07 | ≥ 4 slews | 4, no margin; −93 rpm residual per slew |
| CTR-08 | No runaway | Peak 600 rpm under a 2 mN·m step |
| PHY-02 | ≤ 1.33 kg | Total 1.37 kg, over, on the 1.2 kg body estimate |
| PWR-01 | ≤ 2 W | 0.66 W, of which 0.60 W is an avionics estimate |
| PWR-03 | Report | 0.31 J motor and driver; 3.31 J from the battery over 5 s |
| THM-01 | ≤ 60 °C | 20.1 °C motor case; 21.6 °C driver junction |

**Known weakness:** 10 min within ±1° on gyro alone would need residual bias of ≤ 0.0017 °/s. That simulation stayed close to truth only because stiction held the body while the wheel saturated.

**1U fit (19 Oct, rough estimate):** about 83 mm of the 96 mm internal height is used and about 840 g total. The biggest risks are motor height and the 3-cell pack. CDS Rev 14.1 defines 1U as 100 × 100 × 113.5 mm and 2.00 kg. The 1.33 kg limit comes from Rev 13. An agent reported these figures and flagged the plan's CDS figures as needing a check against the source.

---

## 6. The current Simulink model

`MATLAB/my_bldc_controller.slx`, MATLAB R2026a, Simscape Electrical. Everything in this section was checked on 3 Nov unless noted.

### Signal flow
```
theta_ref (-pi/2) → Speed Profiler → Sum(+,-) → outer PID → Unit Delay → Sum1(w_bias − u) → cmd_vel
                                        ↑                                                     ↓
                         Speed gain (K_A) ← PS-Simulink ← Body A ← [BLDC Motor with Speed Control]
```

Inside `BLDC Motor with Speed Control`:
- **Controller:** Sum → inner PI → Unit Delay → Voltage to Duty (1/Vin) → Duty Limit ±Dmax.
- **Commutation Logic:** six-step forward and reverse tables, freewheel patterns, PWM Generator.
- **Sensor:** rotor angle → sector, and measured speed in rpm.
- **Three-Phase Inverter:** six ideal MOSFETs, driven from a DC Voltage Source set to `Vin`. There is no buck converter in the current model.
- **Mechanics:** BLDC, Rotor Inertia, Body Inertia, Bearing Friction, Ideal Rotational Motion Sensor.

### Values

| Item | Value |
|---|---|
| `J_body`, `J_flywheel`, `J_rotor` | 0.007, 1.6e-5, 5e-7 kg·m² |
| `B_rotor` | 2e-7 N·m·s/rad |
| `psi_m`, Rs, Ld, pole pairs | 0.004 Wb, 2 Ω, 0.2 mH, 1 |
| `Vin`, `Dmax`, `f_pwm` | 12 V, 0.95, 5 kHz |
| `w_bias` | 0 rpm |
| `slew_rate_max`, `slew_acc_max` | 0.5 rad/s, 1.2 rad/s² |
| `Ts_sim` (fixed step), `Ts_outer` | 2e-6 s, 0.01 s |
| Inner PI | P = 0.0647, I = 2.35; Ts 1e-5; limits ±Dmax·Vin; clamping; IC 0 |
| Outer PID | P = 69139.7, I = 168766.5, D = 0; Ts 0.01; **no output limit**; clamping |
| Bearing Friction | 0.05 mN·m breakaway and Coulomb, viscous 0; between rotor and body |
| Solver | FixedStepDiscrete, Backward Euler local solver at `Ts_sim`, stop time 5 s |
| Linearisation points | `Controller/Unit Delay` port 1 (openinput), `Sensor` port 2 (output) |
| Unused leftovers | `C_buck`, `L_buck`, `Fsw` |

Variables live in the **model workspace**, not the base workspace. Read them with `getVariable(get_param(mdl,'ModelWorkspace'),'name')`.

### Useful relationships
- Kt ≈ Ke ≈ 5.8 mN·m/A (Ke = 1.45 × `psi_m`, measured at `psi_m` = 0.004 and assumed to scale linearly). Phase-pair R = 4 Ω, L = 0.4 mH.
- Torque limit is about 16.5 mN·m, from 12 V × 0.95. The inner P term saturates on speed-command jumps above about 176 rpm.
- Body rate = −Jw/(Jb + Jw) × relative wheel speed, so the outer plant is about k/s with k = 2.463e-4 rad/s per rpm.
- PI rule used: Kp = ωc/k, Ki = Kp·ωc/5. For example ωc = 1 rad/s gives Kp 4061, Ki 812, 78° phase margin, 12% overshoot on a raw step (Kp and Ki were never applied to the model).
- The profile takes about 0.42 s to accelerate, 2.7 s to cruise and 0.42 s to decelerate, reaching the target at about 3.56 s. **Settling time therefore mostly reflects the profile limits, not the PID.**

### Measured result (run on 3 Nov on the unmodified model)

| Metric | Value | Requirement |
|---|---|---|
| Last time outside ±1° of −90° (run ends at 5 s) | 3.647 s | CTR-02 (< 5 s): met |
| Overshoot (peak −1.59065 rad) | 1.26% | CTR-03 (< 10%): met |
| Error at 5 s | −0.0186° | — |
| `cmd_vel` range | −157 to 2250 rpm | **SFT-04 (≤ 600 rpm): not met** |
| Wall-clock time | 335 s | — |

Only this one 5 s slew was run. CTR-01, CTR-04, CTR-07, CTR-08, power and thermal have not been tested on this model. So **SIM-01 is not currently shown by any simulation that exists in the repo.**

To reproduce:
```matlab
cd MATLAB; si = Simulink.SimulationInput('my_bldc_controller');
si = si.setModelParameter('ReturnWorkspaceOutputs','on'); o = sim(si);
a = o.logsout.get('Body_angle').Values; t = a.Time; y = a.Data(:); ref = -pi/2;
settle = t(find(abs(y-ref) > deg2rad(1), 1, 'last'));
overshootPct = max(0, abs(min(y)) - pi/2)/(pi/2)*100;
```
Logged signals: `switchPattern`, `duty`, `Rotor_Speed`, `Theta`, `Phase Voltages`, `Body_angle`, `cmd_vel`.

---

## 7. Known problems and inconsistencies

Most of these haven't been raised with Tama as a set. Items 1–5 matter most, because they decide whether the model's results can support WP1 and the hardware design.

**Model vs design**

1. **Wheel speed vs SFT-04.**
   - The model's Jw is about 1.65e-5 kg·m², so a 0.5 rad/s slew needs about 2030 rpm. A 40 °/s disturbance would need about 2835 rpm.
   - With the sized Jw of 1.2e-4 at `J_body` = 0.007, these fall to about 282 and 394 rpm, which fit the limit.
   - The speed cap isn't modelled at all. The wheel inertia and speed limit have to be reconciled, and `J_flywheel` is the obvious candidate. That larger wheel also changes `k`, so the outer loop needs retuning.
2. **Turntable friction is missing.**
   - The Bearing Friction block sits between rotor and body, and that is the motor's bearing.
   - The body has no friction path to ground; the mechanical reference connects only to the motion sensor.
   - The spec calls turntable friction the main disturbance (estimate about 1 mN·m, PHY-05 ≤ 3 mN·m). Current results are likely optimistic, especially for holding attitude.
3. **Perfect attitude feedback.** The loop feeds back true body angle. CTR-06 requires integrated gyro with noise and bias, and there is no gyro model.
4. **Six-step vs FOC.** The model uses six-step commutation. The plan (WP1, WP4) and ELE-02 specify FOC with a magnetic encoder. Current ripple, torque limit and power figures won't carry straight over. Decide whether this model is the design reference or an intermediate step, and raise it with Tama.
5. **Placeholder physical values.**
   - No motor is selected, and `psi_m`, Rs and Ld are not from a datasheet.
   - The model's Kt of 5.8 mN·m/A is far below the old gimbal placeholder: 100 rpm/V implies about 95 mN·m/A.
   - `J_body` is 0.007 here against 2.01e-3 in the old sim, and I couldn't establish the source.
   - The battery is 11.1 V nominal, 9.0–12.6 V; the model fixes 12 V.
6. **Very high outer gains.** Outer P = 69140 rpm/rad means 1° of error commands about 1207 rpm, with no output limit. They are `pidtune` defaults that Tama set. Stability margins haven't been checked since the switch to zero bias.
7. **Zero-speed behaviour is unverified.** With `w_bias` = 0 the wheel starts at and crosses 0 rpm, where friction and sector-based speed sensing are at their worst. Earlier agents flagged this but no one has studied it. A previous agent recommended comparing 0 and about 3000 rpm bias. Bias only helps if it exceeds the largest speed change, and 2000 rpm was found counterproductive.

**Scripts and files**

8. **`linearise_bldc.m` is broken.** Line 29 uses `[mdl '/Constant']`, and no such block exists (it's `theta_ref`). The script's comments also assume a settled bias speed ("op is ~1.2 V"), but the operating point is now zero speed.
   - The reference now passes through the Speed Profiler, so consider how to hold it at zero.
   - `linearisation_results.mat` is out of date (27 Oct, 2000 rpm bias), and `outer_loop_lineariser.m` loads it.
9. **Snippets in old transcripts use `thRef = pi/2`.** The model is now at `-pi/2`.

**Documents**

10. **`risk-assessment.org` is out of date.** It still says ≤ 6000 rpm and about 20 J at line 25 and hazard 1, against 600 rpm and 0.24 J in the requirements. It also leaves BLE vs Wi-Fi open. The PDF's supervisor approval status is above. Any change of battery type or capacity requires the RA to be revised and re-approved.
11. **`requirements.org` and the plan have diverged.** The register calls itself the single source of truth, but the plan was edited later.
    - PHY-01 and PHY-02: the plan allows 1.5U and says "≤ 1.33 kg target"; the register doesn't.
    - SFT-02: register "> 0.5 s", plan "≤ 0.5 s timeout".
    - The register's mass budget and open inputs are commented out, and it points at the missing `sim/results/requirements.md`.
12. **`.claude/agents/matlab-sim.md` is out of date.** It describes `sim/`, old ATT IDs, 6000 rpm and a torque-commanded plant. Don't use it as written.
13. **`AGENTS.md`** gives the wrong Canvas export location (section 3).

**Repo hygiene**

14. **Nothing is committed**, which is how `sim/` could vanish without trace. I'd recommend asking Tama to approve a first commit and a `.gitignore` for `slprj/`, `*.slxc` and `.DS_Store`. Take care with `MATLAB/slprj/` and the root-level `.slxc` files, which are build artefacts. Don't commit or push without Tama's say-so.
15. **Backup models can't be loaded in place.** Names like `my_bldc_controller.before-buck.slx` aren't valid model names; copy to a temp folder under a new name first.

---

## 8. Tooling

These were set up for the old harness, so the new one needs its own equivalents.

**MATLAB MCP server**
- **Command:** `/Users/tama/Library/Application Support/MathWorks/Agentic Toolkits/v1/bin/matlab-mcp-server`
- **Args:** `--matlab-root=/Applications/MATLAB_R2026a.app --matlab-display-mode=desktop --matlab-session-mode=auto --extension-file "/Users/tama/Library/Application Support/MathWorks/Agentic Toolkits/v1/toolkits/simulink-agentic-toolkit/tools/tools.json" --disable-telemetry`
- **Without `--matlab-root`** it fails with "no valid MATLAB environments found".
- **Tools used:** `evaluate_matlab_code`, `model_overview`, `model_read`, `model_edit`, `model_check`. The MATLAB desktop is visible to Tama.

**Lessons from driving MATLAB**
- **Don't leave variables in the base workspace.** A leftover `pid` variable once shadowed the `pid` function and broke Tama's script. The fix was clearing the base workspace, which also wiped Tama's variables.
- **Don't use `restoredefaultpath`:** it breaks the MCP connection.
- **Run scripts from `MATLAB/`:** `getlinio` otherwise can't find the model.
- **`sim` returns a double** unless `ReturnWorkspaceOutputs` is on.
- **Overrides:** `setModelParameter` with several pairs errored, so use separate calls. Simscape initial-condition overrides didn't apply cleanly through `SimulationInput`; use `set_param` on a temp copy.
- **FRE requirements:** input and output points at the test signal rate, `createFixedTsSinestream`, and at least 3 periods after settling.
- **Autolayout warnings** are noise; wrapping in `evalc` hides them.
- **Solver and timing:** the Partitioning local solver gave NaNs with the old LC filter. A 5 s run takes about 5.5 minutes, so run long jobs in the background.

**Writing setup (global, outside the repo)**
- `~/.local/share/pandoc/defaults/ieee.yaml`, and `~/.local/share/pandoc/csl/ieee.csl` (a symlink to `~/Zotero/styles/ieee.csl`).
- `~/.config/doom/config.org`: "Citations (IEEE)" section; ob-mermaid for the Gantt chart.
- Mermaid Gantt in `Project-Plan.org`, Appendix 1, rendering `gantt.png`.
- `~/.claude/agents/writing-reviewer.md`: Tama's proofreading agent (SPaG, IEEE references). It needs porting if Tama wants it in the new harness.
- Earlier agents put backups in `/tmp`. Treat these as gone.

**Project memory:** the only saved memory is under `~/.claude/projects/-Users-tama-Code-torque-uno/memory/`. Its content is included above, except the older quiz deadline (12 Oct).

---

## 9. Turntable status

- **Design:** two 608-2Z bearings (**7 mm wide**, not the 6 mm W6 variant), 35 mm apart, on a Ø8 h6 shaft in an aluminium housing; hub and base plate with 3-point levelling; removable locking pin.
- **Source of truth:** `docs/workshop-drawing-checklist.md` and the header of `cad/reaction-wheel-turntable.fs`. **These override the original spec** (for example tube Ø34, flange Ø56, PCD Ø44, pin radius 14, hub Ø36, shaft 53.5 mm with 2 ground flats, pin Ø3 × 30 h6).
- **Not in the repo:** finished 2D drawings or a submitted Fabrication Request.
- **Not designed yet, as far as the repo shows:** body frame, flywheel, motor mount, enclosure, mass and inertia report.

---

## 10. Suggested next steps

Nothing here was requested by Tama. Confirm priorities first.

1. **Ask Tama:**
   - Does `sim/` exist elsewhere?
   - Has a motor been chosen?
   - Was the plan submitted, and which file is final?
   - Is any PCB, firmware or body CAD work held elsewhere?
   - Is the six-step model the intended design reference, or a learning step towards FOC?
   - What changed on 31 Oct, and why?
2. **Protect the work:** get approval for a first commit with a `.gitignore`.
3. **Finish WP1:**
   - Choose the motor and put its real values in the model.
   - Reconcile `J_flywheel`, `J_body` and the 600 rpm limit.
   - Add the speed cap and turntable friction.
   - Add a gyro model.
   - Limit the outer PID output and consider rate feedforward from the profiler.
   - Fix the linearisation scripts and retune.
   - Run the missing scenarios and rebuild a results table for SIM-01.
4. **Make the 1U or 1.5U decision by 9 Nov** using real motor dimensions, then start the WP2 and WP3 work that depends on it.
5. **Bring the documents back in line:** register vs plan; risk-assessment draft (600 rpm); `AGENTS.md`; `matlab-sim.md`. Keep edits to tables and facts, and leave prose to Tama.
6. **Prepare for Update 1 (22 Nov):** gather factual tables and results for Tama to present, within Tier 2. Check `marking descriptors Progress.pdf` for what's expected.
