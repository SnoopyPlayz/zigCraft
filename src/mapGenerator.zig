const std = @import("std");
const ray = @import("raylib.zig");
const map = @import("map.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

pub fn gen(position: anytype) void {
    if(map.getChunk(position) != null){
        if(map.getChunk(position).?.Generated == true){
            print("already Generated {} \n", .{position});
            return;
        }else{
            map.getChunk(position).?.Generated = true;
        }
    }

    const pos = util.toIntVec3(map.toWorldPos(util.toVec3(position)));

    const size = map.chunkSize;
    const image = ray.GenImagePerlinNoise(size, size, pos.x, pos.z, 0.1);
    const image2 = ray.GenImagePerlinNoise(size, size, pos.x, pos.z, 2);

    const colors = ray.LoadImageColors(image);
    const colors2 = ray.LoadImageColors(image2);

    for (0..@intCast(image.height)) |z|{
        for (0..@intCast(image.width)) |x|{
            const index  = z * @as(usize, @intCast(image.width)) + x;
            const pixel = colors[index];
            const pixel2 = colors2[index];

            var height: i32 = 0;
            height += pixel2.r;
            height += pixel2.g;
            height += pixel2.b;
            height = @divFloor(height, 10);

            height += pixel.b;
            height += pixel.r;
            height += pixel.g;
            height = @divFloor(height, 40);
            height += 20;
            //ray.DrawCube(.{.x = @floatFromInt(x), .y = @floatFromInt(height), .z = @floatFromInt(y)}, 1, 1, 1, ray.ColorAlpha(ray.BLUE, 1));
            const setBlockPos = util.toIntVec3(.{x, height, z});

            for(0..@intCast(height)) |h|{
                map.setBlock(.{setBlockPos.x + pos.x, height - @as(i32, @intCast(h)), setBlockPos.z + pos.z}, 4);
            }
            map.setBlock(.{setBlockPos.x + pos.x, height, setBlockPos.z + pos.z}, 1);

            if(ray.GetRandomValue(0, 100) == 1){
                createTree(.{setBlockPos.x + pos.x, height, setBlockPos.z + pos.z});
            }
        }
    }

    map.getChunk(position).?.Generated = true;
}

pub fn init() void {
    for(0..5)|i|{
        for(0..5)|y|{
            gen(.{i, 0, y});
        }
    }
}

pub fn createTree(position: anytype) void {
    const pos = util.toVec3(position);
     
    map.setBlock(pos, 1);

    for(0..3)|i|{
        const x: f32 = @floatFromInt(i);
        for(0..3)|t|{
            const y: f32 = @floatFromInt(t);
            for(0..3)|q|{
                const z: f32 = @floatFromInt(q);
                map.setBlock(.{pos.x + x - 1, pos.y + 4 + y, pos.z + z - 1}, 6);
            }
        }
    }

    for(0..5)|i|{
        const h: f32 = @floatFromInt(i);
        map.setBlock(.{pos.x, pos.y + h, pos.z}, 5);
    }

}
