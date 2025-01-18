const std = @import("std");
const ray = @import("raylib.zig");
const model = @import("models.zig");
const shader = @import("shader.zig");
const player = @import("player.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

pub const chunkSize: u8 = 16;

const Chunk = struct {
    Blocks: [chunkSize][chunkSize][chunkSize]u8,
    Model: ?ray.Model = null,
    Dirty: bool = false,

    fn genMesh(self: *Chunk, pos: ray.Vector3) !void {
        const chunkPosWorld = ray.Vector3Scale(pos, chunkSize);

        var vertList = std.ArrayList(f32).init(util.allocator);
        var indsList = std.ArrayList(u16).init(util.allocator);
        var texList = std.ArrayList(f32).init(util.allocator);
        defer vertList.deinit();
        defer indsList.deinit();
        defer texList.deinit();
        var indsOffset: u16 = 0;

        for (0..chunkSize) |x| {
            for (0..chunkSize) |y| {
                for (0..chunkSize) |z| {
                    if (self.Blocks[x][y][z] == 0)
                        continue;

                    const blockPosChunk = util.toVec3(.{x, y, z});//ray.Vector3{ .x = @floatFromInt(x), .y = @floatFromInt(y), .z = @floatFromInt(z) };
                    const bw = ray.Vector3Add(chunkPosWorld, blockPosChunk);

                    const tSize = 1.0 / 16.0; //tile size
                    const xt = tSize * @as(f32, @floatFromInt(getBlock(.{bw.x, bw.y, bw.z}) - 1));
                    const texCords = [_]f32{ xt, 0.0, tSize + xt, 0.0, tSize + xt, tSize, 0.0 + xt, tSize };

                    // up face
                    if (isTransparent(getBlock(.{bw.x, bw.y + 1, bw.z}))) {
                        const vert = [_]f32{ bw.x + -0.5, bw.y + 0.5, bw.z + -0.5, bw.x + 0.5, bw.y + 0.5, bw.z + -0.5, bw.x + 0.5, bw.y + 0.5, bw.z + 0.5, bw.x + -0.5, bw.y + 0.5, bw.z + 0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 2, indsOffset + 1, indsOffset, indsOffset + 3, indsOffset + 2 };

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch {};
                        texList.appendSlice(&texCords) catch {};
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x, bw.y - 1, bw.z}))) {
                        const vert = [_]f32{ bw.x + -0.5, bw.y + -0.5, bw.z + -0.5, bw.x + 0.5, bw.y + -0.5, bw.z + -0.5, bw.x + 0.5, bw.y + -0.5, bw.z + 0.5, bw.x + -0.5, bw.y + -0.5, bw.z + 0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 1, indsOffset + 2, indsOffset, indsOffset + 2, indsOffset + 3 };

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x, bw.y, bw.z + 1}))) {
                        const vert = [_]f32{ bw.x + -0.5, bw.y + -0.5, bw.z + 0.5, bw.x + 0.5, bw.y + -0.5, bw.z + 0.5, bw.x + 0.5, bw.y + 0.5, bw.z + 0.5, bw.x + -0.5, bw.y + 0.5, bw.z + 0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 1, indsOffset + 2, indsOffset, indsOffset + 2, indsOffset + 3 };

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x, bw.y, bw.z - 1}))) {
                        const vert = [_]f32{ bw.x + -0.5, bw.y + -0.5, bw.z + -0.5, bw.x + 0.5, bw.y + -0.5, bw.z + -0.5, bw.x + 0.5, bw.y + 0.5, bw.z + -0.5, bw.x + -0.5, bw.y + 0.5, bw.z + -0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 2, indsOffset + 1, indsOffset, indsOffset + 3, indsOffset + 2 };

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x + 1, bw.y, bw.z}))) {
                        const vert = [_]f32{ bw.x + 0.5, bw.y + -0.5, bw.z + -0.5, bw.x + 0.5, bw.y + -0.5, bw.z + 0.5, bw.x + 0.5, bw.y + 0.5, bw.z + 0.5, bw.x + 0.5, bw.y + 0.5, bw.z + -0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 2, indsOffset + 1, indsOffset, indsOffset + 3, indsOffset + 2 };

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x - 1, bw.y, bw.z}))) {
                        const vert = [_]f32{ bw.x + -0.5, bw.y + -0.5, bw.z + -0.5, bw.x + -0.5, bw.y + -0.5, bw.z + 0.5, bw.x + -0.5, bw.y + 0.5, bw.z + 0.5, bw.x + -0.5, bw.y + 0.5, bw.z + -0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 1, indsOffset + 2, indsOffset, indsOffset + 2, indsOffset + 3 };

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }
                }
            }
        }

        if (vertList.items.len == 0){ //emptyChunk
            if(self.Model != null){
                model.unloadMesh(self.Model.?.meshes[0]);
                self.Model = null;
            }
            return;
        }

        if (self.Model != null) {
            model.unloadMesh(self.Model.?.meshes[0]);
        }

        var mesh = ray.Mesh{ 
            .triangleCount = @intCast(vertList.items.len / 6), 
            .vertexCount = @intCast(vertList.items.len / 3), 

            .vertices = @ptrCast(try util.allocator.alloc(f32, vertList.items.len)), 
            .indices = @ptrCast(try util.allocator.alloc(u16, indsList.items.len)), 
            .texcoords = @ptrCast(try util.allocator.alloc(f32, texList.items.len)), 
            .texcoords2 = null, .normals = null, .tangents = null, .colors = null, .animVertices = null, .animNormals = null, .boneIds = null, .boneWeights = null, .vaoId = 0, .vboId = null };

        // remove extra capacity
        for (0..indsList.items.len) |e| mesh.indices[e] = indsList.items[@intCast(e)];
        for (0..vertList.items.len) |e| mesh.vertices[e] = vertList.items[@intCast(e)];
        for (0..texList.items.len) |e| mesh.texcoords[e] = texList.items[@intCast(e)];

        ray.UploadMesh(&mesh, false);

        self.Model = ray.LoadModelFromMesh(mesh);

        model.setTexture(self.Model.?, util.loadTexture("res/sprites.png"));
        model.setShadowShader(self.Model.?);
    }
};

