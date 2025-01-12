const std = @import("std");
const ray = @import("raylib.zig");
const p = @import("player.zig");
const shader = @import("shader.zig");
const util = @import("rayUtils.zig");
const gameState = @import("gameState.zig");
const profiler = @import("profiler.zig");
const getTimeMili = @import("profiler.zig").getTimeMili;
const print = std.debug.print;

fn testr(pos: anytype) ray.Vector3{
    if(@TypeOf(pos) == ray.Vector3)
        return pos;

    if(@TypeOf(pos[0]) == comptime_int or @TypeOf(pos[0]) == u32 or @TypeOf(pos[0]) == u64 or @TypeOf(pos[0]) == u8)
        return ray.Vector3{.x = @floatFromInt(pos[0]), .y = @floatFromInt(pos[1]), .z = @floatFromInt(pos[2])};

    return ray.Vector3{.x = @floatCast(pos[0]), .y = @floatCast(pos[1]), .z = @floatCast(pos[2])};
}

pub fn main() !void {
    _ = testr(ray.Vector3{.x = 0, .y = 2, .z = 1});
    _ = testr(.{2,3,4});
    _ = testr(.{2.1,3.4,4.5});


    // release enable
    //ray.SetTraceLogLevel(ray.LOG_NONE);
    //ray.SetConfigFlags(ray.FLAG_MSAA_4X_HINT); //| ray.FLAG_WINDOW_RESIZABLE); //| ray.FLAG_WINDOW_HIGHDPI);

    //ray.InitWindow(1000, 1000, "kebab 2137 ?????");
    ray.InitWindow(1280, 720, "zigCraft");
    defer ray.CloseWindow();

    //ray.SetTargetFPS(120); // remove this

    ray.SetExitKey(0);
    ray.DisableCursor();

    shader.init();
    shader.setShadowColor(ray.WHITE);

    try gameState.init();

    const timePerFrame: f64 = 1.0 / 60.0;
    var lastTime: f64 = getTimeMili();

    while (!ray.WindowShouldClose()) {
        // update
        while (@abs(getTimeMili() - lastTime) >= timePerFrame) {
            if (getTimeMili() - lastTime < -0.1)
                lastTime = getTimeMili();

            try gameState.update();
            util.clearKeys();
            lastTime += timePerFrame;
        }

        ray.BeginDrawing();

        util.updateKeysPressed();


        ray.UpdateCamera(&p.camera, ray.CAMERA_FREE);
        if(ray.IsKeyDown(ray.KEY_LEFT_SHIFT)){
            ray.UpdateCamera(&p.camera, ray.CAMERA_FREE);
        }
        //ray.UpdateCameraPro(&camera, .{ .x = 0.0, .y = 0.0, .z = 0.0 }, .{ .x = @floatCast(ray.GetMouseDelta().x * 0.05), .y = @floatCast(ray.GetMouseDelta().y * 0.05), .z = 0.0 }, // rotation 0.0); // zoom
        shader.drawShadow();
        ray.ClearBackground(ray.GRAY);

        profiler.clear();

        //ray.rlDisableDepthTest();
        //ray.rlDisableDepthMask();

        ray.BeginMode3D(p.camera);
        try gameState.render();
        ray.EndMode3D();

        profiler.update();

        //ray.DrawRectangle(10, 10, 320, 93, ray.Fade(ray.SKYBLUE, 0.5));
        //ray.DrawRectangleLines(10, 10, 320, 93, ray.BLUE);
        //ray.DrawText("kebab 2137 ?????", 20, 20, 10, ray.BLACK);
        ray.DrawFPS(100, 100);
        ray.DrawCircleLines(@divFloor(ray.GetScreenWidth(), 2), @divFloor(ray.GetScreenHeight(), 2), 4, ray.RED);
        //ray.DrawText("WASD", 40, 40, 10, ray.DARKGRAY);
        ray.EndDrawing();
    }
}
