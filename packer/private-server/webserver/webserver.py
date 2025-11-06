# Import required modules
from socket import *
import sys  # For program termination
import requests

# (Optional) To implement multithreading, the 'threading' module should be imported.
# import threading


def handle_request(connection_socket):
    """
    This function handles the client request. You need to fill in the blanks.
    """
    try:
        message = connection_socket.recv(1024).decode()
        
        # Extracts the filename from the given message. 
        # For example, for "GET /HelloWorld.html HTTP/1.1" it extracts "HelloWorld.html".
        filename = message.split()[1][1:]
        with open(filename, 'r') as f:
            outputdata = f.read()
            
            # Send HTTP header with response
            # FILL IN start
            header = "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset= UTF-8\r\n\r\n"
            connection_socket.send(header.encode())
            # FILL IN end

            for i in range(0, len(outputdata)):
                connection_socket.send(outputdata[i].encode())
            connection_socket.send("\r\n".encode())

    except IOError: #or IndexError:
        # Send HTTP 404 response when file not found
        # FILL IN start
        error_header = 'HTTP/1.1 404 Not Found\r\nContent-Type: text/html; charset=UTF-8\r\n\r\n'
        error_body = '<html>\r\n<body>\r\n\r\n<h1>OOPS! FILE NOT FOUND:/</h1>\r\n\r\n</body>\r\n</html>\r\n'
        connection_socket.send(error_header.encode())
        connection_socket.send(error_body.encode())
        # FILL IN end
    finally:
        connection_socket.close()

def main():
    server_socket = socket(AF_INET, SOCK_STREAM)
    
    # Bind to an address and port
    # FILL IN start
    server_port = 8080
    #I kept getting the error: (Address already in use) when trying to run this program right after a previous run
    #The reason was because the socket would hog the port it was using for a bit even after the program ended
    #So CHATGPT 5.0 wrote this following line to allow reuse of the port right after program ends.
    server_socket.setsockopt(SOL_SOCKET,SO_REUSEADDR,1)
    server_socket.bind(('',server_port))
    
    # FILL IN end

    # Listen for incoming connections
    # FILL IN start
    server_socket.listen(1)

    # FILL IN end

    print("The server is ready to receive")
    
    while True:
        connection_socket, addr = server_socket.accept()

        # To implement a multithreaded server, you would create a new thread here
        # that runs the handle_request function. E.g.,
        # threading.Thread(target=handle_request, args=(connection_socket,)).start()

        # For now, just handle the request using the main thread
        handle_request(connection_socket)

    server_socket.close()
    sys.exit()  # Terminate the program

if __name__ == "__main__":
    main()
