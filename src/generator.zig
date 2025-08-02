const std = @import("std");
const mustache = @import("mustache");

const views = @import("views.zig");

const Allocator = std.mem.Allocator;

const VIEW_CONFIG = views.ViewConfig{
    .base = "views/base.must.html",
    .partials = &[_]views.ViewConfig.PartialConfig{
        .{ .name = "header", .path = "views/header.must.html" },
        .{ .name = "footer", .path = "views/footer.must.html" },
    },
};

fn generate(allocator: Allocator, data: *const views.PageData) ![]const u8 {
    const inputs = try VIEW_CONFIG.readStrings(allocator);
    return try views.renderTemplate(allocator, &inputs, data);
}

fn ensureSaveDirectory() !void {
    std.fs.cwd().makeDir("www") catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };
    return std.fs.cwd().makeDir("www/posts") catch |err| blk: switch (err) {
        error.PathAlreadyExists => break :blk {},
        else => break :blk err,
    };
}

fn save(allocator: Allocator, fname: []const u8, markup: []const u8) !usize {
    try ensureSaveDirectory();
    const filename = try std.fmt.allocPrint(allocator, "www/posts/{s}", .{fname});
    const f = try std.fs.cwd().createFile(filename, .{});
    defer f.close();
    return try f.write(markup);
}

pub fn renderFileToStorage(allocator: Allocator, fname: []const u8, data: *const views.PageData) !void {
    const markup = try generate(allocator, data);
    if (try save(allocator, fname, markup) == 0) return error.NothingWritten;
}
