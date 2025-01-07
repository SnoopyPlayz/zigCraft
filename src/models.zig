const std = @import("std");
const ray = @import("raylib.zig");
const util = @import("rayUtils.zig");
const shader = @import("shader.zig");
const print = std.debug.print;

pub fn setTexture(model: ray.Model, tex: ray.Texture) void{
    model.materials[0].maps[ray.MATERIAL_MAP_DIFFUSE].texture = tex;
}

pub fn setShadowShader(model: ray.Model) void{
    model.materials[0].shader = shader.shadowShader;
}
