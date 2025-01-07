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

    fn genMesh(self: *Chunk, pos: ray.Vector3) !void{
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
                    if(self.Blocks[x][y][z] == 0)
                        continue;

                    const blockPosChunk = ray.Vector3{.x = @floatFromInt(x), .y = @floatFromInt(y), .z = @floatFromInt(z)};
                    const blockWorld = ray.Vector3Add(chunkPosWorld, blockPosChunk);

                    // up
                    if(getBlock(@intFromFloat(blockWorld.x), @intFromFloat(blockWorld.y + 1), @intFromFloat(blockWorld.z)) == 0){
                        const vert = [_]f32{  
                            blockWorld.x + -0.5,blockWorld.y + 0.5, blockWorld.z + -0.5,
                            blockWorld.x + 0.5,  blockWorld.y + 0.5, blockWorld.z + -0.5,
                            blockWorld.x + 0.5,  blockWorld.y + 0.5, blockWorld.z + 0.5,
                            blockWorld.x + -0.5, blockWorld.y + 0.5, blockWorld.z + 0.5};

                        const inds = [_]u16{ 
                            indsOffset, indsOffset + 2, indsOffset + 1,
                            indsOffset, indsOffset + 3, indsOffset + 2};

                        const texCords = [_]f32{ 0, 0, 1, 0, 1, 1, 0, 1};

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if(getBlock(@intFromFloat(blockWorld.x), @intFromFloat(blockWorld.y - 1), @intFromFloat(blockWorld.z)) == 0){
                        const vert = [_]f32{  
                            blockWorld.x + -0.5,blockWorld.y + -0.5, blockWorld.z + -0.5,
                            blockWorld.x + 0.5,  blockWorld.y + -0.5, blockWorld.z + -0.5,
                            blockWorld.x + 0.5,  blockWorld.y + -0.5, blockWorld.z + 0.5,
                            blockWorld.x + -0.5, blockWorld.y + -0.5, blockWorld.z + 0.5};

                        const inds = [_]u16{ 
                            indsOffset, indsOffset + 1, indsOffset + 2,
                            indsOffset, indsOffset + 2, indsOffset + 3};

                        const texCords = [_]f32{ 0, 0, 1, 0, 1, 1, 0, 1};

                        vertList.appendSlice(&vert) catch {};
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if(getBlock(@intFromFloat(blockWorld.x), @intFromFloat(blockWorld.y), @intFromFloat(blockWorld.z + 1)) == 0){
                        const vert = [_]f32{  
                            blockWorld.x + -0.5,blockWorld.y + -0.5, blockWorld.z + 0.5,
                            blockWorld.x + 0.5,  blockWorld.y + -0.5, blockWorld.z + 0.5,
                            blockWorld.x + 0.5,  blockWorld.y + 0.5, blockWorld.z + 0.5,
                            blockWorld.x + -0.5, blockWorld.y + 0.5, blockWorld.z + 0.5};

                        const inds = [_]u16{ 
                            indsOffset, indsOffset + 1, indsOffset + 2,
                            indsOffset, indsOffset + 2, indsOffset + 3};

                        const texCords = [_]f32{ 0, 0, 1, 0, 1, 1, 0, 1};

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if(getBlock(@intFromFloat(blockWorld.x), @intFromFloat(blockWorld.y), @intFromFloat(blockWorld.z - 1)) == 0){
                        const vert = [_]f32{  
                            blockWorld.x + -0.5,blockWorld.y + -0.5, blockWorld.z + -0.5,
                            blockWorld.x + 0.5,  blockWorld.y + -0.5, blockWorld.z + -0.5,
                            blockWorld.x + 0.5,  blockWorld.y + 0.5, blockWorld.z + -0.5,
                            blockWorld.x + -0.5, blockWorld.y + 0.5, blockWorld.z + -0.5};

                        const inds = [_]u16{ 
                            indsOffset, indsOffset + 2, indsOffset + 1,
                            indsOffset, indsOffset + 3, indsOffset + 2};

                        const texCords = [_]f32{ 0, 0, 1, 0, 1, 1, 0, 1};

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if(getBlock(@intFromFloat(blockWorld.x + 1), @intFromFloat(blockWorld.y), @intFromFloat(blockWorld.z)) == 0){
                        const vert = [_]f32{  
                            blockWorld.x + 0.5,blockWorld.y + -0.5, blockWorld.z + -0.5,
                            blockWorld.x + 0.5,  blockWorld.y + -0.5, blockWorld.z + 0.5,
                            blockWorld.x + 0.5,  blockWorld.y + 0.5, blockWorld.z + 0.5,
                            blockWorld.x + 0.5, blockWorld.y + 0.5, blockWorld.z + -0.5};

                        const inds = [_]u16{ 
                            indsOffset, indsOffset + 2, indsOffset + 1,
                            indsOffset, indsOffset + 3, indsOffset + 2};

                        const texCords = [_]f32{ 0, 0, 1, 0, 1, 1, 0, 1};

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }

                    if(getBlock(@intFromFloat(blockWorld.x - 1), @intFromFloat(blockWorld.y), @intFromFloat(blockWorld.z)) == 0){
                        const vert = [_]f32{  
                            blockWorld.x + -0.5,blockWorld.y + -0.5, blockWorld.z + -0.5,
                            blockWorld.x + -0.5,  blockWorld.y + -0.5, blockWorld.z + 0.5,
                            blockWorld.x + -0.5,  blockWorld.y + 0.5, blockWorld.z + 0.5,
                            blockWorld.x + -0.5, blockWorld.y + 0.5, blockWorld.z + -0.5};

                        const inds = [_]u16{ 
                            indsOffset, indsOffset + 1, indsOffset + 2,
                            indsOffset, indsOffset + 2, indsOffset + 3};

                        const texCords = [_]f32{ 0, 0, 1, 0, 1, 1, 0, 1};

                        vertList.appendSlice(&vert) catch |err| print("error {} \n", .{err});
                        indsList.appendSlice(&inds) catch |err| print("error {} \n", .{err});
                        texList.appendSlice(&texCords) catch |err| print("error {} \n", .{err});
                        indsOffset += 4;
                    }
                }}}
       
        if(vertList.items.len == 0) //emptyChunk
            return;

        if(self.Model != null){
            const mesh = self.Model.?.meshes.*;
            const vc: f64 = @floatFromInt(mesh.vertexCount);

            util.allocator.free(mesh.vertices[0..@intFromFloat(vc * 3)]);
            util.allocator.free(mesh.indices[0..@intFromFloat(vc * 1.5)]);
            util.allocator.free(mesh.texcoords[0..@intFromFloat(vc * 2)]);

            ray.rlUnloadVertexArray(mesh.vaoId);

            for (0..7) |i| {
                ray.rlUnloadVertexBuffer(mesh.vboId[i]);
            }
        }

        var mesh = ray.Mesh{
            .triangleCount = @intCast(vertList.items.len / 6),
            .vertexCount = @intCast(vertList.items.len / 3),

            .vertices = @ptrCast(try util.allocator.alloc(f32, vertList.items.len)),
            .indices = @ptrCast(try util.allocator.alloc(u16, indsList.items.len)),
            .texcoords = @ptrCast(try util.allocator.alloc(f32, texList.items.len)),

            .texcoords2 = null, .normals = null, .tangents = null, .colors = null, .animVertices = null, 
            .animNormals = null, .boneIds = null, .boneWeights = null, .vaoId = 0,.vboId = null
        };

        // remove extra capacity
        for(0..indsList.items.len) |e| mesh.indices[e] = indsList.items[@intCast(e)];
        for(0..vertList.items.len) |e| mesh.vertices[e] = vertList.items[@intCast(e)];
        for(0..texList.items.len) |e| mesh.texcoords[e] = texList.items[@intCast(e)];

        ray.UploadMesh(&mesh, false);

        self.Model = ray.LoadModelFromMesh(mesh);

        model.setTexture(self.Model.?, util.loadTexture("res/grass.png"));
        model.setShadowShader(self.Model.?);
    }
};

