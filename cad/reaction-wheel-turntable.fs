FeatureScript 3083;
import(path : "onshape/std/common.fs", version : "3083.0");

// Bearing turntable for the single-axis reaction-wheel test rig.
// Source spec: docs/bearing-turntable-spec.md. Z = 0 is the housing underside / base-plate top; units mm.
//
// Deviations from the spec (agreed design fixes):
//   A  Lock pin is Ø3 x 30 (not x 20) and the body has a Ø4 access hole above it, so the pin can be
//      fitted/removed with the body on. Seated pin spans Z 37..67.
//   B  Housing tube OD Ø34 (was Ø30), lock pin at radius 14 (was 13): 1.5 mm walls either side of the
//      pin hole. Hub flange Ø36 to match. Knock-on: M4 socket heads (Ø7) on the old Ø40 PCD would hit the
//      Ø34 tube, so the housing flange is Ø56 (was Ø50) and the M4 PCD is Ø44 (was Ø40) on P1 and P5.
//   C  Hub grub screws opposed at 90° and 270° (were 0° and 90°, the 0° one broke into the pin hole).
//      Rotating parts are symmetric: lock-pin holes in the hub and body access holes at 0° and 180°, so
//      the rotor is balanced and can be locked in two positions. The fixed housing keeps one pin hole (0°).
//   D  Shaft top at Z 55.5, 0.5 below the body mounting face.
//   E  Shaft bottom at Z 2 (was 1), giving the spec's 2 mm rotating-to-fixed clearance to the base plate.
//      Shaft length 53.5.
//   Also: lip relief groove instead of an R0.3 corner; two ground flats on the shaft (one per grub screw).
//
// Tapped holes are modelled at tap-drill size (M3 Ø2.5, M4 Ø3.3, M6 Ø5.0).

function revolveRZ(context is Context, id is Id, pts is array) returns Query
{
    var sk = newSketchOnPlane(context, id + "sk", { "sketchPlane" : plane(vector(0, 0, 0) * millimeter, vector(0, -1, 0), vector(1, 0, 0)) });
    var p = [];
    for (var pt in pts)
        p = append(p, vector(pt[0], pt[1]) * millimeter);
    p = append(p, p[0]);
    skPolyline(sk, "pl", { "points" : p });
    skSolve(sk);
    opRevolve(context, id + "rev", {
                "entities" : qSketchRegion(id + "sk"),
                "axis" : line(vector(0, 0, 0) * millimeter, vector(0, 0, 1)),
                "angleForward" : 2 * PI * radian });
    opDeleteBodies(context, id + "del", { "entities" : qCreatedBy(id + "sk", EntityType.BODY) });
    return qCreatedBy(id + "rev", EntityType.BODY);
}

function mkCyl(context is Context, id is Id, p0 is Vector, p1 is Vector, r is number) returns Query
{
    fCylinder(context, id, { "bottomCenter" : p0 * millimeter, "topCenter" : p1 * millimeter, "radius" : r * millimeter });
    return qCreatedBy(id, EntityType.BODY);
}

function mkCuboid(context is Context, id is Id, c0 is Vector, c1 is Vector) returns Query
{
    fCuboid(context, id, { "corner1" : c0 * millimeter, "corner2" : c1 * millimeter });
    return qCreatedBy(id, EntityType.BODY);
}

function subtractAll(context is Context, id is Id, target is Query, tools is array)
{
    opBoolean(context, id, { "tools" : qUnion(tools), "targets" : target, "operationType" : BooleanOperationType.SUBTRACTION });
}

function tagPart(context is Context, q is Query, name is string, matName is string, density is number, col is array)
{
    setProperty(context, { "entities" : q, "propertyType" : PropertyType.NAME, "value" : name });
    setProperty(context, { "entities" : q, "propertyType" : PropertyType.MATERIAL,
                "value" : material(matName, density * gram / (centimeter ^ 3)) });
    setProperty(context, { "entities" : q, "propertyType" : PropertyType.APPEARANCE, "value" : color(col[0], col[1], col[2]) });
}

function polarPt(r is number, deg is number, z is number) returns Vector
{
    return vector(r * cos(deg * degree), r * sin(deg * degree), z);
}

// Simplified 608-2Z: inner ring Ø8–12, outer ring Ø19–22, shields Ø12–19 recessed 0.3 per face.
function bearing608(context is Context, id is Id, z0 is number) returns Query
{
    return revolveRZ(context, id, [[4, z0], [6, z0], [6, z0 + 0.3], [9.5, z0 + 0.3], [9.5, z0], [11, z0], [11, z0 + 7],
                [9.5, z0 + 7], [9.5, z0 + 6.7], [6, z0 + 6.7], [6, z0 + 7], [4, z0 + 7]]);
}

