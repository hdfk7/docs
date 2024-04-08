# docker集群端口说明

2377：用于集群管理通信的TCP端口

7946:TCP和UDP的端口，用于节点间通信

4789：UDP端口，用于覆盖网络流量。


# docker集群命令
docker swarm init --advertise-addr 192.168.0.4

docker swarm init --advertise-addr 106.12.159.173 --data-path-port 5789

docker swarm join-token worker

docker swarm join-token manager

docker network create --driver overlay --attachable --subnet 10.25.0.0/24 fansmore-dev

docker stack deploy -c docker-compose.yml fansmore-dev


docker swarm join --advertise-addr 本机公网ip --token SWMTKN-1-50perjzm4ibsks59jjv7e1v6fg78tqpphuoq8htbq4ff91ew2l-4re36luenoapm3z909q8w73re 106.12.159.173:2377

docker swarm join --advertise-addr 本机公网ip --token xxxxxx 管理节点公网ip:2377
