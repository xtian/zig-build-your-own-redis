const std = @import("std");
const os = std.os;

pub const ProtocolError = error{TooLong};
pub const ReadError = error{EndOfFile};

pub fn read_full(fd: os.socket_t, buffer: []u8) !void {
    var offset: usize = 0;

    while (os.read(fd, buffer[offset..])) |num_bytes| {
        offset += num_bytes;
        if (num_bytes == 0) return ReadError.EndOfFile;
        if (offset >= buffer.len) break;
    } else |err| {
        return err;
    }
}

pub fn write_all(fd: os.socket_t, buffer: []u8) !void {
    var offset: usize = 0;

    while (os.write(fd, buffer[offset..])) |num_bytes| {
        offset += num_bytes;
        if (offset >= buffer.len) break;
    } else |err| {
        return err;
    }
}
