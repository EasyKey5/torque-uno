# Bearing turntable for a single-axis reaction-wheel test rig: 3D modelling brief

## 1. Purpose and design intent

The rig demonstrates attitude control of a CubeSat-style body about **one vertical axis**. A 1U body (10 × 10 × 10 cm, ≤ 1.33 kg, battery-powered, with no wires to the base) sits on top of a vertical **8 mm steel shaft**. The shaft turns in **two deep-groove ball bearings** held in an aluminium **housing**, and the housing is bolted to a fixed, levelled **base plate**.

The design priorities, in order:
1. **Low and repeatable friction** about the vertical axis. Friction is the main disturbance torque, and it will be measured.
2. **No tilting or wobble** of the body. The two bearings are spaced 35 mm apart so that tipping moments become small sideways forces on the bearings. A single bearing would let the body rock.
3. **The rotation axis must be accurately vertical, and perpendicular to the body's mounting face.** A tilted axis lets gravity apply torque about the axis, and it misaligns the onboard gyro.
4. **The body and shaft lift straight out** of the housing for maintenance, and the bearings can be swapped. Both bearing pairs will be friction-tested.
5. **The rotating parts can be locked** to the base with a pin, for safe firmware testing.

The mechanical workshop will machine the parts, so produce workshop-ready parts and drawings.

## 2. Coordinate system

- **Z axis** = the rotation axis, pointing up. **Z = 0** is the underside of the housing, which is also the top surface of the base plate.
- X and Y are horizontal. Every part is centred on the Z axis unless stated otherwise.
- Units are mm.

## 3. Parts list

| # | Part | Qty | Material | Source |
|---|---|---|---|---|
| P1 | Bearing housing | 1 | Aluminium 6082-T6 | Machined |
| P2 | Outer-ring spacer | 1 | Aluminium 6082 or acetal (Delrin) | Machined |
| P3 | Shaft | 1 | Hardened, ground steel shaft, Ø8 h6 (linear-shaft stock) | Bought, cut to length |
| P4 | Body hub | 1 | Aluminium 6082-T6 | Machined |
| P5 | Base plate | 1 | Aluminium plate (or 18 mm plywood as a placeholder) | Machined or cut |
| P6 | Ball bearing **608-2Z** (also sold as 608-ZZ): bore 8, OD 22, **width 7** | 2 (+2 spare open 608s, same dimensions) | Bearing steel | Bought |
| P7 | Locking pin, Ø3 × 20 dowel | 1 | Steel | Bought |
| — | M4 × 12 socket cap screws (housing to base) | 4 | Steel | Bought |
| — | M3 × 4 cup-point grub screws (hub to shaft) | 2 | Steel | Bought |
| — | M3 socket cap screws (body to hub; length set by the body plate thickness) | 4 | Steel | Bought |
| — | M6 levelling screws with lock nuts | 3 | Steel | Bought |

**Bearing warning:** some "608-2Z" variants (e.g. ZEN 608-2Z-W6) are **6 mm wide**. Model and specify the standard **7 mm** width.

**Bearing abutment rules.** Model these accurately, because breaking them causes friction:
- On the **inner ring**, only touch the annulus from **Ø8 to Ø11**.
- On the **outer ring**, only touch the annulus from **Ø19 to Ø22**.
- Nothing may touch the **shields**, which sit roughly between Ø12 and Ø19 on each face.

## 4. Part details

### P1: Bearing housing (fixed)

A stepped cylinder: a mounting flange at the bottom and a tube above it.

