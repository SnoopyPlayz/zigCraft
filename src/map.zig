const std = @import("std");
const ray = @import("raylib.zig");
const model = @import("models.zig");
const shader = @import("shader.zig");
const cull = @import("frustumCulling.zig");
const player = @import("player.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

pub const chunkSize: u8 = 16;

const Chunk = struct {
    Blocks: [chunkSize][chunkSize][chunkSize]u8,
    Model: ?ray.Model = null,
    Dirty: bool = false,
    Generated: bool = false,

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

                    const bc = util.toVec3(.{x, y, z});//ray.Vector3{ .x = @floatFromInt(x), .y = @floatFromInt(y), .z = @floatFromInt(z) };
                    const bw = ray.Vector3Add(chunkPosWorld, bc);

                    const tSize = 1.0 / 16.0; //tile size
                    const xt = tSize * @as(f32, @floatFromInt(getBlock(.{bw.x, bw.y, bw.z}) - 1));
                    const texCords = [_]f32{ xt, 0.0, tSize + xt, 0.0, tSize + xt, tSize, 0.0 + xt, tSize };

                    // up face
                    if (isTransparent(getBlock(.{bw.x, bw.y + 1, bw.z}))) {
                        const vert = [_]f32{ bc.x + -0.5, bc.y + 0.5, bc.z + -0.5, bc.x + 0.5, bc.y + 0.5, bc.z + -0.5, bc.x + 0.5, bc.y + 0.5, bc.z + 0.5, bc.x + -0.5, bc.y + 0.5, bc.z + 0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 2, indsOffset + 1, indsOffset, indsOffset + 3, indsOffset + 2 };

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch {};
                        texList.appendSlice(&texCords) catch {};
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x, bw.y - 1, bw.z}))) {
                        const vert = [_]f32{ bc.x + -0.5, bc.y + -0.5, bc.z + -0.5, bc.x + 0.5, bc.y + -0.5, bc.z + -0.5, bc.x + 0.5, bc.y + -0.5, bc.z + 0.5, bc.x + -0.5, bc.y + -0.5, bc.z + 0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 1, indsOffset + 2, indsOffset, indsOffset + 2, indsOffset + 3 };

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch {};
                        texList.appendSlice(&texCords) catch {};
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x, bw.y, bw.z + 1}))) {
                        const vert = [_]f32{ bc.x + -0.5, bc.y + -0.5, bc.z + 0.5, bc.x + 0.5, bc.y + -0.5, bc.z + 0.5, bc.x + 0.5, bc.y + 0.5, bc.z + 0.5, bc.x + -0.5, bc.y + 0.5, bc.z + 0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 1, indsOffset + 2, indsOffset, indsOffset + 2, indsOffset + 3 };

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch {};
                        texList.appendSlice(&texCords) catch {};
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x, bw.y, bw.z - 1}))) {
                        const vert = [_]f32{ bc.x + -0.5, bc.y + -0.5, bc.z + -0.5, bc.x + 0.5, bc.y + -0.5, bc.z + -0.5, bc.x + 0.5, bc.y + 0.5, bc.z + -0.5, bc.x + -0.5, bc.y + 0.5, bc.z + -0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 2, indsOffset + 1, indsOffset, indsOffset + 3, indsOffset + 2 };

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch {};
                        texList.appendSlice(&texCords) catch {};
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x + 1, bw.y, bw.z}))) {
                        const vert = [_]f32{ bc.x + 0.5, bc.y + -0.5, bc.z + -0.5, bc.x + 0.5, bc.y + -0.5, bc.z + 0.5, bc.x + 0.5, bc.y + 0.5, bc.z + 0.5, bc.x + 0.5, bc.y + 0.5, bc.z + -0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 2, indsOffset + 1, indsOffset, indsOffset + 3, indsOffset + 2 };

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch {};
                        texList.appendSlice(&texCords) catch {};
                        indsOffset += 4;
                    }

                    if (isTransparent(getBlock(.{bw.x - 1, bw.y, bw.z}))) {
                        const vert = [_]f32{ bc.x + -0.5, bc.y + -0.5, bc.z + -0.5, bc.x + -0.5, bc.y + -0.5, bc.z + 0.5, bc.x + -0.5, bc.y + 0.5, bc.z + 0.5, bc.x + -0.5, bc.y + 0.5, bc.z + -0.5 };
                        const inds = [_]u16{ indsOffset, indsOffset + 1, indsOffset + 2, indsOffset, indsOffset + 2, indsOffset + 3 };

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch {};
                        texList.appendSlice(&texCords) catch {};
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

//        
//        const vao = ray.rlLoadVertexArray();
//        _ = ray.rlEnableVertexArray(vao);
//        
//        const verts:[*c] u32 = @ptrCast(try util.allocator.alloc(f32, vertList.items.len));
//        vao = ray.rlLoadVertexBuffer(verts, vertList.items.len * 32, false);
//        
//        ray.rlSetVertexAttribute(0, 1, 0x1405, false, 32, 0);
//        ray.rlEnableVertexAttribute(0);
//
//        ray.rlDisableVertexArray();
//
        //try model.UploadMesh(&mesh, false);
        ray.UploadMesh(&mesh, false);

        self.Model = ray.LoadModelFromMesh(mesh);

        model.setTexture(self.Model.?, util.loadTexture("res/sprites.png"));
        model.setShadowShader(self.Model.?);
    }
};

