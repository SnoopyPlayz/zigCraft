const std = @import("std");
const ray = @import("raylib.zig");
const map = @import("map.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

var image:ray.Image = undefined;
var colors: [*c] ray.Color = undefined;

pub fn gen(position: anytype) void {
    if(map.getChunk(position) != null){
        if(map.getChunk(position).?.Generated == true){
            print("already Generated {} \n", .{position});
            return;
        }else{
            map.getChunk(position).?.Generated = true;
        }
    }

    const pos = util.toIntVec3(ray.Vector3Scale(util.toVec3(position), map.chunkSize));

    const size = map.chunkSize;
    image = ray.GenImagePerlinNoise(size, size, pos.x, pos.z, 0.1);
    const image2 = ray.GenImagePerlinNoise(size, size, pos.x, pos.z, 2);
    colors = ray.LoadImageColors(image);
    const colors2 = ray.LoadImageColors(image2);

    for (0..@intCast(image.height)) |y|{
        for (0..@intCast(image.width)) |x|{
            const index  = y * @as(usize, @intCast(image.width)) + x;
            const pixel = colors[index];
            const pixel2 = colors2[index];

            var height: i32 = 0;
            height += pixel2.r;
            height += pixel2.g;
            height += pixel2.b;
            height = @divFloor(height, 10);

            height += pixel.b;
            height += pixel.r;
            height += pixel.g;
            height = @divFloor(height, 40);
            height += 20;
            //ray.DrawCube(.{.x = @floatFromInt(x), .y = @floatFromInt(height), .z = @floatFromInt(y)}, 1, 1, 1, ray.ColorAlpha(ray.BLUE, 1));
            //map.setBlock(.{x, height, y}, 1);

            for(0..@intCast(height)) |h|{
                map.setBlock(.{@as(i32, @intCast(x)) + pos.x, height - @as(i32, @intCast(h)), @as(i32, @intCast(y)) + pos.z}, 1);
            }
        }
    }
    map.getChunk(position).?.Generated = true;
}

pub fn init() void {
    for(0..5)|i|{
        for(0..5)|y|{
            gen(.{i, 0, y});
        }
    }
}
