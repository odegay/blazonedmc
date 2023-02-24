from __future__ import print_function
import argparse
import socket
import collections
import struct

bufsize = 4096
Packet = collections.namedtuple("Packet", ("ident", "kind", "payload"))

# python 2 compatibility
try:
    input = raw_input
except NameError:
    pass

class IncompletePacket(Exception):
    def __init__(self, minimum):
        self.minimum = minimum

def decode_packet(data):
    """
    Decodes a packet from the beginning of the given byte string. Returns a
    2-tuple, where the first element is a ``Packet`` instance and the second
    element is a byte string containing any remaining data after the packet.
    """

    if len(data) < 14:
        raise IncompletePacket(14)

    length = struct.unpack("<i", data[:4])[0] + 4
    if len(data) < length:
        raise IncompletePacket(length)

    ident, kind = struct.unpack("<ii", data[4:12])
    payload, padding = data[12:length-2], data[length-2:length]
    assert padding == b"\x00\x00"
    return Packet(ident, kind, payload), data[length:]


def encode_packet(packet):
    """
    Encodes a packet from the given ``Packet` instance. Returns a byte string.
    """

    data = struct.pack("<ii", packet.ident, packet.kind) + packet.payload + b"\x00\x00"
    return struct.pack("<i", len(data)) + data


def receive_packet(sock):
    """
    Receive a packet from the given socket. Returns a ``Packet`` instance.
    """

    data = b""
    while True:
        try:
            return decode_packet(data)[0]
        except IncompletePacket as exc:
            while len(data) < exc.minimum:
                data += sock.recv(exc.minimum - len(data))


def send_packet(sock, packet):
    """
    Send a packet to the given socket.
    """

    sock.sendall(encode_packet(packet))


def login(sock, password):
    """
    Send a "login" packet to the server. Returns a boolean indicating whether
    the login was successful.
    """

    send_packet(sock, Packet(0, 3, password.encode("utf8")))
    packet = receive_packet(sock)
    return packet.ident == 0


def command(sock, text):
    """
    Sends a "command" packet to the server. Returns the response as a string.
    """

    send_packet(sock, Packet(0, 2, text.encode("utf8")))
    send_packet(sock, Packet(1, 0, b""))
    response = b""
    while True:
        packet = receive_packet(sock)
        if packet.ident != 0:
            break
        response += packet.payload
    return response.decode("utf8")       
def main():
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("host")
    parser.add_argument("port", type=int)
    parser.add_argument("password")
    # parser.add_argument("command")
    
    args, unknownargs = parser.parse_known_args()
    if len(unknownargs) > 0:
        args.command = " ".join(unknownargs)
    else:
        print("command argument is missing ")    
        return
    try:    
        # Connect
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        print("connecting to  host: ", args.host, "port: ", args.port)
        sock.connect((args.host, args.port))
        print("CONNECTED to ", args.host)

    
        # Log in
        result = login(sock, args.password)
        if not result:
            print("Incorrect rcon password")
            return
        else:
            print("password accepted")

        # Start looping
#        while True:
#            request = input()
        print("sending ", args.command)
        response = command(sock, args.command)
        print("Command:", args.command, " executed, response = ", response)
    finally:
        sock.close()

if __name__ == '__main__':
    main()