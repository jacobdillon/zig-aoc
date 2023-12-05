const std = @import("std");

pub fn englishStringToNumber(input: []const u8) ?u32 {
    const strnum_tuples = .{
        .{ "one", 1 },
        .{ "two", 2 },
        .{ "three", 3 },
        .{ "four", 4 },
        .{ "five", 5 },
        .{ "six", 6 },
        .{ "seven", 7 },
        .{ "eight", 8 },
        .{ "nine", 9 }};
    inline for (strnum_tuples) |strnum| {
        if (std.mem.startsWith(u8, input, strnum[0])) {
            return strnum[1];
        }
    }

    return null;
}
