const std = @import("std");
const ray = @import("raylib.zig");
const player = @import("player.zig");
const profiler = @import("profiler.zig");
const mapGen = @import("mapGenerator.zig");
const util = @import("rayUtils.zig");
const map = @import("map.zig");
const print = std.debug.print;

pub fn update() !void {
    player.update();
    map.update();

    if(util.IsKeyPressed(ray.KEY_F11))
        ray.ToggleFullscreen();
}

pub fn init() !void {
    try map.init();
    mapGen.init();
}

pub fn render() !void {
    profiler.time("time");
    map.draw();
    player.render();
    profiler.time("time");
}

pub fn render2D() !void {
    mapGen.render();
}
