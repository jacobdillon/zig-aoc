const std = @import("std");

pub fn day1_part1(input: []const u8) !u32 {
    var result: u32 = 0;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var first_num: ?u8 = null;
        var last_num: ?u8 = null;

        for (line) |char| {
            if (std.ascii.isDigit(char)) {
                if (first_num == null) {
                    first_num = char - '0';
                }
                last_num = char - '0';
            }
        }

        result += ((first_num orelse 0) * 10) + (last_num orelse 0);
    }

    return result;
}

fn getSliceEnglishNumValue(slice: []const u8) ?u8 {
    const strnum_map_tuples = .{
        .{ "one", 1 },
        .{ "two", 2 },
        .{ "three", 3 },
        .{ "four", 4 },
        .{ "five", 5 },
        .{ "six", 6 },
        .{ "seven", 7 },
        .{ "eight", 8 },
        .{ "nine", 9 }};
    const lens_to_check = [_]u8 {3, 4, 5};
    const strnum_map = std.ComptimeStringMap(u8, strnum_map_tuples);
    for (lens_to_check) |len| {
        if (slice.len >= len and strnum_map.has(slice[0..len])) {
            return strnum_map.get(slice[0..len]);
        }
    }
    return null;
}

pub fn day1_part2(input: []const u8) !u32 {
    var result: u32 = 0;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var first_num: ?u8 = null;
        var last_num: ?u8 = null;

        for (line, 0..) |char, index| {
            if (std.ascii.isDigit(char)) {
                if (first_num == null) {
                    first_num = char - '0';
                }
                last_num = char - '0';
            } else {
                const num_value = getSliceEnglishNumValue(line[index..]);
                if (num_value != null) {
                    if (first_num == null) {
                        first_num = num_value;
                    }
                    last_num = num_value;
                }
            }
        }

        result += ((first_num orelse 0) * 10) + (last_num orelse 0);
    }

    return result;
}

pub fn day2_part1(input: []const u8) !u32 {
    var result: u32 = 0;
    var game_id: u32 = 1;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| : (game_id += 1)  {
        var line_failed = false;

        var sets = std.mem.tokenizeAny(u8, line[std.mem.indexOf(u8, line, ":").? + 1..], ";");
        while (sets.next()) |set| {
            var set_cubes = std.mem.tokenizeAny(u8, set, ",");
            while (set_cubes.next()) |cubes| {
                var values = std.mem.tokenizeAny(u8, cubes, " ");
                const num = try std.fmt.parseInt(u32, values.next().?, 10);
                const color = values.next().?[0];

                if ((color == 'r' and num > 12) or
                    (color == 'g' and num > 13) or
                    (color == 'b' and num > 14)) {
                    line_failed = true;
                }
            }
        }

        if (!line_failed) {
            result += game_id;
        }
    }

    return result;
}

pub fn day2_part2(input: []const u8) !u32 {
    var result: u32 = 0;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var red_max: u32 = 1;
        var green_max: u32 = 1;
        var blue_max: u32 = 1;

        var sets = std.mem.tokenizeAny(u8, line[std.mem.indexOf(u8, line, ":").? + 1..], ";");
        while (sets.next()) |set| {
            var set_cubes = std.mem.tokenizeAny(u8, set, ",");
            while (set_cubes.next()) |cubes| {
                var values = std.mem.tokenizeAny(u8, cubes, " ");
                const num = try std.fmt.parseInt(u32, values.next().?, 10);
                const color = values.next().?[0];

                switch (color) {
                    'r' => red_max = @max(red_max, num),
                    'g' => green_max = @max(green_max, num),
                    'b' => blue_max = @max(blue_max, num),
                    else => {},
                }
            }
        }

        result += red_max * green_max * blue_max;
    }

    return result;
}

