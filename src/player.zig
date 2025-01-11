const map = @import("map.zig");
const util = @import("rayUtils.zig");
const shader = @import("shader.zig");
const ray = @import("raylib.zig");
const std = @import("std");
const print = std.debug.print;

pub var camera = ray.Camera3D{
    .position = .{ .x = 1.0, .y = 10.0, .z = 1.0 },
    .target = .{ .x = 0.0, .y = 0.0, .z = 0.0 },
    .up = .{ .x = 0.0, .y = 1.0, .z = 0.0 },
    .fovy = 90.0,
    .projection = ray.CAMERA_PERSPECTIVE,
};

var col: ray.RayCollision = undefined;
var selectedBlock: u8 = 1;
pub fn update() void{
    // Shadow follow player
//    if(@abs((shader.lightCam.position.x + shader.lightCam.position.z) - (camera.position.x + camera.position.z)) > 50){
//        shader.lightCam.position.x = camera.position.x;
//        shader.lightCam.position.z = camera.position.z;
//        shader.lightCam.target.x = camera.position.x;
//        shader.lightCam.target.z = camera.position.z + 0.001;
//    }
//    camera.target = shader.lightCam.target;
//    camera.position = shader.lightCam.position;
//    camera.fovy = shader.lightCam.fovy;
//    camera.projection = shader.lightCam.projection;
    if(ray.IsKeyDown(ray.KEY_K)){
        shader.lightCam.target.z += 0.01;
    }

    if(ray.IsKeyDown(ray.KEY_L)){
        shader.lightCam.target.z -= 0.01;
    }

    for(49..57) |key|{
        if(ray.IsKeyDown(@intCast(key)))
            selectedBlock = @intCast(key - 48);
    }

    col = .{.distance = 100};

    const raycast = ray.GetScreenToWorldRay(.{.x = @floatFromInt(@divFloor(ray.GetScreenWidth(), 2)), .y = @floatFromInt(@divFloor(ray.GetScreenHeight(), 2))}, camera);

    var mapIter = map.map.iterator();

    while(mapIter.next()) |chunk|{
        if(chunk.value_ptr.Model == null)
            continue;
        
        //ray.Vector3Scale(map.chunkPosFromHash(chunk.key_ptr.*), 32);
        //chunk.value_ptr.Model.?.transform);//
        
        const meshHitInfo = ray.GetRayCollisionMesh(raycast, chunk.value_ptr.Model.?.meshes[0], ray.MatrixTranslate(0,0,0));
        //print("chunk {} \n",.{chunk.value_ptr.Model.?.transform});

        if(meshHitInfo.hit and meshHitInfo.distance < 5 and meshHitInfo.distance < col.distance){
            col = meshHitInfo;
        }

        //print("distance: {d:12} \n", .{col.distance});
    }
    //print("new :  \n", .{});

    if(col.hit){
        const pointa = ray.Vector3Add(col.point, ray.Vector3Scale(col.normal, 0.5));
        if(util.IsKeyPressed(ray.MOUSE_BUTTON_RIGHT) and map.getBlock(@intFromFloat(@round(pointa.x)), @intFromFloat(@round(pointa.y)), @intFromFloat(@round(pointa.z))) == 0){
            map.setBlock(@intFromFloat(@round(pointa.x)), @intFromFloat(@round(pointa.y)), @intFromFloat(@round(pointa.z)), selectedBlock);
        }

        const point = ray.Vector3Subtract(col.point, ray.Vector3Scale(col.normal, 0.5));
        if(util.IsKeyPressed(ray.MOUSE_BUTTON_LEFT) and map.getBlock(@intFromFloat(@round(point.x)), @intFromFloat(@round(point.y)), @intFromFloat(@round(point.z))) != 0){
            map.setBlock(@intFromFloat(@round(point.x)), @intFromFloat(@round(point.y)), @intFromFloat(@round(point.z)), 0);
        }
    }

    //print("camera target: {} \n",.{ray.Vector3Subtract(camera.target,camera.position)});
    //const t = ray.Vector3Subtract(camera.position, camera.target);
    //print("camera posget: x:{d:12} y:{d:12} z:{d:12} \n",.{t.x , t.y , t.z });
}

pub fn render() void{
    //print("col: {} \n", .{col.normal});
    const point = ray.Vector3Subtract(col.point, ray.Vector3Scale(col.normal, 0.5));
    //const pointa = ray.Vector3Add(col.point, ray.Vector3Scale(col.normal, 0.5));
    if(col.hit){
        ray.DrawCube(.{.x = @round(point.x), .y = @round(point.y), .z = @round(point.z)}, 1.01, 1.01, 1.01, ray.ColorAlpha(ray.BLACK, 0.5));
    }
    //ray.DrawCube(.{.x = @round(pointa.x), .y = @round(pointa.y), .z = @round(pointa.z)}, 1.0, 1.0, 1.0, ray.ColorAlpha(ray.BLUE, 0.5));
    //ray.DrawCubeWires(.{.x = @round(point.x), .y = @round(point.y), .z = @round(point.z)}, 1.0, 1.0, 1.0, ray.BLACK);
    //print("{} {} {} \n", .{col.point.x, col.point.y, col.point.z});
}
