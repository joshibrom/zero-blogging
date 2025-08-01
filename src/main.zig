//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const mustache = @import("mustache");

const Allocator = std.mem.Allocator;

const VIEW_CONFIG = .{
    .base = "views/base.must.html",
    .partials = .{
        .{ "header", "views/header.must.html" },
        .{ "footer", "views/footer.must.html" },
    },
};

fn readToString(allocator: Allocator, fname: []const u8) ![]const u8 {
    const f = try std.fs.cwd().openFile(fname, .{});
    defer f.close();
    return f.readToEndAlloc(allocator, 10000);
}

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = allocator.allocator();

    const inputs = .{
        .base = try readToString(arena, VIEW_CONFIG.base),
        .partials = .{
            .{ "header", try readToString(arena, VIEW_CONFIG.partials[0][1]) },
            .{ "footer", try readToString(arena, VIEW_CONFIG.partials[1][1]) },
        },
    };

    const templ = try mustache.allocRenderTextPartials(
        arena,
        inputs.base,
        inputs.partials,
        .{ .content = "Hello, world!" },
    );
    defer allocator.deinit();

    std.debug.print("{s}\n", .{templ});
}
