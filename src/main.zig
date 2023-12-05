const print = @import("std").debug.print;
const aoc = @import("aoc.zig");

pub fn main() !void {
    const day1_input = @embedFile("inputs/day1.txt");
    const day2_input = @embedFile("inputs/day2.txt");
    const day3_input = @embedFile("inputs/day3.txt");
    const day4_input = @embedFile("inputs/day4.txt");
    const day5_input = @embedFile("inputs/day5.txt");

    print("Day 1 Part 1 result: {d}!\n", .{try aoc.day1_part1(day1_input)});
    print("Day 1 Part 2 result: {d}!\n", .{try aoc.day1_part2(day1_input)});
    print("Day 2 Part 1 result: {d}!\n", .{try aoc.day2_part1(day2_input)});
    print("Day 2 Part 2 result: {d}!\n", .{try aoc.day2_part2(day2_input)});
    print("Day 3 Part 1 result: {d}!\n", .{try aoc.day3_part1(day3_input)});
    print("Day 3 Part 2 result: {d}!\n", .{try aoc.day3_part2(day3_input)});
    print("Day 4 Part 1 result: {d}!\n", .{try aoc.day4_part1(day4_input)});
    print("Day 4 Part 2 result: {d}!\n", .{try aoc.day4_part2(day4_input)});
    print("Day 5 Part 1 result: {d}!\n", .{try aoc.day5_part1(day5_input)});
    //print("Day 5 Part 2 result: {d}!\n", .{try aoc.day5_part2(day5_input)});
}
