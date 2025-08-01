const std = @import("std");
const mustache = @import("mustache");

const Allocator = std.mem.Allocator;

pub const ViewConfig = struct {
    const Self = @This();

    const ViewStrings = struct {
        const Partial = struct { []const u8, []const u8 };

        base: []const u8,
        partials: []const Self.ViewStrings.Partial,
    };

    pub const PartialConfig = struct { name: []const u8, path: []const u8 };

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

pub const PageData = struct {
    title: ?[]const u8 = null,
    content: []const u8,
};

pub fn renderTemplate(
    allocator: Allocator,
    views: *const ViewConfig.ViewStrings,
    data: *const PageData,
) ![]const u8 {
    return mustache.allocRenderTextPartials(
        allocator,
        views.base,
        views.partials,
        data,
    );
}
