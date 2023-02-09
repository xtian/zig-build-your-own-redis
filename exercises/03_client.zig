// See: https://build-your-own.org/redis/03/03_client.cpp.htm

const std = @import("std");
const os = std.os;

pub fn main() !void {
    const fd = try os.socket(os.AF.INET, os.SOCK.STREAM, 0);
    defer os.close(fd);

    const addr = os.sockaddr.in{ .addr = 0, .port = 1234 };
    try os.connect(fd, @ptrCast(*const os.sockaddr, &addr), @sizeOf(os.sockaddr.in));

    _ = try os.write(fd, "hello");

    var read_buffer = [_]u8{0} ** 64;
    _ = try os.read(fd, &read_buffer);

    std.debug.print("server says: {s}\n", .{read_buffer});
}
