// See: https://build-your-own.org/redis/04/04_client.cpp.htm

const std = @import("std");
const os = std.os;

const lib = @import("04_lib.zig");

pub fn main() !void {
    const fd = try os.socket(os.AF.INET, os.SOCK.STREAM, 0);
    defer os.close(fd);

    const addr = os.sockaddr.in{ .addr = 0, .port = 1234 };
    try os.connect(fd, @ptrCast(*const os.sockaddr, &addr), @sizeOf(os.sockaddr.in));

    try query(fd, "hello1");
    try query(fd, "hello2");
    try query(fd, "hello3");
}

const head_len = @sizeOf(u32);
const max_message_len = 4096;

fn query(fd: os.socket_t, text: [:0]const u8) !void {
    if (text.len > max_message_len) return lib.ProtocolError.TooLong;

    var write_buffer: [head_len + max_message_len]u8 = undefined;

    std.mem.writeIntLittle(u32, write_buffer[0..head_len], @intCast(u32, text.len));
    std.mem.copy(u8, write_buffer[head_len .. head_len + text.len], text);

    try lib.write_all(fd, write_buffer[0 .. head_len + text.len]);

    var read_buffer: [head_len + max_message_len]u8 = undefined;
    try lib.read_full(fd, read_buffer[0..head_len]);

    const len = std.mem.readIntLittle(u32, read_buffer[0..head_len]);
    if (len > max_message_len) return lib.ProtocolError.TooLong;

    try lib.read_full(fd, read_buffer[head_len .. head_len + len]);
    read_buffer[head_len + len] = 0;

    std.debug.print("server says: {s}\n", .{read_buffer[head_len .. head_len + len]});
}
