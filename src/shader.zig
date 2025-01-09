const std = @import("std");
const ray = @import("raylib.zig");
const p = @import("player.zig");
const gameState = @import("gameState.zig");
const print = std.debug.print;


pub var shadowShader: ray.Shader = undefined;

pub fn setShadowColor(color: ray.Color) void{
    // light color
    const lightColorNormalized = ray.ColorNormalize(color);
    const lightColLoc = ray.GetShaderLocation(shadowShader, "lightColor");
    ray.SetShaderValue(shadowShader, lightColLoc, &lightColorNormalized, ray.SHADER_ATTRIB_VEC4);
}

var shadowMap: ray.RenderTexture2D = undefined;
var lightVPLoc: c_int = undefined;
var shadowMapLoc: c_int = undefined;
pub var lightCam: ray.Camera3D = undefined;

pub fn init() void {
    shadowShader = ray.LoadShader("res/shaders/vertShadowMap.glsl", "res/shaders/fragShadowMap.glsl");
    shadowShader.locs[ray.SHADER_LOC_VECTOR_VIEW] = ray.GetShaderLocation(shadowShader, "viewPos");

    lightVPLoc = ray.GetShaderLocation(shadowShader, "lightVP");
    shadowMapLoc = ray.GetShaderLocation(shadowShader, "shadowMap");
    const shadowMapResolution: c_int = 4096;
    ray.SetShaderValue(shadowShader, ray.GetShaderLocation(shadowShader, "shadowMapResolution"), &shadowMapResolution, ray.SHADER_UNIFORM_INT);

    shadowMap = LoadShadowmapRenderTexture(shadowMapResolution, shadowMapResolution);
    lightCam = undefined;
    lightCam.position = ray.Vector3{ .x = 0, .y = 50, .z = 0 }; //ray.Vector3Scale(lightDir, -15.0);
    lightCam.target = lightCam.position;
    lightCam.target.z += 0.001;
    lightCam.target.y -= 15;
    lightCam.projection = ray.CAMERA_ORTHOGRAPHIC;
    lightCam.up = ray.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0 };
    lightCam.fovy = 170.0;

    //camera.position = lightCam.position;
    p.camera.position = ray.Vector3One();
    //camera.position = ray.Vector3Zero();
    p.camera.target = lightCam.target;
    //camera.fovy = 170;
    //camera.projection = ray.CAMERA_ORTHOGRAPHIC;
    //
    // light direction
    var lightDir = ray.Vector3Normalize(ray.Vector3{ .x = lightCam.target.x - lightCam.position.x, .y = -1.0, .z = lightCam.target.z - lightCam.position.z });
    const lightDirLoc = ray.GetShaderLocation(shadowShader, "lightDir");
    ray.SetShaderValue(shadowShader, lightDirLoc, &lightDir, ray.SHADER_ATTRIB_VEC3);

}

pub fn drawShadow() void{
        ray.SetShaderValue(shadowShader, shadowShader.locs[ray.SHADER_LOC_VECTOR_VIEW], &p.camera.position, ray.SHADER_UNIFORM_VEC3);

        ray.BeginTextureMode(shadowMap);
        ray.ClearBackground(ray.RAYWHITE);
        ray.rlSetCullFace(ray.RL_CULL_FACE_FRONT);

        ray.BeginMode3D(lightCam);
        const lightView = ray.rlGetMatrixModelview();
        const lightProj = ray.rlGetMatrixProjection();
        try gameState.render();
        ray.EndMode3D();
        ray.EndTextureMode();
        ray.rlSetCullFace(ray.RL_CULL_FACE_BACK);

        const lightViewProj = ray.MatrixMultiply(lightView, lightProj);

        ray.ClearBackground(ray.GRAY);
        ray.SetShaderValueMatrix(shadowShader, lightVPLoc, lightViewProj);

        ray.rlEnableShader(shadowShader.id);
        const slot: c_int = 10;
        ray.rlActiveTextureSlot(slot);
        ray.rlEnableTexture(shadowMap.depth.id);

        ray.rlSetUniform(shadowMapLoc, &slot, ray.SHADER_UNIFORM_INT, 1);
}

fn LoadShadowmapRenderTexture(width: u32, height: u32) ray.RenderTexture2D {
    var target: ray.RenderTexture2D = undefined;

    target.id = ray.rlLoadFramebuffer();
    target.texture.width = @intCast(width);
    target.texture.height = @intCast(height);

    if (target.id > 0) {
        ray.rlEnableFramebuffer(target.id);

        target.depth.id = ray.rlLoadTextureDepth(@intCast(width), @intCast(height), false);
        target.depth.width = @intCast(width);
        target.depth.height = @intCast(height);
        target.depth.format = 19; //DEPTH_COMPONENT_24BIT?
        target.depth.mipmaps = 1;

        // Attach depth texture to FBO
        ray.rlFramebufferAttach(target.id, target.depth.id, ray.RL_ATTACHMENT_DEPTH, ray.RL_ATTACHMENT_TEXTURE2D, 0);

        // Check if fbo is complete with attachments (valid)
        if (!ray.rlFramebufferComplete(target.id)) {
            print("SHADOWMAP FAIL \n", .{});
        }

        ray.rlDisableFramebuffer();
    } else print("SHADOWMAP FAIL \n", .{});

    return target;
}