pub var map = std.AutoHashMap(u96, Chunk).init(util.allocator);

//pub fn isChunkVisible(position: anytype) bool{
//    const pos = ray.Vector3Scale(util.toVec3(position), chunkSize);
//    
//    const screenWidth: f32 = @floatFromInt(ray.GetScreenWidth());
//    const screenHeight: f32 = @floatFromInt(ray.GetScreenHeight());
//    
//    const cs = chunkSize;
//
//    const chunkCorners = [_]ray.Vector3{
//        pos,
//        .{.x = pos.x + cs, .y = pos.y,      .z = pos.z},
//        .{.x = pos.x + cs, .y = pos.y + cs, .z = pos.z},
//        .{.x = pos.x,      .y = pos.y + cs, .z = pos.z},
//        .{.x = pos.x,      .y = pos.y,      .z = pos.z + cs},
//        .{.x = pos.x + cs, .y = pos.y,      .z = pos.z + cs},
//        .{.x = pos.x,      .y = pos.y + cs, .z = pos.z + cs},
//        .{.x = pos.x + cs, .y = pos.y + cs, .z = pos.z + cs},
//    };
//
//    for(chunkCorners) |corner| {
//        const screenPos = ray.GetWorldToScreen(corner, player.camera);
//
////        if(draw1){
////            ray.DrawCircle(@intFromFloat(screenPos.x), @intFromFloat(screenPos.y), 10, ray.BLUE);
////            print("screenPosx: {d:12} \n", .{screenPos.x});
////            print("screenPosy: {d:12} \n", .{screenPos.y});
////        }
//
//        if (screenPos.x > 0 and screenPos.x < screenWidth and
//            screenPos.y > 0 and screenPos.y < screenHeight) {
//            return true;
//        }
//    }
//
//    return false;
//}

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
    const max = ray.Vector3Add(min, .{.x = chunkSize, .y = chunkSize, .z = chunkSize});

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

