const std = @import("std");
const ray = @import("raylib.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator(); // main game allocator
//pub const allocator = std.heap.c_allocator;

var map = std.StringHashMap(ray.Texture).init(allocator);

pub fn loadTexture(texLoc: []const u8) ray.Texture {
    // give texture if already loaded
    if (map.get(texLoc) != null)
        return map.get(texLoc).?;

    const texture: ray.Texture = ray.LoadTexture(@ptrCast(texLoc));

    //ray.GenTextureMipmaps(@ptrCast(&texture));
    //ray.SetTextureWrap(texture, ray.TEXTURE_WRAP_REPEAT);
    ray.SetTextureFilter(texture, ray.TEXTURE_FILTER_POINT);

    map.put(texLoc, texture) catch |err| print("texture hashmap failed: {}", .{err});
    return texture;
}

var keys = std.ArrayList(u16).init(util.allocator);

pub fn IsKeyPressed(key: c_int) bool {
    for(keys.items) |k|{
        if(k == key)
            return true;
    }
    return false;
}

pub fn clearKeys() void {
    keys.clearAndFree();
}

pub fn updateKeysPressed() void {
    while (true){
        const key = ray.GetKeyPressed();
        if(key == 0) break;
        keys.append(@intCast(key)) catch {};
    }

    for(0..6) |mouseKey|{
        if(ray.IsMouseButtonPressed(@intCast(mouseKey))){
            keys.append(@intCast(mouseKey)) catch {};
        }
    }
}

// TODO make better
pub fn toVec3(pos: anytype) ray.Vector3{
    if(@TypeOf(pos) == ray.Vector3)
        return pos;

    const T = @TypeOf(pos[0]);

    if(T == comptime_int or T == u32 or T == u64 or T == u8 or T == usize)
        return ray.Vector3{.x = @floatFromInt(pos[0]), .y = @floatFromInt(pos[1]), .z = @floatFromInt(pos[2])};

    return ray.Vector3{.x = @floatCast(pos[0]), .y = @floatCast(pos[1]), .z = @floatCast(pos[2])};
}

pub const Vector3Int = struct{
    x: i32, y: i32, z: i32,
};

pub fn toIntVec3(pos: anytype) Vector3Int{
    if(@TypeOf(pos) == Vector3Int)
        return pos;

    const T = @TypeOf(pos[0]);

    if(T == comptime_float or T == f32 or T == f64 or T == f16)
        return Vector3Int{.x = @intFromFloat(pos[0]), .y = @intFromFloat(pos[1]), .z = @intFromFloat(pos[2])};

    return Vector3Int{.x = @intCast(pos[0]), .y = @intCast(pos[1]), .z = @intCast(pos[2])};
}
