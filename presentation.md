#### request <-> web server <-> application server

- What is happening .accept()/read()
- How nginx works
- What can we investigate

---

#### How it works

- HTTP -> TCP -> IP -> MAC
- socket
 - logic structure, = file descriptor
 - = source ip:port + destination ip:port
- NIC
 - = physical device representation in OS
 - interacts with kernel, has a MAC address

Notes:
- virtual network interface = real (NIC) or virtual

----

![image](http://www.laneye.com/network/ethernet-network-packet-holding-an-ip-packet.gif)

----

![image](./seven-layers-of-OSI-model.png)

---
#### Control flow

- a process binds a listening socket
 - .accept(0.0.0.0:80) -blocking
- call returns a connected socket
- read/write on connected socket
- socket is closed or timed out

---
#### Control flow v2 (ESTABLISHED)

- NIC receives data
- NIC (interrupt/poll) kernel
- kernel look up socket
- kernel copy data to fd buffer
- kernel notify processes blocked or polling on it
- process works
- process writes to socket fd
- kernel writes to NIC

Notes:
- .accept() => creates listening socket
- kernel may buffer these because new client may try to connect while .accept() is not called
- epoll polls for a short time for events on sockets
- socket statuses: https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.halu101/constatus.htm
- tcpdump/wireshark use pcap (libcap interact with os to capture packages on NIC)
- Ethernet packets can be maximum 1,5 KB

---
#### nginx Overview

- released in 2004 by Igor Sysoev to solve C10K
- C mostly, 8k commits, 203k loc, 66 contributors, BSD
- second web server by popularity

Notes:
- On OpenHub, 19% of C programs are comments, nginx has 4% comments
- Nginx took of after 2011 (company + more contributors)
- 69% C, 20% Perl
- Apache has 40k commits, 1,5M loc, 125 contributors

---
#### nginx Arhitecture

- master process - reads config, port binding, child management
- cache loader - on startup loads disk cache in memory
- cache manager - prunes disk cache
- worker - handle connections, read/write, communicate with upstreams

Notes:
https://www.nginx.com/blog/inside-nginx-how-we-designed-for-performance-scale/

----
![image](http://www.aosabook.org/images/nginx/architecture.png)
http://www.aosabook.org/en/nginx.html

Notes:
http://people.eecs.berkeley.edu/~sangjin/2012/12/21/epoll-vs-kqueue.html

---
#### nginx worker

- listen on sockets from master (lock or SO_REUSEPORT)
- event loop driven (new connections, established connections)
 - multiple workers to take advantage of CPUs
- state machine - match block, rates, authentication, resolve/upstream, response, logging

----
![image](https://www.nginx.com/wp-content/uploads/2015/06/infographic-Inside-NGINX_request-flow.png)
https://www.nginx.com/blog/inside-nginx-how-we-designed-for-performance-scale/


---
#### How we can investigate


```
#host
docker build -t pres_nginx .
docker run -it -p 80:80 pres_nginx bash
# List tcp network connections
netstat -tapne
# Route info
netstat -r
# Net traffic statistics
netstat -s
# List processes
ps -F fax
```

---
#### no server
```
#host
telnet localhost 80
```

```
#docker
netstat -tapne
lsof -i
tcpdump
```

---
#### with nginx

```
#docker
service nginx start
ps -F fax
lsof -i
ls -l /proc/<pid>/fd
lsof |wc -l
tcpdump
tcpdump -A 'tcp port 80'
# or python3 -m http.server 80
```


```
#host
telnet localhost 80
time curl -s "localhost?[1-100]"
```

---
#### Resources

- [nginx arhitecture blog](https://www.nginx.com/blog/inside-nginx-how-we-designed-for-performance-scale/)
- [nginx architecture article](http://www.aosabook.org/en/nginx.html)
- [How TCP socket work post](https://eklitzke.org/how-tcp-sockets-work)
- [OSI - TCP](https://community.fs.com/blog/tcpip-vs-osi-whats-the-difference-between-the-two-models.html)
- [TCP States](https://www.ibm.com/support/knowledgecenter/en/SSLTBW_2.1.0/com.ibm.zos.v2r1.halu101/constatus.htm)