function buildTurntable(context is Context, id is Id, definition is map) returns map
{
    var s = definition.spacing / millimeter; // bearing centre spacing
    var zTop = 10 + s; // housing top = upper bearing top (45)
    var up0 = 3 + s; // upper bearing bottom face (38)
    var hf = definition.hubFlangeDia / millimeter / 2;
    var halfPlate = definition.plateSize / millimeter / 2;
    var bodyR = definition.bodyPcd / millimeter / 2;
    var pinR = 14;
    if (hf < pinR + 3.05)
    {
        throw regenError("Hub flange too small for the lock-pin hole");
    }
    if (halfPlate < 80)
    {
        throw regenError("Base plate must be at least 160 x 160");
    }
    var parts = {};

    // P1 housing: flange Ø56 Z0–6, tube Ø34 to zTop, bore Ø22 H7 down to Z3, lip Ø19, relief groove at the lip corner
    var p1 = revolveRZ(context, id + "p1", [[9.5, 0], [27.5, 0], [28, 0.5], [28, 5.5], [27.5, 6], [17, 6], [17, zTop - 0.5],
                [16.5, zTop], [11.5, zTop], [11, zTop - 0.5], [11, 3.4], [11.2, 3.4], [11.2, 2.8], [10.8, 2.8], [10.8, 3], [9.5, 3]]);
    var t1 = [];
    for (var i = 0; i < 4; i += 1)
    {
        t1 = append(t1, mkCyl(context, id + ("p1m" ~ i), polarPt(22, 45 + 90 * i, -1), polarPt(22, 45 + 90 * i, 7), 2.25));
    }
    // Lock-pin hole: drilled 10 deep, reamed Ø3 H7 to 8 deep
    t1 = append(t1, mkCyl(context, id + "p1pin", vector(pinR, 0, zTop - 10), vector(pinR, 0, zTop + 1), 1.5));
    subtractAll(context, id + "p1cut", p1, t1);
    tagPart(context, p1, "P1 Bearing housing", "Aluminium 6082-T6", 2.70, [0.78, 0.80, 0.84]);
    parts["P1 housing"] = p1;

    // P2 outer-ring spacer: length = spacing - 7
    var p2 = revolveRZ(context, id + "p2", [[9.5, 10], [10.7, 10], [11, 10.3], [11, up0 - 0.3], [10.7, up0], [9.5, up0]]);
    tagPart(context, p2, "P2 Outer-ring spacer", "Aluminium 6082-T6", 2.70, [0.55, 0.65, 0.80]);
    parts["P2 spacer"] = p2;

    var b1 = bearing608(context, id + "b1", 3);
    var b2 = bearing608(context, id + "b2", up0);
    tagPart(context, b1, "P6 Bearing 608-2Z lower", "Bearing steel", 7.85, [0.35, 0.35, 0.38]);
    tagPart(context, b2, "P6 Bearing 608-2Z upper", "Bearing steel", 7.85, [0.35, 0.35, 0.38]);
    parts["P6 lower bearing"] = b1;
    parts["P6 upper bearing"] = b2;

    // P3 shaft Ø8 h6, Z 2 .. zTop+10.5, ground flats 0.5 deep at 90° and 270°
    var p3 = revolveRZ(context, id + "p3", [[0, 2], [3.5, 2], [4, 2.5], [4, zTop + 10], [3.5, zTop + 10.5], [0, zTop + 10.5]]);
    var f1 = mkCuboid(context, id + "p3f1", vector(-5, 3.5, zTop + 2.5), vector(5, 5, zTop + 11));
    var f2 = mkCuboid(context, id + "p3f2", vector(-5, -5, zTop + 2.5), vector(5, -3.5, zTop + 11));
    subtractAll(context, id + "p3cut", p3, [f1, f2]);
    tagPart(context, p3, "P3 Shaft", "Steel, hardened", 7.85, [0.60, 0.60, 0.62]);
    parts["P3 shaft"] = p3;

    // P4 hub: Ø11 boss on the upper inner ring only, flange top = body mounting face (zTop+11)
    var p4 = revolveRZ(context, id + "p4", [[4.3, zTop], [5.5, zTop], [5.5, zTop + 2], [hf - 0.5, zTop + 2], [hf, zTop + 2.5],
                [hf, zTop + 10.5], [hf - 0.5, zTop + 11], [4.3, zTop + 11], [4, zTop + 10.7], [4, zTop + 0.3]]);
    var t4 = [];
    t4 = append(t4, mkCyl(context, id + "p4pin", vector(pinR, 0, zTop + 1), vector(pinR, 0, zTop + 12), 1.55));
    t4 = append(t4, mkCyl(context, id + "p4pin2", vector(-pinR, 0, zTop + 1), vector(-pinR, 0, zTop + 12), 1.55));
    t4 = append(t4, mkCyl(context, id + "p4g1", vector(0, 3, zTop + 6.5), vector(0, hf + 1, zTop + 6.5), 1.25));
    t4 = append(t4, mkCyl(context, id + "p4g2", vector(0, -3, zTop + 6.5), vector(0, -hf - 1, zTop + 6.5), 1.25));
    for (var i = 0; i < 4; i += 1)
    {
        // M3 x 6 thread, drilled 7.5
        t4 = append(t4, mkCyl(context, id + ("p4m" ~ i), polarPt(bodyR, 45 + 90 * i, zTop + 3.5), polarPt(bodyR, 45 + 90 * i, zTop + 12), 1.25));
    }
    subtractAll(context, id + "p4cut", p4, t4);
    tagPart(context, p4, "P4 Body hub", "Aluminium 6082-T6", 2.70, [0.85, 0.55, 0.25]);
    parts["P4 hub"] = p4;

    // P7 lock pin Ø3 x 30: seated, or parked on the base plate
    var pinZ = 0;
    var pinXY = vector(-60, 60, 0);
    if (definition.pinFitted)
    {
        pinZ = zTop - 8;
        pinXY = vector(pinR, 0, 0);
    }
    var p7 = revolveRZ(context, id + "p7", [[0, pinZ], [1.2, pinZ], [1.5, pinZ + 0.3], [1.5, pinZ + 29.7], [1.2, pinZ + 30], [0, pinZ + 30]]);
    opTransform(context, id + "p7pos", { "bodies" : p7, "transform" : transform(pinXY * millimeter) });
    tagPart(context, p7, "P7 Locking pin", "Steel", 7.85, [0.80, 0.15, 0.15]);
    parts["P7 pin"] = p7;

    // P5 base plate Z -10..0: M4 on Ø44 PCD, M6 levelling on Ø170 PCD at 90/210/330
    var p5 = mkCuboid(context, id + "p5", vector(-halfPlate, -halfPlate, -10), vector(halfPlate, halfPlate, 0));
    var t5 = [];
    for (var i = 0; i < 4; i += 1)
    {
        t5 = append(t5, mkCyl(context, id + ("p5m" ~ i), polarPt(22, 45 + 90 * i, -11), polarPt(22, 45 + 90 * i, 1), 1.65));
    }
    var lev = [90, 210, 330];
    for (var i = 0; i < 3; i += 1)
    {
        t5 = append(t5, mkCyl(context, id + ("p5l" ~ i), polarPt(85, lev[i], -11), polarPt(85, lev[i], 1), 2.5));
    }
    subtractAll(context, id + "p5cut", p5, t5);
    tagPart(context, p5, "P5 Base plate", "Aluminium 6082-T6", 2.70, [0.45, 0.47, 0.50]);
    parts["P5 plate"] = p5;

    // 1U body clearance envelope with Ø4 pin access holes above both hub pin holes
    if (definition.showBody)
    {
        var bd = mkCuboid(context, id + "body", vector(-50, -50, zTop + 11), vector(50, 50, zTop + 111));
        var acc = mkCyl(context, id + "bodyacc", vector(pinR, 0, zTop + 10), vector(pinR, 0, zTop + 36), 2);
        var acc2 = mkCyl(context, id + "bodyacc2", vector(-pinR, 0, zTop + 10), vector(-pinR, 0, zTop + 36), 2);
        subtractAll(context, id + "bodycut", bd, [acc, acc2]);
        tagPart(context, bd, "Body 1U (clearance envelope)", "Placeholder", 1.33, [0.30, 0.70, 0.45]);
        parts["Body"] = bd;
    }
    return parts;
}

annotation { "Feature Type Name" : "ReactionWheelTurntable" }
export const reactionWheelTurntable = defineFeature(function(context is Context, id is Id, definition is map)
    precondition
    {
        annotation { "Name" : "Bearing centre spacing" }
        isLength(definition.spacing, NONNEGATIVE_LENGTH_BOUNDS);
        annotation { "Name" : "Hub flange diameter" }
        isLength(definition.hubFlangeDia, NONNEGATIVE_LENGTH_BOUNDS);
        annotation { "Name" : "Base plate size" }
        isLength(definition.plateSize, NONNEGATIVE_LENGTH_BOUNDS);
        annotation { "Name" : "Body bolt pitch-circle diameter" }
        isLength(definition.bodyPcd, NONNEGATIVE_LENGTH_BOUNDS);
        annotation { "Name" : "Pin fitted" }
        definition.pinFitted is boolean;
        annotation { "Name" : "Show body envelope" }
        definition.showBody is boolean;
    }
    {
        buildTurntable(context, id, definition);
    }, { spacing : 35 * millimeter, hubFlangeDia : 36 * millimeter, plateSize : 200 * millimeter,
        bodyPcd : 22 * millimeter, pinFitted : true, showBody : true });