pub var map = std.AutoHashMap(u96, Chunk).init(util.allocator);

pub fn draw() void {
    var mapIter = map.iterator();

    while(mapIter.next()) |chunk|{
        if(chunk.value_ptr.Model == null) continue;
        ray.DrawModel(chunk.value_ptr.Model.?, ray.Vector3Zero(), 1, ray.WHITE);
    }
}

// x: 101 + y: 010 + z: 001 = hash: 101010001
fn hashingFunc(x: i32, y: i32, z: i32) u96{
    var result: u96 = @as(u32, @bitCast(x));
    result <<= 32;

    result += @as(u32, @bitCast(y));
    result <<= 32;

    result += @as(u32, @bitCast(z));

    return result;
}

pub fn getBlock(x: i32, y: i32, z: i32) u8 {
    const chunk = map.get(hashingFunc(@divFloor(x, chunkSize), @divFloor(y, chunkSize), @divFloor(z, chunkSize)));

    if(chunk == null){
        print("failed to get chunk at x:{} y:{} z:{} \n", .{@divFloor(x, chunkSize), @divFloor(y, chunkSize), @divFloor(z, chunkSize)});
        return 0; // return air
    }

    return chunk.?.Blocks[@intCast(@mod(x, chunkSize))][@intCast(@mod(y, chunkSize))][@intCast(@mod(z, chunkSize))];
}

