const std = @import("std");
const ray = @import("raylib.zig");
const model = @import("models.zig");
const shader = @import("shader.zig");
const gameState = @import("gameState.zig");
const util = @import("rayUtils.zig");
const print = std.debug.print;

pub fn getTimeMili() f64 { 
    //  3 more zeros for nano sec                                 can remove 2 zeros
    return @as(f64, @floatFromInt(@rem(std.time.microTimestamp(), 1000000000))) * 0.000001;
}

var times = std.StringHashMap(f64).init(util.allocator);

pub fn time(timeName: []const u8) void {
    // give time if already loaded
    if (times.get(timeName) != null){
        times.put(timeName, getTimeMili() - times.get(timeName).?) catch {};
        return;
    }

    times.put(timeName, getTimeMili()) catch |err| print("time hashmap failed: {}", .{err});
}

pub fn clear() void{
    times.clearAndFree();
}

pub fn update() void{
    var timeIter = times.iterator();
    var line:i32 = 0;

    while(timeIter.next()) |t|{
        const timeString = std.fmt.allocPrint(util.allocator, "{s}: {d:12}", .{t.key_ptr.*, t.value_ptr.* * 1000}) catch {return;};
        defer util.allocator.free(timeString);
        var string: [25] u8 = undefined;
        
        for (0..timeString.len) |e|{
            if(e >= 25) break;
            string[e] = timeString[e];
        }

        ray.DrawText(&string, 2, @intCast((line * 20) + 2), 20, ray.DARKGRAY);
        ray.DrawText(&string, 0, @intCast(line * 20), 20, ray.WHITE);
        line += 1;
    }
    times.clearAndFree();
}
