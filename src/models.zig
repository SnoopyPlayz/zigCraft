const std = @import("std");
const ray = @import("raylib.zig");
const rayRL = @import("raylib");
const util = @import("rayUtils.zig");
const shader = @import("shader.zig");
const print = std.debug.print;

pub fn setTexture(model: ray.Model, tex: ray.Texture) void {
    model.materials[0].maps[ray.MATERIAL_MAP_DIFFUSE].texture = tex;
}

pub fn setShadowShader(model: ray.Model) void {
    model.materials[0].shader = shader.shadowShader;
}

pub fn unloadMesh(mesh: ray.Mesh) void {
    //const mesh = self.Model.?.meshes.*;
    const vc: f64 = @floatFromInt(mesh.vertexCount);

    util.allocator.free(mesh.indices[0..@intFromFloat(vc * 1.5)]);
    //util.allocator.free(mesh.texcoords[0..@intFromFloat(vc * 2)]);
    //util.allocator.free(mesh.texcoords[0..@intFromFloat(vc * 2)]);

    ray.rlUnloadVertexArray(mesh.vaoId);

    for (0..7) |i| {
        ray.rlUnloadVertexBuffer(mesh.vboId[i]);
    }
}

pub fn UploadMesh(mesh: *ray.Mesh, verts: [*]u32) !void {
    if (mesh.vaoId > 0) {
        // Check if mesh has already been loaded in GPU
        print("VAO: [ID {}] Trying to re-load an already loaded mesh \n", .{mesh.vaoId});
        return;
    }

    mesh.vboId = (try util.allocator.alloc(u32, 9)).ptr;

    mesh.vaoId = ray.rlLoadVertexArray();
    _ = ray.rlEnableVertexArray(mesh.vaoId);

    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION] = ray.rlLoadVertexBuffer(verts, mesh.vertexCount * 1 * @sizeOf(u32), false);
    rayRL.gl.rlSetVertexAttributeI(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION, 1, 0x1405, 0, 0);
    ray.rlEnableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION);

    ray.rlDisableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL);
    ray.rlDisableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR);
    ray.rlDisableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT);
    ray.rlDisableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2);

    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_INDICES] = ray.rlLoadVertexBufferElement(mesh.indices, mesh.triangleCount * 3 * @sizeOf(u16), false);

    if (mesh.vaoId > 0) {
        print("INFO: VAO: [ID {}] Mesh uploaded successfully to VRAM (GPU) \n", .{mesh.vaoId});
    } else print("Mesh not loaded successfully ID: {} \n", .{mesh.vaoId});

    ray.rlDisableVertexArray();
}