pub fn setBlock(x: i32, y: i32, z: i32, b: u8) void {
    const chunk = map.getPtr(hashingFunc(@divFloor(x, chunkSize), @divFloor(y, chunkSize), @divFloor(z, chunkSize)));

    if(chunk == null){
        print("fail setBlock chunk at: x:{} y:{} z:{} \n", .{@divFloor(x, chunkSize), @divFloor(y, chunkSize), @divFloor(z, chunkSize)});
        return;
    }

    chunk.?.*.Blocks[@intCast(@mod(x, chunkSize))][@intCast(@mod(y, chunkSize))][@intCast(@mod(z, chunkSize))] = b;
    chunk.?.genMesh(.{.x = @floatFromInt(@divFloor(x, chunkSize)),.y = @floatFromInt(@divFloor(y, chunkSize)),.z = @floatFromInt(@divFloor(z, chunkSize))}) catch {};
}

pub fn chunkPosFromHash(key: u96) ray.Vector3 {
    var result: ray.Vector3 = undefined;
    result.x = @floatFromInt(key >> 64);
    result.y = @floatFromInt(@as(u32, @truncate(key >> 32)));
    result.z = @floatFromInt(@as(u32, @truncate(key)));

    return result;
}

const emptyChunk = undefined;

fn addChunk(x: i32, y: i32, z: i32) void{
    const c = emptyChunk;

    map.put(hashingFunc(x,y,z), c) catch |err| print("addChunk Error {}", .{err});
}

pub fn init() !void {
    addChunk(0,0,0);

    for (0..chunkSize) |i| {
        for (0..chunkSize) |y| {
            map.getPtr(hashingFunc(0,0,0)).?.Blocks[i][0][y] = 1;
        }
    }

    map.getPtr(hashingFunc(0,0,0)).?.Blocks[0][1][0] = 1;

    addChunk(0,0,1);
    addChunk(0,0,-1);
    addChunk(-1,0,0);
    addChunk(-1,0,1);
    addChunk(0,-1,0);
    addChunk(0,-1,1);
    addChunk(0,1,1); // emptyChunk
    addChunk(1,0,1); // emptyChunk
    addChunk(1,0,0); // emptyChunk
    addChunk(0,0,2); // emptyChunk

    for (0..chunkSize) |x| {
        for (0..chunkSize) |y| {
            //for (0..chunkSize) |z| {
                map.getPtr(hashingFunc(0,0,1)).?.Blocks[x][y][0] = 1;
            //}
        }
    }

    var mapIter = map.iterator();

        while(mapIter.next()) |chunk|{
            try chunk.value_ptr.genMesh(chunkPosFromHash(chunk.key_ptr.*));
            if (chunk.value_ptr.Model == null)
                continue;

            chunk.value_ptr.Model.?.materials[0].maps[ray.MATERIAL_MAP_DIFFUSE].texture = util.loadTexture("res/grass.png");
            chunk.value_ptr.Model.?.materials[0].shader = shader.shadowShader;
        }
}
