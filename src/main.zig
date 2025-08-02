//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const mustache = @import("mustache");

const views = @import("views.zig");
const generator = @import("generator.zig");

const Allocator = std.mem.Allocator;

const VIEW_CONFIG = views.ViewConfig{
    .base = "views/base.must.html",
    .partials = &[_]views.ViewConfig.PartialConfig{
        .{ .name = "header", .path = "views/header.must.html" },
        .{ .name = "footer", .path = "views/footer.must.html" },
    },
};

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = allocator.allocator();
    defer allocator.deinit();
    try generator.renderFileToStorage(arena, "hello.html", &views.PageData{ .subtitle = "hello page", .content = "Hello, world!" });
}