pub fn day3_part1(input: []const u8) !u32 {
    const Point = struct {
        x: i32,
        y: i32,
    };

    const NumberPoint = struct {
        val: u32,
        y: i32,
        start_x: i32,
        end_x: i32,
    };

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var num_list = std.ArrayList(NumberPoint).init(allocator);
    var parts_list = std.ArrayList(Point).init(allocator);

    var result: u32 = 0;

    var y: i32 = 0;
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| : (y += 1) {
        var processing_number = false;
        var num_point = NumberPoint{.y = y, .val = 0, .start_x = undefined, .end_x = undefined};

        for (line, 0..) |char, x| {
            if (std.ascii.isDigit(char)) {
                if (!processing_number) {
                    processing_number = true;
                    num_point.start_x = @intCast(x);
                }
                num_point.end_x = @intCast(x);

                if (x == line.len - 1) {
                    num_point.val = try std.fmt.parseInt(u32, line[@intCast(num_point.start_x)..@as(usize, @intCast(num_point.end_x)) + 1], 10);
                    try num_list.append(num_point);
                }
            } else if (processing_number) {
                processing_number = false;
                num_point.val = try std.fmt.parseInt(u32, line[@intCast(num_point.start_x)..@as(usize, @intCast(num_point.end_x)) + 1], 10);
                try num_list.append(num_point);
            }

            if (char != '.' and
                ((char >= '!' and char <= '/') or
                 (char >= ':' and char <= '@') or
                 (char >= '[' and char <= '`') or
                 (char >= '{' and char <= '~'))) {
                try parts_list.append(.{.x = @intCast(x), .y = y});
            }
        }
    }

    for (num_list.items) |num_point| {
        for (parts_list.items) |part_point| {
            if (part_point.y >= num_point.y - 1 and part_point.y <= num_point.y + 1 and
                part_point.x >= num_point.start_x - 1 and part_point.x <= num_point.end_x + 1) {
                result += num_point.val;
                break;
            }
        }
    }

    return result;
}

pub fn day3_part2(input: []const u8) !u32 {
    const Point = struct {
        x: i32,
        y: i32,
    };

    const NumberPoint = struct {
        val: u32,
        y: i32,
        start_x: i32,
        end_x: i32,
    };

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var num_list = std.ArrayList(NumberPoint).init(allocator);
    var gear_list = std.ArrayList(Point).init(allocator);

    var result: u32 = 0;

    var y: i32 = 0;
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| : (y += 1) {
        var processing_number = false;
        var num_point = NumberPoint{.y = y, .val = 0, .start_x = undefined, .end_x = undefined};

        for (line, 0..) |char, x| {
            if (std.ascii.isDigit(char)) {
                if (!processing_number) {
                    processing_number = true;
                    num_point.start_x = @intCast(x);
                }
                num_point.end_x = @intCast(x);

                if (x == line.len - 1) {
                    num_point.val = try std.fmt.parseInt(u32, line[@intCast(num_point.start_x)..@as(usize, @intCast(num_point.end_x)) + 1], 10);
                    try num_list.append(num_point);
                }
            } else if (processing_number) {
                processing_number = false;
                num_point.val = try std.fmt.parseInt(u32, line[@intCast(num_point.start_x)..@as(usize, @intCast(num_point.end_x)) + 1], 10);
                try num_list.append(num_point);
            }

            if (char == '*') {
                try gear_list.append(.{.x = @intCast(x), .y = y});
            }
        }
    }

    for (gear_list.items) |gear_point| {
        var num_connected: u32 = 0;
        var gear_ratio: u32 = 1;

        for (num_list.items) |num_point| {
            if (gear_point.y >= num_point.y - 1 and gear_point.y <= num_point.y + 1 and
                gear_point.x >= num_point.start_x - 1 and gear_point.x <= num_point.end_x + 1) {
                num_connected += 1;
                gear_ratio *= num_point.val;
            }
        }

        if (num_connected == 2) {
            result += gear_ratio;
        }
    }

    return result;
}
