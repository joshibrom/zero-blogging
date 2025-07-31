//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");

const Allocator = std.mem.Allocator;

const TEMPL_BASE = "views/base.must.html";

fn readToString(allocator: Allocator, fname: []const u8) ![]const u8 {
    const f = try std.fs.cwd().openFile(fname, .{});
    defer f.close();
    return f.readToEndAlloc(allocator, 10000);
}

pub fn main() !void {
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    const templ = try readToString(std.heap.page_allocator, TEMPL_BASE);
    try stdout.print("{s}\n", .{templ});

    try bw.flush(); // Don't forget to flush!
}
