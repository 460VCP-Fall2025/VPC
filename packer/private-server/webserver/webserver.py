from socket import *
import sys
import threading

def handle_request(connection_socket):
    try:
        message = connection_socket.recv(1024).decode()

        if not message:
            connection_socket.close()
            return

        # Extract file name
        filename = message.split()[1][1:]

        with open(filename, 'r') as f:
            outputdata = f.read()

        # Send header
        header = (
            "HTTP/1.1 200 OK\r\n"
            "Content-Type: text/html; charset=UTF-8\r\n"
            "Connection: close\r\n"
            "\r\n"
        )
        connection_socket.send(header.encode())

        # Send file content
        connection_socket.sendall(outputdata.encode())

    except Exception:
        # 404 response
        error_header = (
            "HTTP/1.1 404 Not Found\r\n"
            "Content-Type: text/html; charset=UTF-8\r\n"
            "Connection: close\r\n"
            "\r\n"
        )
        error_body = (
            "<html><body><h1>404 - File Not Found</h1></body></html>"
        )

        connection_socket.send(error_header.encode())
        connection_socket.send(error_body.encode())

    finally:
        connection_socket.close()


def main():
    server_socket = socket(AF_INET, SOCK_STREAM)
    server_port = 8080

    server_socket.setsockopt(SOL_SOCKET, SO_REUSEADDR, 1)
    server_socket.bind(('', server_port))
    server_socket.listen(5)   # allow more pending connections

    print("The server is ready to receive")

    while True:
        connection_socket, addr = server_socket.accept()
        print(f"Connection accepted from {addr}")

        # Create a new thread for each client
        thread = threading.Thread(
            target=handle_request,
            args=(connection_socket,)
        )
        thread.daemon = True     # auto-destroy threads on exit
        thread.start()


if __name__ == "__main__":
    main()
