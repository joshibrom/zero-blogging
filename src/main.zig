//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.
const std = @import("std");
const mustache = @import("mustache");

const Allocator = std.mem.Allocator;

const ViewConfig = struct {
    const Self = @This();

    const PartialConfig = struct { name: []const u8, path: []const u8 };

    const ViewStrings = struct {
        const Partial = struct { []const u8, []const u8 };

        base: []const u8,
        partials: []const Self.ViewStrings.Partial,
    };

    base: []const u8,
    partials: []const PartialConfig,

    pub fn readStrings(self: *const Self, allocator: Allocator) !ViewStrings {
        var partials = std.ArrayList(Self.ViewStrings.Partial).init(allocator);

        for (self.partials) |pc| {
            try partials.append(.{
                pc.name, try Self.readToString(allocator, pc.path),
            });
        }

        return .{
            .base = try Self.readToString(allocator, self.base),
            .partials = try partials.toOwnedSlice(),
        };
    }

    fn readToString(allocator: Allocator, fname: []const u8) ![]const u8 {
        const f = try std.fs.cwd().openFile(fname, .{});
        defer f.close();
        return f.readToEndAlloc(allocator, 10000);
    }
};

const VIEW_CONFIG = ViewConfig{
    .base = "views/base.must.html",
    .partials = &[_]ViewConfig.PartialConfig{
        .{ .name = "header", .path = "views/header.must.html" },
        .{ .name = "footer", .path = "views/footer.must.html" },
    },
};

pub fn main() !void {
    var allocator = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const arena = allocator.allocator();

    const inputs = try VIEW_CONFIG.readStrings(arena);

    const templ = try mustache.allocRenderTextPartials(
        arena,
        inputs.base,
        inputs.partials,
        .{ .content = "Hello, world!" },
    );
    defer allocator.deinit();

    std.debug.print("{s}\n", .{templ});
}
