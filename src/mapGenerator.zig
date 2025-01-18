const std = @import("std");
const ray = @import("raylib.zig");
const map = @import("map.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

var image:ray.Image = undefined;
var colors: [*c] ray.Color = undefined;
var texture: ray.Texture = undefined;

pub fn render() void {
    ray.DrawTexture(texture, 0, 0, ray.WHITE);
}

pub fn init() void {
    const size = 150;
    image = ray.GenImagePerlinNoise(size, size,0,0,4);
    texture = ray.LoadTextureFromImage(image);
    const image2 = ray.GenImagePerlinNoise(size, size,0,0,1);
    colors = ray.LoadImageColors(image);
    const colors2 = ray.LoadImageColors(image2);

    for (0..@intCast(image.height)) |y|{
        for (0..@intCast(image.width)) |x|{
            const index  = y * @as(usize, @intCast(image.width)) + x;
            const pixel = colors[index];
            const pixel2 = colors2[index];

            var height: i32 = pixel.b;
            height += pixel.r;
            height += pixel.g;
            height = @divFloor(height, 50);
            height += pixel2.r;
            height += pixel2.g;
            height += pixel2.b;
            height = @divFloor(height, 30);
            height += 20;
            //ray.DrawCube(.{.x = @floatFromInt(x), .y = @floatFromInt(height), .z = @floatFromInt(y)}, 1, 1, 1, ray.ColorAlpha(ray.BLUE, 1));
            //map.setBlock(.{x, height, y}, 1);

            for(0..@intCast(height)) |h|{
                map.setBlock(.{x, height - @as(i32, @intCast(h)), y}, 1);
            }
        }
    }
}
