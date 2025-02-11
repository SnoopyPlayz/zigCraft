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

var col: ray.RayCollision = undefined;
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

    col = .{ .distance = 100 };

    const raycast = ray.GetScreenToWorldRay(.{ .x = @floatFromInt(@divFloor(ray.GetScreenWidth(), 2)), .y = @floatFromInt(@divFloor(ray.GetScreenHeight(), 2)) }, camera);

    var mapIter = map.map.iterator();

    while (mapIter.next()) |chunk| {
        if (chunk.value_ptr.Model == null)
            continue;

        // optimization. only chunks close
        const chunkPos = map.toWorldPos(map.chunkPosFromHash(chunk.key_ptr.*));

        const distance = ray.Vector3Distance(ray.Vector3Add(chunkPos, .{ .x = map.chunkSize / 2, .y = map.chunkSize / 2, .z = map.chunkSize / 2 }), camera.position);

        if (distance > 20) {
            continue;
        }

        const meshHitInfo = ray.GetRayCollisionMesh(raycast, chunk.value_ptr.Model.?.meshes[0], ray.MatrixTranslate(chunkPos.x, chunkPos.y, chunkPos.z));

        if (meshHitInfo.hit and meshHitInfo.distance < 5 and meshHitInfo.distance < col.distance) {
            col = meshHitInfo;
        }
    }
    const rayCast = sendRay();
    if(rayCast == null){
        return;
    }
    const point = ray.Vector3AddValue(sendRay().?, -0.5);

    if (util.IsKeyPressed(ray.MOUSE_BUTTON_RIGHT))
        map.setBlock(.{ @round(point.x), @round(point.y), @round(point.z) }, selectedBlock);
    
    if (util.IsKeyPressed(ray.MOUSE_BUTTON_LEFT))
        map.setBlock(point, 0);
    

    //print("camera target: {} \n",.{ray.Vector3Subtract(camera.target,camera.position)});
    //const t = ray.Vector3Subtract(camera.position, camera.target);
    //print("camera posget: x:{d:12} y:{d:12} z:{d:12} \n",.{t.x , t.y , t.z });
}

fn sendRay() ?ray.Vector3 {
    const amount = 50;
    const stepAmount = 0.1;

    for (0..amount) |i| {
        const distance = @as(f32, @floatFromInt(i)) * stepAmount;

        const rayBlockPos = ray.Vector3MoveTowards(camera.position, camera.target, distance);
 
        //rayBlockPos = ray.Vector3AddValue(rayBlockPos, 0.5);

        const block = map.getBlock(rayBlockPos);

        if (block != 0) {
            ray.DrawSphere(rayBlockPos, 0.1,ray.RED);
            //ray.DrawSphere(.{ .x = @round(rayBlockPos.x), .y = @round(rayBlockPos.y), .z = @round(rayBlockPos.z)}, 0.8, ray.GREEN );
            ray.DrawSphere(util.toVec3(util.toIntVec3(rayBlockPos)), 0.9,ray.BLUE);
            //ray.DrawSphere(rayBlockPos, 0.9,ray.GREEN);
            return rayBlockPos;
        }
    }

    return null;
}

pub fn render() void {
    //print("col: {} \n", .{col.normal});
    const point = ray.Vector3Subtract(col.point, ray.Vector3Scale(col.normal, 0.5));
    //const pointa = ray.Vector3Add(col.point, ray.Vector3Scale(col.normal, 0.5));
    if (col.hit) {
        ray.DrawCube(.{ .x = @round(point.x), .y = @round(point.y), .z = @round(point.z) }, 1.01, 1.01, 1.01, ray.ColorAlpha(ray.BLACK, 0.5));
    }

    //ray.DrawSphere(ray.Vector3Normalize(ray.Vector3Subtract(camera.target, camera.position)), 1, ray.RED);
    //ray.DrawSphere(ray.Vector3Add(ray.Vector3Scale(ray.Vector3Normalize(ray.Vector3Subtract(camera.target, camera.position)), 50), camera.target), 1, ray.RED);
    _ = sendRay();
    //ray.DrawSphere(camera.target, 1, ray.RED);

    //ray.DrawCube(.{.x = @round(pointa.x), .y = @round(pointa.y), .z = @round(pointa.z)}, 1.0, 1.0, 1.0, ray.ColorAlpha(ray.BLUE, 0.5));
    //ray.DrawCubeWires(.{.x = @round(point.x), .y = @round(point.y), .z = @round(point.z)}, 1.0, 1.0, 1.0, ray.BLACK);
    //print("{} {} {} \n", .{col.point.x, col.point.y, col.point.z});
}
