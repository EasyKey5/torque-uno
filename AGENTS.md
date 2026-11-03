# torque-uno

ELEC340 BEng final year project (University of Liverpool, 2026/27): a
reaction wheel for a CubeSat. Supervisor: Dr Kai Hoettges.

Canvas module export (deadlines, templates, marking descriptors) is in
`202627-ELEC340---BEng-Project-*/viewer/files/`. Working documents are in
`docs/` (risk assessment: `docs/risk-assessment.org`).

Assessed reports are AI "Tier 2": draft calculations, tables, code and
structure, but the user writes all report prose.

## Original project brief

Reaction Wheels are a key component to control the orientation of a
spacecraft by transferring angular momentum from the spacecraft to a fast
spinning mass.

The main component of this project is to model and create a reaction wheel
for a cubesat system. This will be comprised of a flywheel being spun by a
custom designed motor controller, PCB and control system, via a
microcontroller.

Prior to physical development, the system will be modelled in MATLAB to
ensure good control theory and system design before development.

The whole system should be designed to be compact as possible due to
limitations of space within cubesats.

The system will be a prototype and not space ready but space related issues
of heat and energy should be considered.

### Aspirational / further development goals

- Duplicate or triple the system to provide 2–3 axis rotation. Linear/
  incremental rotations, i.e. x rotation followed by y rotation etc.
- Implementation of a magnetorquer to provide additional rotation movement,
  modelled in the same control system as the attitude reaction wheel.
- Battery/power system for meeting the power demands of the system.
  (Ensuring power requirements are low is part of the main project goals.)
