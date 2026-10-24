# Docker Swarm 集群速查

以下 IP、令牌、网络名称均为示例，执行前替换成实际环境。涉及 Swarm 管理的操作在管理节点执行。

## 节点间需要的端口

| 端口 | 协议 | 用途 |
| --- | --- | --- |
| 2377 | TCP | 集群管理通信 |
| 7946 | TCP / UDP | 节点发现与通信 |
| 4789 | UDP | 默认覆盖网络数据通信 |

端口应在可信节点之间放通，尤其不要把 VXLAN 数据端口直接暴露给不可信网络。

## 初始化管理节点

```bash
docker swarm init --advertise-addr 192.0.2.10

# 如确需自定义覆盖网络数据端口，在初始化时指定
# docker swarm init --advertise-addr 192.0.2.10 --data-path-port 5789
```

自定义数据端口后，应按实际端口配置节点之间的防火墙规则。

## 获取加入命令

```bash
docker swarm join-token worker
docker swarm join-token manager
```

在待加入的节点执行输出的命令。例如：

```bash
docker swarm join \
  --advertise-addr 192.0.2.11 \
  --token '<WORKER_TOKEN>' \
  192.0.2.10:2377
```

不要把真实加入令牌放进公开笔记。如果旧令牌曾公开，需由管理节点轮换对应令牌：

```bash
docker swarm join-token --rotate worker
docker swarm join-token --rotate manager
```

## 创建覆盖网络并部署

```bash
docker network create --driver overlay --attachable \
  --subnet 10.25.0.0/24 example-net

docker stack deploy -c docker-compose.yml example-stack
```

如 Compose 文件使用上面预先创建的网络，应将其声明为外部网络：

```yaml
networks:
  example-net:
    external: true
```

服务本身也需要在 Compose 文件中引用该网络。

## 检查运行状态

```bash
docker node ls
docker network ls
docker stack services example-stack
docker stack ps example-stack
```

参考：[Docker Swarm 入门与端口要求](https://docs.docker.com/engine/swarm/swarm-tutorial/)。