| Feature | Dimension |
|---|---|
| Mounting flange | Ø50, from Z = 0 to Z = 6 |
| Tube | OD Ø30, from Z = 6 to Z = 45 (top face at **Z = 45**) |
| Main bore | **Ø22 H7** (+0.021 / 0), from Z = 45 down to Z = 3 (depth 42) |
| Bottom lip | Z = 0 to Z = 3, through-hole **Ø19** (supports the lower bearing's outer ring only) |
| Bore entry chamfer | 0.5 × 45° at Z = 45 |
| Internal corner at the lip | Undercut, or radius ≤ 0.3, so the bearing seats flat |
| Mounting holes | 4 × Ø4.5 through the flange, on a **Ø40 pitch circle**, at 45°, 135°, 225° and 315° |
| Lock-pin hole | 1 × **Ø3 H7**, 8 deep, into the tube top face at **radius 13**, angle 0° (on +X) |

**Critical:** the main bore and the lip hole must be machined in **one setup**, so the two bearing seats are concentric. The top and bottom faces must be perpendicular to the bore axis within 0.02 mm. Put both notes on the drawing.

### P2: Outer-ring spacer (fixed)

A plain tube that holds the two bearings' outer rings apart.

| Feature | Dimension |
|---|---|
| OD | Ø22, sliding fit in the housing bore (−0.02 / −0.05) |
| ID | Ø19 (clears the bearing shields) |
| Length | **28.0**, with ends parallel within 0.02 mm |
| Position | Z = 10 to Z = 38 |

### P6: Bearing positions

| Bearing | Z range | Centre |
|---|---|---|
| Lower | Z = 3 to 10 (outer ring rests on the lip) | Z = 6.5 |
| Upper | Z = 38 to 45 (top face flush with the housing top) | Z = 41.5 |

That puts the bearing centres **35 mm apart**.

The outer rings are a sliding or light fit in the Ø22 H7 bore. Gravity holds the stack down: upper outer ring → spacer → lower outer ring → lip. **No retaining compound** is used, so the bearings can be swapped.

### P3: Shaft (rotates with the body)

| Feature | Dimension |
|---|---|
| Diameter | **Ø8 h6**, hardened and ground |
| Length | **55**, from Z = 1 to Z = 56 |
| End chamfers | 0.5 × 45° at both ends |
| Grub-screw flat | 0.5 deep, 8 long, from Z = 47.5 to Z = 55.5, under the hub's grub screws |

The shaft is a **sliding fit** in both bearing bores, so it lifts out with the body. If an h6 shaft turns out too tight in the bearings, switch to g6. Below the lower bearing, the shaft end hangs 2 mm into the Ø19 lip hole with clearance all round.

### P4: Body hub (rotates)

This part carries the body's weight onto the **upper bearing's inner ring only**, and provides the mounting face for the body.

| Feature | Dimension |
|---|---|
| Boss (underside) | **Ø11** × 2 high, from Z = 45 to Z = 47. It rests on the upper inner ring |
| Flange | Ø30 × 9, from Z = 47 to **Z = 56** (top face = body mounting face) |
| Bore | **Ø8 H7** through |
| Grub screws | 2 × M3 tapped radial holes at **Z = 51.5**, at 0° and 90° |
| Body mounting holes | 4 × M3 tapped, 6 deep, from the top face, on a **Ø22 pitch circle**, at 45°, 135°, 225° and 315° |
| Lock-pin hole | 1 × Ø3.1 through the flange at **radius 13**, angle 0°. It lines up with the housing's lock-pin hole |
| Clearance to the fixed housing | 2 mm axially (flange underside at Z = 47 vs housing top at Z = 45) |

**Critical:** face the top surface and bore Ø8 in **one setup**. The top face must be perpendicular to the bore within 0.02 mm. This makes the body, and the gyro on it, perpendicular to the rotation axis.

The body's bottom plate bolts to the hub top face at Z = 56. Model the body as a simple **100 × 100 × 100 mm block** above Z = 56, centred on the axis, for checking clearances only.

### P7: Locking pin

A Ø3 × 20 dowel. When fitted, it passes down through the hub hole into the housing hole, locking rotation. In normal running it's removed. Model it as a separate body so the assembly can be shown both locked and unlocked.

### P5: Base plate (fixed)

| Feature | Dimension |
|---|---|
| Size | **200 × 200 × 10** (adjustable, but must be at least 160 × 160 so the body can't overhang it) |
| Housing mounting | 4 × M4 tapped holes on a Ø40 pitch circle, matching P1, centred on the plate |
| Levelling | 3 × M6 tapped holes for levelling screws on a **Ø170 pitch circle** at 90°, 210° and 330° |
| Clamping | Leave clear edges at least 20 mm wide on two opposite sides for G-clamps to the bench |

Three-point levelling stops the plate rocking and lets the axis be set vertical with a spirit level placed on the hub top face.

## 5. Assembly constraints (summary)

1. All parts are coaxial with the Z axis.
2. Load path (axial, downward): body → hub → **Ø11 boss** → upper bearing inner ring → balls → upper outer ring → spacer → lower outer ring → lip of P1 → base plate.
3. The lower bearing carries **sideways load only**. Nothing presses on its inner ring.
4. Rotating parts (P3, P4, the body, the inner rings) keep **≥ 2 mm clearance** from all fixed parts, except at the bearings and the lock pin.
5. Nothing touches the bearing shields (see the abutment rules in section 3).
6. The body and shaft can be lifted out vertically together. Nothing on the shaft prevents this.

## 6. Interference and clearance checks to run

- Hub flange underside against housing top: 2 mm gap.
- Hub boss Ø11 against the upper bearing: it touches the inner ring only.
- Shaft end against the lip hole Ø19: clearance all round.
- Spacer ID Ø19 and lip hole Ø19 against the shields: no contact.
- Body block (100 mm cube) against the base plate and housing flange: it clears everything.
- Lock-pin hole alignment: Ø3 at radius 13 on both the hub and the housing.

## 7. Deliverables

1. Separate part files for P1–P5 and P7, plus bearing models (a simplified 8 × 22 × 7 ring model is fine).
2. An assembly with the constraints above, in two configurations: **pin fitted** and **pin removed**.
3. A section view through the XZ plane showing the bearing stack, load path and clearances.
4. STEP exports of every part and the assembly.
5. 2D workshop drawings for **P1, P2, P4 and P5**, with:
   - fits (Ø22 H7, Ø8 H7)
   - the perpendicularity and concentricity notes above
   - "machine bores in one setup" on P1 and P4
   - material on every drawing, with general tolerance ±0.1 unless stated

## 8. Things that may change (keep them parametric)

- Bearing spacing (35 mm) → spacer length = spacing − 7.
- Base plate size and material.
- Body bolt-hole pattern on the hub, which depends on the body's bottom-plate design.
- Hub flange diameter (Ø30).

## 9. Open checks before machining

The abutment diameters, fits, 35 mm spacing and hub layout are design choices, not catalogue values. Check them with the mechanical workshop. Confirm the abutment diameters against the datasheet of the exact bearing ordered.
