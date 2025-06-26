import lorem
import socket
import time

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

while True:
    msg = lorem.get_sentence(count=1, comma=(0, 2), word_range=(4, 8), sep=' ')
    print(msg)
    sock.sendto(msg.encode("utf-8"), ("10.1.2.3", 51966))
    time.sleep(2)
