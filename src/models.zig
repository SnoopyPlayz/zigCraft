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

pub fn unloadMesh(mesh: ray.Mesh) void{
    //const mesh = self.Model.?.meshes.*;
    const vc: f64 = @floatFromInt(mesh.vertexCount);

    util.allocator.free(mesh.vertices[0..@intFromFloat(vc * 3)]);
    util.allocator.free(mesh.indices[0..@intFromFloat(vc * 1.5)]);
    util.allocator.free(mesh.texcoords[0..@intFromFloat(vc * 2)]);

    ray.rlUnloadVertexArray(mesh.vaoId);

    for (0..7) |i| {
        ray.rlUnloadVertexBuffer(mesh.vboId[i]);
    }
}
