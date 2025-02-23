const map = @import("map.zig");
const util = @import("rayUtils.zig");
const shader = @import("shader.zig");
const mapGen = @import("mapGenerator.zig");
const ray = @import("raylib.zig");
const std = @import("std");
const print = std.debug.print;

pub var camera = ray.Camera3D{
    .position = .{ .x = 1.0, .y = 40.0, .z = 1.0 },
    .target = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
    .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
    .fovy = 90.0,
    .projection = ray.CAMERA_PERSPECTIVE,
};

var selectedBlock: u8 = 1;
pub fn update() void {
    // Shadow follow player
    if (@abs((shader.lightCam.position.x + shader.lightCam.position.z) - (camera.position.x + camera.position.z)) > 50) {
        shader.lightCam.position.x = camera.position.x;
        shader.lightCam.position.z = camera.position.z;
        shader.lightCam.target.x = camera.position.x;
        shader.lightCam.target.z = camera.position.z + 0.001;
    }
    //    camera.target = shader.lightCam.target;
    //    camera.position = shader.lightCam.position;
    //    camera.fovy = shader.lightCam.fovy;
    //    camera.projection = shader.lightCam.projection;
    //
    //print("{} \n",.{map.toChunkPos(.{camera.position.x, 0, camera.position.z})});

    if (map.getChunk(map.toChunkPos(.{ camera.position.x, 0, camera.position.z })) == null) {
        mapGen.gen(map.toChunkPos(.{ camera.position.x, 0, camera.position.z }));
    } else if (map.getChunk(map.toChunkPos(.{ camera.position.x, 0, camera.position.z })).?.Generated == false) {
        mapGen.gen(map.toChunkPos(.{ camera.position.x, 0, camera.position.z }));
    }

    const posChunkPos = util.toIntVec3(map.toChunkPos(.{ camera.position.x, 0, camera.position.z }));

    const rednderDistance = 5;
    for (0..@intCast(posChunkPos.x - posChunkPos.x + rednderDistance)) |i| {
        for (0..@intCast(posChunkPos.z - posChunkPos.z + rednderDistance)) |y| {
            mapGen.gen(.{ posChunkPos.x + @as(i32, @intCast(i)) - rednderDistance / 2, 0, posChunkPos.z + @as(i32, @intCast(y)) - rednderDistance / 2 });
        }
        //mapGen.gen(.{ posChunkPos.x + @as(i32, @intCast(i)), 0, posChunkPos.z });
    }

    if (ray.IsKeyDown(ray.KEY_K)) {
        shader.lightCam.target.z += 0.01;
    }

    if (util.IsKeyPressed(ray.KEY_X)) {
        mapGen.createTree(camera.position);
    }

    if (ray.IsKeyDown(ray.KEY_L)) {
        shader.lightCam.target.z -= 0.01;
    }

    for (49..57) |key| {
        if (ray.IsKeyDown(@intCast(key)))
            selectedBlock = @intCast(key - 48);
    }

    const rayCast = sendRay();
    if (rayCast == null) {
        return;
    }

    if (util.IsKeyPressed(ray.MOUSE_BUTTON_RIGHT))
        map.setBlock(rayCast.?, selectedBlock);

    if (util.IsKeyPressed(ray.MOUSE_BUTTON_LEFT))
        map.setBlock(rayCast.?, 0);

    //print("camera target: {} \n",.{ray.Vector3Subtract(camera.target,camera.position)});
    //const t = ray.Vector3Subtract(camera.position, camera.target);
    //print("camera posget: x:{d:12} y:{d:12} z:{d:12} \n",.{t.x , t.y , t.z });
}

fn sendRay() ?ray.Vector3 {
    const amount = 50;
    const stepAmount = 0.1;

    for (0..amount) |i| {
        const distance = @as(f32, @floatFromInt(i)) * stepAmount;

        var rayBlockPos = ray.Vector3MoveTowards(camera.position, camera.target, distance);
        rayBlockPos = .{ .x = @round(rayBlockPos.x), .y = @round(rayBlockPos.y), .z = @round(rayBlockPos.z) };

        const block = map.getBlock(rayBlockPos);

        if (block != 0) {
            //ray.DrawSphere(rayBlockPos, 0.1, ray.RED);
            //ray.DrawSphere(.{ .x = @round(rayBlockPos.x), .y = @round(rayBlockPos.y), .z = @round(rayBlockPos.z) }, 0.7, ray.GREEN);
            return rayBlockPos;
        }
    }

    return null;
}

pub fn render() void {
    if (sendRay() != null) {
        ray.DrawCube(sendRay().?, 1.01, 1.01, 1.01, ray.ColorAlpha(ray.BLACK, 0.5));
    }
}
