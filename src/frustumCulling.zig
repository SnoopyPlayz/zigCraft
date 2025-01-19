const std = @import("std");
const ray = @import("raylib.zig");
const player = @import("player.zig");
const map = @import("map.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

fn DistanceToPlane(plane: ray.Vector4, x: f32, y: f32, z: f32) f32{
    return (plane.x * x + plane.y * y + plane.z * z + plane.w);
}

fn PointInFrustum(frustum: [6]ray.Vector4, x: f32, y: f32, z: f32) bool{
//    if (frustum == NULL)
//        return false;

    for (0..6) |i|{
        if (DistanceToPlane(frustum[i], x, y, z) <= 0) // point is behind plane
            return false;
    }

    return true;
}

const FrustumPlanes = enum {
    Back,
    Front,
    Bottom,
    Top,
    Right,
    Left,
    MAX
};

fn ExtractFrustum(frustum: *[6]ray.Vector4) void{
    const projection = ray.rlGetMatrixProjection();
    const modelview = ray.rlGetMatrixModelview();

    var planes:ray.Matrix = undefined;

    planes.m0 = modelview.m0 * projection.m0 + modelview.m1 * projection.m4 + modelview.m2 * projection.m8 + modelview.m3 * projection.m12;
    planes.m1 = modelview.m0 * projection.m1 + modelview.m1 * projection.m5 + modelview.m2 * projection.m9 + modelview.m3 * projection.m13;
    planes.m2 = modelview.m0 * projection.m2 + modelview.m1 * projection.m6 + modelview.m2 * projection.m10 + modelview.m3 * projection.m14;
    planes.m3 = modelview.m0 * projection.m3 + modelview.m1 * projection.m7 + modelview.m2 * projection.m11 + modelview.m3 * projection.m15;
    planes.m4 = modelview.m4 * projection.m0 + modelview.m5 * projection.m4 + modelview.m6 * projection.m8 + modelview.m7 * projection.m12;
    planes.m5 = modelview.m4 * projection.m1 + modelview.m5 * projection.m5 + modelview.m6 * projection.m9 + modelview.m7 * projection.m13;
    planes.m6 = modelview.m4 * projection.m2 + modelview.m5 * projection.m6 + modelview.m6 * projection.m10 + modelview.m7 * projection.m14;
    planes.m7 = modelview.m4 * projection.m3 + modelview.m5 * projection.m7 + modelview.m6 * projection.m11 + modelview.m7 * projection.m15;
    planes.m8 = modelview.m8 * projection.m0 + modelview.m9 * projection.m4 + modelview.m10 * projection.m8 + modelview.m11 * projection.m12;
    planes.m9 = modelview.m8 * projection.m1 + modelview.m9 * projection.m5 + modelview.m10 * projection.m9 + modelview.m11 * projection.m13;
    planes.m10 = modelview.m8 * projection.m2 + modelview.m9 * projection.m6 + modelview.m10 * projection.m10 + modelview.m11 * projection.m14;
    planes.m11 = modelview.m8 * projection.m3 + modelview.m9 * projection.m7 + modelview.m10 * projection.m11 + modelview.m11 * projection.m15;
    planes.m12 = modelview.m12 * projection.m0 + modelview.m13 * projection.m4 + modelview.m14 * projection.m8 + modelview.m15 * projection.m12;
    planes.m13 = modelview.m12 * projection.m1 + modelview.m13 * projection.m5 + modelview.m14 * projection.m9 + modelview.m15 * projection.m13;
    planes.m14 = modelview.m12 * projection.m2 + modelview.m13 * projection.m6 + modelview.m14 * projection.m10 + modelview.m15 * projection.m14;
    planes.m15 = modelview.m12 * projection.m3 + modelview.m13 * projection.m7 + modelview.m14 * projection.m11 + modelview.m15 * projection.m15;

    frustum[@intFromEnum(FrustumPlanes.Right)] = ray.Vector4{.x = planes.m3 - planes.m0, .y = planes.m7 - planes.m4, .z = planes.m11 - planes.m8, .w = planes.m15 - planes.m12 };
    frustum[@intFromEnum(FrustumPlanes.Right)] = ray.Vector4Normalize(frustum[@intFromEnum(FrustumPlanes.Right)]);

    frustum[@intFromEnum(FrustumPlanes.Left)] = ray.Vector4{ .x = planes.m3 + planes.m0, .y = planes.m7 + planes.m4, .z = planes.m11 + planes.m8, .w = planes.m15 + planes.m12 };
    frustum[@intFromEnum(FrustumPlanes.Left)] = ray.Vector4Normalize(frustum[@intFromEnum(FrustumPlanes.Left)]);

    frustum[@intFromEnum(FrustumPlanes.Top)] = ray.Vector4{ .x = planes.m3 - planes.m1, .y = planes.m7 - planes.m5, .z = planes.m11 - planes.m9, .w = planes.m15 - planes.m13 };
    frustum[@intFromEnum(FrustumPlanes.Top)] = ray.Vector4Normalize(frustum[@intFromEnum(FrustumPlanes.Top)]);

    frustum[@intFromEnum(FrustumPlanes.Bottom)] = ray.Vector4{ .x = planes.m3 + planes.m1, .y = planes.m7 + planes.m5, .z = planes.m11 + planes.m9, .w = planes.m15 + planes.m13 };
    frustum[@intFromEnum(FrustumPlanes.Bottom)] = ray.Vector4Normalize(frustum[@intFromEnum(FrustumPlanes.Bottom)]);

    frustum[@intFromEnum(FrustumPlanes.Back)] = ray.Vector4{ .x = planes.m3 - planes.m2, .y = planes.m7 - planes.m6, .z = planes.m11 - planes.m10, .w = planes.m15 - planes.m14 };
    frustum[@intFromEnum(FrustumPlanes.Back)] = ray.Vector4Normalize(frustum[@intFromEnum(FrustumPlanes.Back)]);

    frustum[@intFromEnum(FrustumPlanes.Front)] = ray.Vector4{ .x = planes.m3 + planes.m2, .y = planes.m7 + planes.m6, .z = planes.m11 + planes.m10, .w = planes.m15 + planes.m14 };
    frustum[@intFromEnum(FrustumPlanes.Front)] = ray.Vector4Normalize(frustum[@intFromEnum(FrustumPlanes.Front)]);
}

pub fn isChunkVisible(position: anytype) bool{
    const min = util.toVec3(position);
    const max = ray.Vector3Add(min, .{.x = map.chunkSize, .y = map.chunkSize, .z = map.chunkSize});

    const pojMatrix = ray.GetCameraMatrix(player.camera);

    var planes: [6]ray.Vector4 = undefined;
    planes[0] = ray.Vector4{.x = pojMatrix.m3 + pojMatrix.m0, 
                        .y = pojMatrix.m7 + pojMatrix.m4,
                        .z = pojMatrix.m11 + pojMatrix.m8, 
                        .w = pojMatrix.m15 + pojMatrix.m12}; // Left
    planes[1] = ray.Vector4{.x = pojMatrix.m3 - pojMatrix.m0, 
                        .y = pojMatrix.m7 - pojMatrix.m4,
                        .z = pojMatrix.m11 - pojMatrix.m8, 
                        .w = pojMatrix.m15 - pojMatrix.m12}; // Right
    planes[2] = ray.Vector4{.x = pojMatrix.m3 + pojMatrix.m1, 
                        .y = pojMatrix.m7 + pojMatrix.m5,
                        .z = pojMatrix.m11 + pojMatrix.m9, 
                        .w = pojMatrix.m15 + pojMatrix.m13}; // Bottom
    planes[3] = ray.Vector4{.x = pojMatrix.m3 - pojMatrix.m1, 
                        .y = pojMatrix.m7 - pojMatrix.m5,
                        .z = pojMatrix.m11 - pojMatrix.m9, 
                        .w = pojMatrix.m15 - pojMatrix.m13}; // Top
    planes[4] = ray.Vector4{.x = pojMatrix.m3 + pojMatrix.m2, 
                        .y = pojMatrix.m7 + pojMatrix.m6,
                        .z = pojMatrix.m11 + pojMatrix.m10, 
                        .w = pojMatrix.m15 + pojMatrix.m14}; // Near
    planes[5] = ray.Vector4{.x = pojMatrix.m3 - pojMatrix.m2, 
                        .y = pojMatrix.m7 - pojMatrix.m6,
                        .z = pojMatrix.m11 - pojMatrix.m10, 
                        .w = pojMatrix.m15 - pojMatrix.m14}; // Far

    ExtractFrustum(&planes);

    // if any point is in and we are good
    if (PointInFrustum(planes, min.x, min.y, min.z))
        return true;

    if (PointInFrustum(planes, min.x, max.y, min.z))
        return true;

    if (PointInFrustum(planes, max.x, max.y, min.z))
        return true;

    if (PointInFrustum(planes, max.x, min.y, min.z))
        return true;

    if (PointInFrustum(planes, min.x, min.y, max.z))
        return true;

    if (PointInFrustum(planes, min.x, max.y, max.z))
        return true;

    if (PointInFrustum(planes, max.x, max.y, max.z))
        return true;

    if (PointInFrustum(planes, max.x, min.y, max.z))
        return true;

    // check to see if all points are outside of any one plane, if so the entire box is outside
    for (0..6)|i|
    {
        var oneInside = false;

        if (DistanceToPlane(planes[i], min.x, min.y, min.z) >= 0)
            oneInside = true;

        if (DistanceToPlane(planes[i], max.x, min.y, min.z) >= 0)
            oneInside = true;

        if (DistanceToPlane(planes[i], max.x, max.y, min.z) >= 0)
            oneInside = true;

        if (DistanceToPlane(planes[i], min.x, max.y, min.z) >= 0)
            oneInside = true;

        if (DistanceToPlane(planes[i], min.x, min.y, max.z) >= 0)
            oneInside = true;

        if (DistanceToPlane(planes[i], max.x, min.y, max.z) >= 0)
            oneInside = true;

        if (DistanceToPlane(planes[i], max.x, max.y, max.z) >= 0)
            oneInside = true;

        if (DistanceToPlane(planes[i], min.x, max.y, max.z) >= 0)
            oneInside = true;

        if (!oneInside)
            return false;
    }

    // the box extends outside the frustum but crosses it
    return true;
}

