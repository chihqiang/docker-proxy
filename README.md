#  Proxy Toolkit with Docker

本项目收集了一组常用代理服务的 Docker 镜像，支持快速部署 SSH、SOCKS5、VPN、HTTP 代理、V2Ray/Xray 等服务。

## 🐧 SSH Server

拉取镜像：

```
docker pull zhiqiangwang/proxy:ssh
```

### 默认模式（用户：ubuntu，密码：12345）

```
docker run -d --name ubuntu -p 8022:22 zhiqiangwang/proxy:ssh
ssh ubuntu@127.0.0.1 -p 8022
```

### 自定义用户密码

```
docker run -d --name ubuntu \
  -e SSH_USER=root \
  -e SSH_PASSWORD=123456 \
  -p 8022:22 zhiqiangwang/proxy:ssh

ssh root@127.0.0.1 -p 8022
```

✅ **建议**：请勿在生产环境中使用默认密码。

## 🧦 Dante - A Free SOCKS5 Server

官方网址：https://www.inet.no/dante/

拉取镜像：

```
docker pull zhiqiangwang/proxy:dante
```

运行：

```
docker run -it --rm --name dante \
  -p 1080:1080 \
  -e USER_NAME="dante" \
  -e USER_PASS="dante123" \
  zhiqiangwang/proxy:dante
```

✅ **用途**：适用于 Telegram、OpenAI、GitHub 等需要代理的客户端。

## 🔐 OpenVPN Server

官方网址：https://openvpn.net/

拉取镜像：

```
docker pull zhiqiangwang/proxy:openvpn
```

### 启动容器

#### 使用默认配置（全局代理）

```
docker run -it --rm --name openvpn \
  --privileged \
  -p 1194:1194 \
  -e USE_DEFAULT_CONF=1 \
  --device=/dev/net/tun \
  zhiqiangwang/proxy:openvpn
```

#### 自动获取 IP 模式

```
docker run -it --rm --name openvpn \
  --privileged \
  -p 1194:1194 \
  -e USE_DEFAULT_CONF=0 \
  --device=/dev/net/tun \
  zhiqiangwang/proxy:openvpn
```

#### 自定义配置

~~~
docker run -it --rm --name openvpn \
  --privileged \
  -p 1194:1194 \
  -v openvpn.conf:/etc/openvpn/openvpn.conf
  -e USE_DEFAULT_CONF=0 \
  --device=/dev/net/tun \
  zhiqiangwang/proxy:openvpn
~~~

### 管理命令（容器内）

进入容器：

```
docker exec -it openvpn bash
```

生成客户端配置：

```
cd /etc/openvpn/setup
./newclient.sh
```

测试 `.ovpn` 配置文件（外部运行 OpenVPN）：

```
openvpn --config /etc/openvpn/certs/pki/client1.ovpn
```

吊销客户端证书：

```
cd /etc/openvpn/setup
./removeclient.sh
```

✅ **建议**：生成的客户端配置可下载至本地使用。

## 🦑 Squid - HTTP Proxy

官方网址：https://www.squid-cache.org/

拉取镜像：

~~~
docker pull zhiqiangwang/proxy:squid
~~~

运行：

```
docker run -it --rm --name squid \
  -p 3128:3128 \
  -e PROXY_USERS="squid:squid123" \
  zhiqiangwang/proxy:squid
```

测试代理：

```
curl -x http://squid:squid123@localhost:3128 ipinfo.io
```

✅ **用途**：适用于 HTTP/HTTPS 的基本代理需求。

## ⚡ v2ray - 多协议代理平台

GitHub：https://github.com/v2fly/v2ray-core

拉取镜像：

~~~
docker pull zhiqiangwang/proxy:v2ray
~~~

运行：

```
docker run -it --rm --name v2ray \
  -p 10086:10086 \
  -v $(pwd)/config.json:/etc/v2ray/config.json \
  zhiqiangwang/proxy:v2ray
```

✅ **说明**：请提前准备好符合规范的 `config.json` 文件。

## ✴️ Xray - V2Ray 的进阶分支

GitHub：https://github.com/XTLS/Xray-core

拉取镜像：

~~~
docker pull zhiqiangwang/proxy:xray
~~~

运行：

```
docker run -it --rm --name xray \
  -p 9000:9000 \
  -v $(pwd)/config.json:/etc/xray/config.json \
  zhiqiangwang/proxy:xray
```

✅ **用途**：支持 XTLS、Reality、VLESS 等新特性，适合高级场景。

## 📌 注意事项

- 所有服务建议使用防火墙控制外网访问。
- 自定义配置文件推荐使用挂载方式（`-v`）。
- 建议将账号密码配置放入 `.env` 文件进行管理。
