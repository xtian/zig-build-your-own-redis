// See: https://build-your-own.org/redis/03/03_server.cpp.htm

const std = @import("std");
const os = std.os;

pub fn main() !void {
    const fd = try os.socket(os.AF.INET, os.SOCK.STREAM, 0);
    defer os.close(fd);

    try os.setsockopt(fd, os.SOL.SOCKET, os.SO.REUSEADDR, &std.mem.toBytes(@as(c_int, 1)));

    const addr = os.sockaddr.in{ .addr = 0, .port = 1234 };
    try os.bind(fd, @ptrCast(*const os.sockaddr, &addr), @sizeOf(os.sockaddr.in));
    try os.listen(fd, 1024);

    while (true) {
        const conn_fd = os.accept(fd, null, null, 0) catch continue;
        defer os.close(conn_fd);

        do_something(conn_fd);
    }
}

fn do_something(conn_fd: os.socket_t) void {
    var read_buffer = [_]u8{0} ** 64;
    _ = os.read(conn_fd, &read_buffer) catch {
        std.debug.print("read error", .{});
        return;
    };

    std.debug.print("client says: {s}\n", .{read_buffer});
    _ = os.write(conn_fd, "world") catch {};
}
