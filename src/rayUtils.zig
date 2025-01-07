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

    var texture: ray.Texture = ray.LoadTexture(@ptrCast(texLoc));

    ray.GenTextureMipmaps(@ptrCast(&texture));
    //ray.SetTextureWrap(texture, ray.TEXTURE_WRAP_REPEAT);
    ray.SetTextureFilter(texture, ray.TEXTURE_FILTER_ANISOTROPIC_16X);

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
