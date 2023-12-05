const std = @import("std");
const print = @import("std").debug.print;
const utils = @import("utils.zig");

pub fn day1_part1(input: []const u8) !u32 {
    var result: u32 = 0;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var found_first = false;
        var found_last = false;

        for (0..line.len) |pos| {
            if (!found_first and std.ascii.isDigit(line[pos])) {
                result += (line[pos] - '0') * 10;
                found_first = true;
            }

            if (!found_last and std.ascii.isDigit(line[line.len - pos - 1])) {
                result += line[line.len - pos - 1] - '0';
                found_last = true;
            }

            if (found_first and found_last) {
                break;
            }
        }
    }

    return result;
}

pub fn day1_part2(input: []const u8) !u32 {
    var result: u32 = 0;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var found_first = false;
        var found_last = false;

        for (0..line.len) |pos| {
            if (!found_first) {
                if (std.ascii.isDigit(line[pos])) {
                    result += (line[pos] - '0') * 10;
                    found_first = true;
                } else if (utils.englishStringToNumber(line[pos..])) |value| {
                    result += value * 10;
                    found_first = true;
                }
            }

            if (!found_last) {
                const idx = line.len - pos - 1;
                if (std.ascii.isDigit(line[idx])) {
                    result += line[idx] - '0';
                    found_last = true;
                } else if (utils.englishStringToNumber(line[idx..])) |value| {
                    result += value;
                    found_last = true;
                }
            }

            if (found_first and found_last) {
                break;
            }
        }
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

pub fn day4_part1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var result: u32 = 0;

    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| {
        var winners_set = std.AutoHashMap(u8, void).init(allocator);
        var card_result: u32 = 0;

        var num_sets = std.mem.tokenizeAny(u8, line[std.mem.indexOf(u8, line, ":").? + 1..], "|");
        var winners_it = std.mem.tokenizeAny(u8, num_sets.next().?, " ");
        var my_nums_it = std.mem.tokenizeAny(u8, num_sets.next().?, " ");

        while (winners_it.next()) |winner_str| {
            try winners_set.put(try std.fmt.parseInt(u8, winner_str, 10), {});
        }

        while (my_nums_it.next()) |my_nums_str| {
            const num = try std.fmt.parseInt(u8, my_nums_str, 10);
            if (winners_set.contains(num)) {
                if (card_result == 0) {
                    card_result = 1;
                } else {
                    card_result *= 2;
                }
            }
        }
        result += card_result;
    }

    return result;
}

pub fn day4_part2(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var result: u32 = 0;

    var won_cards = std.AutoHashMap(u8, u32).init(allocator);

    var card_num: u8 = 1;
    var lines = std.mem.tokenizeAny(u8, input, "\n");
    while (lines.next()) |line| : (card_num += 1){
        var winners_set = std.AutoHashMap(u8, void).init(allocator);
        var matching_numbers: u32 = 0;

        var num_sets = std.mem.tokenizeAny(u8, line[std.mem.indexOf(u8, line, ":").? + 1..], "|");
        var winners_it = std.mem.tokenizeAny(u8, num_sets.next().?, " ");
        var my_nums_it = std.mem.tokenizeAny(u8, num_sets.next().?, " ");

        while (winners_it.next()) |winner_str| {
            try winners_set.put(try std.fmt.parseInt(u8, winner_str, 10), {});
        }

        while (my_nums_it.next()) |my_nums_str| {
            const num = try std.fmt.parseInt(u8, my_nums_str, 10);
            if (winners_set.contains(num)) {
                matching_numbers += 1;
            }
        }

        const num_current_cards = won_cards.get(card_num) orelse 1;
        const cards_won = num_current_cards * matching_numbers;

        result += cards_won;

        if (matching_numbers != 0) {
            for (card_num + 1..card_num + 1 + matching_numbers) |current_card| {
                try won_cards.put(@intCast(current_card), (won_cards.get(@intCast(current_card)) orelse 1) + num_current_cards);
            }
        }
    }

    return result + card_num - 1;
}

pub fn day5_part1(input: []const u8) !u32 {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var result: u32 = 0;

    var seed_set = std.AutoHashMap(u8, void).init(allocator);
    var seed_to_soil = std.AutoHashMap(u32, u32).init(allocator);
    _ = seed_to_soil;
    var soil_to_fertilizer = std.AutoHashMap(u32, u32).init(allocator);
    _ = soil_to_fertilizer;
    var fertilizer_to_water = std.AutoHashMap(u32, u32).init(allocator);
    _ = fertilizer_to_water;
    var water_to_light = std.AutoHashMap(u32, u32).init(allocator);
    _ = water_to_light;
    var light_to_temperature = std.AutoHashMap(u32, u32).init(allocator);
    _ = light_to_temperature;
    var temperature_to_humidity = std.AutoHashMap(u32, u32).init(allocator);
    _ = temperature_to_humidity;
    var humidity_to_location = std.AutoHashMap(u32, u32).init(allocator);
    _ = humidity_to_location;

    var seed_strs_it = std.mem.tokenizeAny(u8, input[0..std.mem.indexOf(u8, input, "\n").?], " ");
    while (seed_strs_it.next()) |seed_str| {
        try seed_set.put(try std.fmt.parseInt(u8, seed_str, 10), 0);
    }

    var maps_it = std.mem.tokenizeAny(u8, input[std.mem.indexOf(u8, input, "\n")..], "map:");
    maps_it.next();


    return result;
}