pub var map = std.AutoHashMap(u96, Chunk).init(util.allocator);

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

    while (mapIter.next()) |chunk| {
        if (chunk.value_ptr.Model == null) continue;
        if (!cull.isChunkVisible(ray.Vector3Scale(chunkPosFromHash(chunk.key_ptr.*), chunkSize))) continue;
        ray.DrawModel(chunk.value_ptr.Model.?, toWorldPos(chunkPosFromHash(chunk.key_ptr.*)), 1, ray.WHITE);
    }
    //print(" {} \n", .{i});
}

pub fn update() void {
    var mapIter = map.iterator();

    while (mapIter.next()) |chunk| {
        if (chunk.value_ptr.Dirty == false) continue;
        chunk.value_ptr.genMesh(chunkPosFromHash(chunk.key_ptr.*)) catch {};
        chunk.value_ptr.*.Dirty = false;
    }
}

fn isTransparent(i: u8) bool{
    if(i == 0 or i == 2 or i == 6)
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

pub fn toChunkPos(position: anytype) ray.Vector3{
    const pos = util.toIntVec3(position);
    return util.toVec3(.{@divFloor(pos.x, chunkSize), @divFloor(pos.y, chunkSize), @divFloor(pos.z, chunkSize)});
}

pub fn toWorldPos(position: anytype) ray.Vector3{
    const pos = util.toVec3(position);
    return util.toVec3(.{pos.x * chunkSize, pos.y * chunkSize, pos.z * chunkSize});
}

pub fn getChunk(position: anytype) ?*Chunk {
    const pos = util.toIntVec3(position);
    return map.getPtr(hashingFunc(pos.x, pos.y, pos.z));
}
// gen if there is no chunk
pub fn getChunkOrGen(position: anytype) *Chunk {
    const pos = util.toIntVec3(position);
    if(map.getPtr(hashingFunc(pos.x, pos.y, pos.z)) == null){
        addChunk(pos);
    }
    return map.getPtr(hashingFunc(pos.x, pos.y, pos.z)).?;
}

pub fn setBlock(position: anytype, b: u8) void {
    const pos = util.toIntVec3(position);
    const chunk = getChunkOrGen(toChunkPos(pos));

    // update Chunks around block that is updated
    if(getBlock(.{pos.x, pos.y + 1, pos.z}) != 0) getChunkOrGen(toChunkPos(.{pos.x, pos.y + 1, pos.z})).*.Dirty = true;
    if(getBlock(.{pos.x, pos.y - 1, pos.z}) != 0) getChunkOrGen(toChunkPos(.{pos.x, pos.y - 1, pos.z})).*.Dirty = true;
    if(getBlock(.{pos.x + 1, pos.y, pos.z}) != 0) getChunkOrGen(toChunkPos(.{pos.x + 1, pos.y, pos.z})).*.Dirty = true;
    if(getBlock(.{pos.x - 1, pos.y, pos.z}) != 0) getChunkOrGen(toChunkPos(.{pos.x - 1, pos.y, pos.z})).*.Dirty = true;
    if(getBlock(.{pos.x, pos.y, pos.z + 1}) != 0) getChunkOrGen(toChunkPos(.{pos.x, pos.y, pos.z + 1})).*.Dirty = true;
    if(getBlock(.{pos.x, pos.y, pos.z - 1}) != 0) getChunkOrGen(toChunkPos(.{pos.x, pos.y, pos.z - 1})).*.Dirty = true;
    //getChunkOrGen(toChunkPos(.{pos.x, pos.y + 1, pos.z})).*.Dirty = if (getBlock(.{pos.x, pos.y + 1, pos.z}) != 0) true else false;

    chunk.*.Blocks[@intCast(@mod(pos.x, chunkSize))][@intCast(@mod(pos.y, chunkSize))][@intCast(@mod(pos.z, chunkSize))] = b;
    chunk.*.Dirty = true;
}

const emptyChunk = undefined;
pub fn addChunk(position: anytype) void {
    const pos = util.toIntVec3(position);
    map.put(hashingFunc(pos.x, pos.y, pos.z), emptyChunk) catch |err| print("cannot addChunk {}", .{err});
}
