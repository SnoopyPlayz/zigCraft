const std = @import("std");
const ray = @import("raylib.zig");
const model = @import("models.zig");
const shader = @import("shader.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

const chunkSize: u8 = 32;

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
            model.unloadMesh(self.Model.?.meshes[0]);
            self.Model = null;
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

pub fn draw() void {
    var mapIter = map.iterator();
//    for (0..5) |x|{
//        for (0..5) |y|{
//            for (0..5) |z|{
//                var pos = util.toVec3(.{x, y, z});
//                pos = ray.Vector3Scale(pos, chunkSize);
//                pos = ray.Vector3AddValue(pos, 15.5);
//                ray.DrawCubeWires(pos, chunkSize, chunkSize, chunkSize, ray.WHITE);
//            }
//        }
//    }

    while (mapIter.next()) |chunk| {
        if (chunk.value_ptr.Model == null) continue;
        ray.DrawModel(chunk.value_ptr.Model.?, ray.Vector3Zero(), 1, ray.WHITE);
    }
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

pub fn setBlock(position: anytype, b: u8) void {
    const pos = util.toIntVec3(position);
    var chunk = map.getPtr(hashingFunc(@divFloor(pos.x, chunkSize), @divFloor(pos.y, chunkSize), @divFloor(pos.z, chunkSize)));

    if (chunk == null) {
        addChunk(@divFloor(pos.x, chunkSize), @divFloor(pos.y, chunkSize), @divFloor(pos.z, chunkSize));
        chunk = map.getPtr(hashingFunc(@divFloor(pos.x, chunkSize), @divFloor(pos.y, chunkSize), @divFloor(pos.z, chunkSize)));
    }

    if(@mod(pos.x, chunkSize) - chunkSize == 0){
        print("border ", .{});
    }

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
