const std = @import("std");
const ray = @import("raylib.zig");
const map = @import("map.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

var image:ray.Image = undefined;
var colors: [*c] ray.Color = undefined;

pub fn render() void {
}

pub fn init() void {
    image = ray.GenImagePerlinNoise(100,100,10,10,4);
    colors = ray.LoadImageColors(image);

    for (0..@intCast(image.height)) |y|{
        for (0..@intCast(image.width)) |x|{
            const index  = y * @as(usize, @intCast(image.width)) + x;
            const pixel = colors[index];
            var height: i32 = pixel.b;
            height += pixel.r;
            height += pixel.g;
            height = @divFloor(height, 100);
            height += 20;
            //ray.DrawCube(.{.x = @floatFromInt(x), .y = @floatFromInt(height), .z = @floatFromInt(y)}, 1, 1, 1, ray.ColorAlpha(ray.BLUE, 1));
            map.setBlock(@intCast(x), height, @intCast(y), 1);

            for(0..@intCast(height)) |h|{
                map.setBlock(@intCast(x), height - @as(i32, @intCast(h)), @intCast(y), 1);
            }
        }
    }
}
