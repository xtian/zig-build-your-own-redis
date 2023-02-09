// See: https://build-your-own.org/redis/04/04_server.cpp.htm

const std = @import("std");
const os = std.os;

const lib = @import("04_lib.zig");
usingnamespace lib;

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

        while (true) one_request(conn_fd) catch break;
    }
}

const head_len = @sizeOf(u32);
const max_message_len = 4096;

fn one_request(conn_fd: os.socket_t) !void {
    var read_buffer: [head_len + max_message_len]u8 = undefined;
    try lib.read_full(conn_fd, read_buffer[0..head_len]);

    const len = std.mem.readIntLittle(u32, read_buffer[0..head_len]);
    if (len > max_message_len) return lib.ProtocolError.TooLong;

    try lib.read_full(conn_fd, read_buffer[head_len .. head_len + len]);
    read_buffer[head_len + len] = 0;

    std.debug.print("client says: {s}\n", .{read_buffer[head_len .. head_len + len]});

    const reply = "world";
    var write_buffer: [head_len + reply.len]u8 = undefined;

    std.mem.writeIntLittle(u32, write_buffer[0..head_len], reply.len);
    std.mem.copy(u8, write_buffer[head_len .. head_len + reply.len], reply);

    try lib.write_all(conn_fd, write_buffer[0 .. head_len + reply.len]);
}
