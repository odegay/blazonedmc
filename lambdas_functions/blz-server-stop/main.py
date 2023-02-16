from __future__ import print_function
import argparse
import socket
import mcrcon


# python 2 compatibility
try:
    input = raw_input
except NameError:
    pass



def main():
    # Parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument("host")
    parser.add_argument("port", type=int)
    parser.add_argument("password")
    args = parser.parse_args()
    print("args accepted ", args)
    # Connect
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    print("connecting to  host: ", args.host, "port: ", args.port)
    sock.connect((args.host, args.port))
    print("CONNECTED to ", args.host)

    try:
        # Log in
        result = mcrcon.login(sock, args.password)
        if not result:
            print("Incorrect rcon password")
            return
        else:
            print("password accepted")

        # Start looping
        while True:
            request = input()
            print("sending ", request)            
            response = mcrcon.command(sock, request)
            print(response)
    finally:
        sock.close()

if __name__ == '__main__':
    main()