pub fn draw() void {
    var mapIter = map.iterator();
    for (0..5) |x|{
        for (0..5) |y|{
            for (0..5) |z|{
                var pos = util.toVec3(.{x, y, z});
                pos = ray.Vector3Scale(pos, chunkSize);
                pos = ray.Vector3AddValue(pos, (chunkSize / 2));
                pos = ray.Vector3AddValue(pos, -0.5);
                ray.DrawCubeWires(pos, chunkSize, chunkSize, chunkSize, ray.WHITE);
            }
        }
    }

    var i: u32 = 0;
    while (mapIter.next()) |chunk| {
        if (chunk.value_ptr.Model == null) continue;
        if (!isChunkVisible(ray.Vector3Scale(chunkPosFromHash(chunk.key_ptr.*), chunkSize))) continue;
        i+=1;
        ray.DrawModel(chunk.value_ptr.Model.?, ray.Vector3Zero(), 1, ray.WHITE);
    }
    print(" {} \n", .{i});
}

pub fn update() void {
    var mapIter = map.iterator();

    while (mapIter.next()) |chunk| {
        if (chunk.value_ptr.Dirty == false) continue;
        chunk.value_ptr.genMesh(chunkPosFromHash(chunk.key_ptr.*)) catch {};
        //print("fail setBlock chunk at: x:{} \n", .{ @divFloor(z, chunkSize) });
        chunk.value_ptr.*.Dirty = false;
    }
}


fn isTransparent(i: u8) bool{
    if(i == 0 or i == 2)
        return true;
    return false;
}

// x i32 + y i32 + z i32 = u96 for hashing 
fn hashingFunc(x: i32, y: i32, z: i32) u96 {
    var result: u96 = @as(u32, @bitCast(x));
    result <<= 32;

    result += @as(u32, @bitCast(y));
    result <<= 32;

    result += @as(u32, @bitCast(z));

    return result;
}

pub fn chunkPosFromHash(key: u96) ray.Vector3 {
    var result: ray.Vector3 = undefined;
    result.x = @floatFromInt(@as(i32, @bitCast(@as(u32, @truncate((key >> 64))))));
    result.y = @floatFromInt(@as(i32, @bitCast(@as(u32, @truncate(key >> 32)))));
    result.z = @floatFromInt(@as(i32, @bitCast(@as(u32, @truncate(key)))));

    return result;
}

pub fn getBlock(position: anytype) u8 {
    const pos = util.toIntVec3(position);

    const chunk = map.get(hashingFunc(@divFloor(pos.x, chunkSize), @divFloor(pos.y, chunkSize), @divFloor(pos.z, chunkSize)));

    if (chunk == null) {
        //print("failed to get chunk at x:{} y:{} z:{} \n", .{ @divFloor(x, chunkSize), @divFloor(y, chunkSize), @divFloor(z, chunkSize) });
        return 0; // return air
    }

    return chunk.?.Blocks[@intCast(@mod(pos.x, chunkSize))][@intCast(@mod(pos.y, chunkSize))][@intCast(@mod(pos.z, chunkSize))];
}

pub fn getChunk(position: anytype) ?*Chunk{
    const pos = util.toIntVec3(position);
    return map.getPtr(hashingFunc(@divFloor(pos.x, chunkSize), @divFloor(pos.y, chunkSize), @divFloor(pos.z, chunkSize)));
}

pub fn setBlock(position: anytype, b: u8) void {
    const pos = util.toIntVec3(position);
    var chunk = getChunk(pos);

    if (chunk == null) {
        addChunk(@divFloor(pos.x, chunkSize), @divFloor(pos.y, chunkSize), @divFloor(pos.z, chunkSize));
        chunk = getChunk(pos);
    }

//    print("printx {} \n",.{@mod(pos.x, chunkSize)});
//    print("printz {} \n",.{@mod(pos.z, chunkSize)});
//    if(getBlock(.{pos.x, pos.y, pos.z}) == 31){
//        print("border ", .{});
//    }

    chunk.?.*.Blocks[@intCast(@mod(pos.x, chunkSize))][@intCast(@mod(pos.y, chunkSize))][@intCast(@mod(pos.z, chunkSize))] = b;
    chunk.?.*.Dirty = true;
}

const emptyChunk = undefined;

fn addChunk(x: i32, y: i32, z: i32) void {
    const c = emptyChunk;

    map.put(hashingFunc(x, y, z), c) catch |err| print("addChunk Error {}", .{err});
}

pub fn init() !void {
}
