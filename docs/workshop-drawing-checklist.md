# Workshop drawing checklist: bearing turntable

Notes to put on the 2D drawings for P1, P2, P4 and P5, plus a cutting note for P3. The
dimensions follow the Onshape model (`cad/reaction-wheel-turntable.fs`), not the original spec
where they differ (see "Changes from the spec" at the end).

Every drawing needs:

- [ ] Title block: part number and name, material, quantity, units mm, projection symbol, revision
- [ ] "General tolerance ±0.1 unless stated"
- [ ] "Break all sharp edges 0.2 max unless stated"
- [ ] Datum **A** = axis of the main bore (P1, P2, P4)

## P1: Bearing housing (6082-T6, qty 1)

| Feature | Dimension / tolerance |
|---|---|
| Overall height | 45 |
| Flange | Ø56 × 6 thick, 0.5 × 45° chamfer on both outer edges |
| Tube | Ø34 OD, 0.5 × 45° chamfer on the top outer edge |
| Main bore (datum A) | **Ø22 H7 (+0.021 / 0)**, 42 deep from the top face, Ra 1.6 |
| Bore entry chamfer | 0.5 × 45° at the top face |
| Lip hole | Ø19 through (lip is 3 thick) |
| Lip corner | Relief undercut 0.4 × 0.4, 0.2 deep into both the lip face and the bore wall. **No corner radius**, so the bearing seats flat |
| Mounting holes | 4 × Ø4.5 through, on a **Ø44 PCD**, at 45°, 135°, 225° and 315° |
| Lock-pin hole | **Ø3 H7 (+0.010 / 0)**, reamed 8 deep, drilled Ø2.8 × 10 deep. At **R14.00 ± 0.03** from A, on the 0° (+X) line |

Notes:

- [ ] **"Machine the Ø22 bore, the lip face and the Ø19 lip hole in one setup"**
- [ ] Ø19 lip hole coaxial with A within Ø0.02
- [ ] Top face, bottom face and lip face (the lower bearing seat) each perpendicular to A within 0.02
- [ ] Lock-pin radius tolerance: only the radius matters. The hub can rotate to line up, so the angle can stay at ±0.5°

## P2: Outer-ring spacer (6082-T6 or acetal, qty 1)

| Feature | Dimension / tolerance |
|---|---|
| OD | **Ø22 −0.02 / −0.05** (21.95 to 21.98), sliding fit in P1 |
| ID | **Ø19 +0.1 / 0**. It must not be under Ø19, or it will touch the bearing shields |
| Length | **28.00 ± 0.05** (= bearing spacing − 7) |
| Chamfers | 0.3 × 45° on the outer edges, both ends |

Notes:

- [ ] Ends parallel within 0.02
- [ ] Both ends perpendicular to A (the OD axis) within 0.02
- [ ] If made in acetal: expect about 0.03 mm length change per 10 °C. That's acceptable, because only the 2 mm hub gap changes

## P4: Body hub (6082-T6, qty 1)

| Feature | Dimension / tolerance |
|---|---|
| Flange | **Ø36** × 9 thick, 0.5 × 45° chamfer on both outer edges |
| Boss | **Ø11 0 / −0.2** × 2.0 high. It must not be over Ø11, or it will touch the shields |
| Bore (datum A) | **Ø8 H7 (+0.015 / 0)** through, 0.3 × 45° chamfer both ends |
| Grub-screw holes | 2 × M3 tapped radial, through to the bore, **4.5 below the top face**, opposed at **90° and 270°** |
| Body mounting holes | 4 × M3 × 6 thread depth, drilled Ø2.5 × 7.5, on a Ø22 PCD, at 45°, 135°, 225° and 315° |
| Lock-pin holes | **2 × Ø3.1 +0.05 / 0** through the flange, at **R14.00 ± 0.03** from A, at **0° and 180°** |

Notes:

- [ ] **"Face the top surface and bore Ø8 in one setup"**
- [ ] Top face (body mounting face) perpendicular to A within 0.02
- [ ] Boss underside (it seats on the bearing inner ring) perpendicular to A within 0.02, and parallel to the top face within 0.02. If this face is out of square, the body tilts just as much as it would from a bad top face
- [ ] Deburr the bore after tapping the radial holes, so the shaft still slides in
- [ ] Assembly note: seat the hub on the bearing inner ring (press down) before tightening the grub screws, then tighten them alternately. The opposed screws don't pull the shaft against the bore, so the boss face sets the squareness

## P5: Base plate (aluminium plate, qty 1)

| Feature | Dimension / tolerance |
|---|---|
| Size | 200 × 200 × 10 |
| Housing holes | 4 × M4 tapped through, on a **Ø44 PCD** centred on the plate, at 45°, 135°, 225° and 315° |
| Levelling holes | 3 × M6 tapped through, on a Ø170 PCD, at 90°, 210° and 330° (0° = +X) |

Notes:

- [ ] Top face flat within 0.05 over the Ø60 area under the housing (face it if the stock isn't flat)
- [ ] Keep the ±X edge strips (20 mm wide) clear for G-clamps; put packers under the clamp points
- [ ] Material: tooling plate (e.g. cast 5083) or 6082-T6. Plywood is acceptable as a placeholder only

## P3: Shaft cutting note (bought Ø8 h6 hardened ground shaft, qty 1)

- [ ] Cut to **53.5** long, 0.5 × 45° chamfer both ends
- [ ] 2 flats, 0.5 deep, 8 long, running out at the top end, **diametrically opposite (180° apart)**, lined up with the hub grub screws
- [ ] The stock is hardened, so the flats must be **ground or EDM'd**. They can't be milled
- [ ] If the shaft is too tight in the bearings, use Ø8 g6 instead

## Bought parts and fasteners

| Item | Qty | Note |
|---|---|---|
| 608-2Z bearing, **7 mm wide** | 2 (+2 spare open 608) | Not the 6 mm "W6" variant |
| Lock pin Ø3 × 30, **h6** (ground pin or ejector pin) | 1 | Standard dowels are m6, which is a tight fit in the H7 hole. The pin has to come out by hand |
| M4 × 14 socket cap screws | 4 | Was × 12 in the spec. × 14 gives 8 mm of thread in the plate |
| M3 × 4 cup-point grub screws | 2 | 1.5 mm hex key |
| M3 socket cap screws (body to hub) | 4 | Length = body plate thickness + 5 |
| M6 levelling screws with lock nuts | 3 | |

## Changes from the spec

Make sure the drawings use these values, not the spec values:

| Item | Spec | Drawing |
|---|---|---|
| Housing tube OD | Ø30 | **Ø34** |
| Housing flange | Ø50 | **Ø56** |
| M4 PCD (P1 and P5) | Ø40 | **Ø44** |
| Lock-pin radius (P1 and P4) | R13 | **R14** |
| Hub flange | Ø30 | **Ø36** |
| Hub grub screws | 0° and 90° | **90° and 270° (opposed)** |
| Hub lock-pin holes | 1 at 0° | **2, at 0° and 180°** (housing keeps 1, at 0°) |
| Body bottom plate | Not specified | **2 × Ø4 pin access holes at R14, 0° and 180°** |
| Shaft | 55 long, Z 1 to 56 | **53.5 long, Z 2 to 55.5** |
| Shaft flats | 1 | **2** |
| Lock pin | Ø3 × 20 | **Ø3 × 30 h6** |
| Lip corner | Undercut or R ≤ 0.3 | **Undercut only** |
| M4 screws | × 12 | **× 14** |
