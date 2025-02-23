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

    const vboid = try util.allocator.alloc(u32, 9);
    mesh.vboId = vboid.ptr;

    mesh.vaoId = 0; // Vertex Array Object
    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION] = 0; // Vertex buffer: positions
    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD] = 0; // Vertex buffer: texcoords
    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL] = 0; // Vertex buffer: normals
    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR] = 0; // Vertex buffer: colors
    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT] = 0; // Vertex buffer: tangents
    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2] = 0; // Vertex buffer: texcoords2
    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_INDICES] = 0; // Vertex buffer: indices

    mesh.vaoId = ray.rlLoadVertexArray();
    _ = ray.rlEnableVertexArray(mesh.vaoId);

    // NOTE: Vertex attributes must be uploaded considering default locations points and available vertex data

    // Enable vertex attributes: position (shader-location = 0)
    //const vertices = mesh.vertices;
    //rayRL.gl.rlSetVertexAttributeI();
    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION] = ray.rlLoadVertexBuffer(verts, mesh.vertexCount * 1 * @sizeOf(u32), false);
    rayRL.gl.rlSetVertexAttributeI(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION, 1, 0x1405, 0, 0);
    ray.rlEnableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_POSITION);

    // Enable vertex attributes: texcoords (shader-location = 1)
    //    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD] = ray.rlLoadVertexBuffer(tex, mesh.vertexCount*2*@sizeOf(f32), false);
    //    ray.rlSetVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD, 2, ray.RL_FLOAT, false, 0, 0);
    //    ray.rlEnableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD);

    // WARNING: When setting default vertex attribute values, the values for each generic vertex attribute
    // is part of current state, and it is maintained even if a different program object is used

    // Default vertex attribute: normal
    // WARNING: Default value provided to shader if location available
    {
        const value = [_]f32{ 1.0, 1.0, 1.0 };
        ray.rlSetVertexAttributeDefault(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL, &value, ray.SHADER_ATTRIB_VEC3, 3);
        ray.rlDisableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_NORMAL);
    }

    // Default vertex attribute: color
    // WARNING: Default value provided to shader if location available
    {
        const value = [_]f32{ 1.0, 1.0, 1.0, 1.0 }; // WHITE
        ray.rlSetVertexAttributeDefault(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR, &value, ray.SHADER_ATTRIB_VEC4, 4);
        ray.rlDisableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_COLOR);
    }

    // Default vertex attribute: tangent
    // WARNING: Default value provided to shader if location available
    {
        const value = [_]f32{ 0.0, 0.0, 0.0, 0.0 };
        ray.rlSetVertexAttributeDefault(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT, &value, ray.SHADER_ATTRIB_VEC4, 4);
        ray.rlDisableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TANGENT);
    }

    // Default vertex attribute: texcoord2
    // WARNING: Default value provided to shader if location available
    {
        const value = [_]f32{ 0.0, 0.0 };
        ray.rlSetVertexAttributeDefault(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2, &value, ray.SHADER_ATTRIB_VEC2, 2);
        ray.rlDisableVertexAttribute(ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_TEXCOORD2);
    }

    mesh.vboId[ray.RL_DEFAULT_SHADER_ATTRIB_LOCATION_INDICES] = ray.rlLoadVertexBufferElement(mesh.indices, mesh.triangleCount * 3 * @sizeOf(u16), false);

    if (mesh.vaoId > 0) {
        print("INFO: VAO: [ID {}] Mesh uploaded successfully to VRAM (GPU) \n", .{mesh.vaoId});
    } else print("VBO: Mesh uploaded successfully to VRAM (GPU) \n", .{});

    ray.rlDisableVertexArray();
}
