from socket import *
import sys

def main():
    arg1 = sys.argv[1] #server_host
    arg2 = sys.argv[2] #server_port
    arg3 = sys.argv[3] #file name
    client_socket = socket(AF_INET, SOCK_STREAM)
    client_socket.connect((arg1, int(arg2)))

    #A successful GET request would be:
    #GET /HelloWorld.html
    #Host: http://localhost:8080 (or) Host: http://127.0.0.1:8080
    http_request = f"GET /{arg3} HTTP/1.1\r\nHost: http://{arg1}:{arg2}\r\n\r\n"

    
    client_socket.send(http_request.encode())

    http_response = "" #storing whole html file in a string
    while True:
        chunk = client_socket.recv(1024).decode() #receiving each packet
        if not chunk: break #once empty, stop receiving
        http_response += chunk #append chunk to the string

    print(http_response) #display html page

    client_socket.close()

if __name__ == "__main__":
    main()
