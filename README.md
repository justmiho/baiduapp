# baiduapp

百度网盘群晖套件（`baiduapp`）中抽离出来的 Docker 镜像。把原套件里的 Java 后端与前端页面打包成一个容器，可在群晖 DSM 的 Container Manager 或任意 Docker 环境中独立运行。

## 挂载点

| 容器路径 | 用途 | 是否必须 |
|---|---|---|
| `/data` | SQLite 数据库、登录态、`share_volumes.map` | 必须，否则重启后登录信息丢失 |
| `/all_shares` | 网盘上传 / 下载的根目录。容器启动时会把其下每个子目录软链到 `/sdkpath/volumeN/<子目录名>` | 必须 |
| `/tmp/nas-file/logs` | 应用日志 | 可选 |

Web 页面由容器内 nginx 提供，默认监听 `8080`，只需映射这一个端口。

### 环境变量

| 变量 | 默认值 | 说明 |
|---|---|---|
| `WEB_PORT` | `8080` | nginx 监听端口。bridge 模式下用 `ports` 映射即可，无需修改；host 模式下没有端口映射，可通过它直接指定宿主机上的访问端口 |
| `API_HOST` | `127.0.0.1:8091` | 后端内部地址，保持默认 |

### `share_volumes.map`（可选）

放在 `/data/share_volumes.map`，每行 `<共享名>\t<volumeN>`（制表符分隔），用于指定某个共享映射到哪个卷号。没有映射表或表中查不到的共享一律按 `volume1` 处理。

```
photo	volume1
video	volume2
```

## 快速开始

### docker run

```bash
docker run -d \
  --name baiduapp \
  --restart always \
  -p 8092:8080 \
  -e API_HOST=127.0.0.1:8091 \
  -v /path/to/data:/data \
  -v /path/to/shares:/all_shares \
  -v /path/to/logs:/tmp/nas-file/logs \
  --user 0:0 \
  justmiho/baiduapp:1.0.15-73009
```

浏览器打开 `http://<宿主机IP>:8092`，扫码登录百度网盘即可。

### docker compose

```yaml
services:
  baiduapp:
    image: justmiho/baiduapp:1.0.15-73009
    container_name: baiduapp
    restart: always
    user: "0:0"
    ports:
      - "8092:8080"
    environment:
      - API_HOST=127.0.0.1:8091
    volumes:
      - ./data:/data
      - ./logs:/tmp/nas-file/logs
      - /volume1:/all_shares          # 群晖: 挂整卷; 其它系统: 挂你想让网盘访问的目录
```

```bash
docker compose up -d
```

### host 网络模式

host 模式下 `ports` 不生效，容器直接占用宿主机端口。用 `WEB_PORT` 指定访问端口即可：

```yaml
services:
  baiduapp:
    image: justmiho/baiduapp:1.0.15-73009
    container_name: baiduapp
    restart: always
    user: "0:0"
    network_mode: host
    environment:
      - WEB_PORT=8092
      - API_HOST=127.0.0.1:8091
    volumes:
      - ./data:/data
      - ./logs:/tmp/nas-file/logs
      - /volume1:/all_shares
```

注意 host 模式下容器内的 `8090`、`8091` 也会直接占用宿主机端口，请确认没有冲突。

## 自行构建

```bash
git clone https://github.com/justmiho/baiduapp.git
cd baiduapp/baiduapp
docker build -t baiduapp:local .
```

基础镜像为 `registry.baidubce.com/netdisk/openjdk:8-nginx`。

## 目录结构

```
baiduapp/
├── Dockerfile
├── endpoint.sh          # 容器入口: 建软链 → 起 java → 起 nginx → 守护
├── application.yml      # Spring Boot 配置 (端口、SQLite 路径、百度 App 信息)
├── target/*.jar         # 后端
├── dist/                # 前端静态页面
├── nginx/nginx.conf
├── sh/                  # 套件运行时调用的辅助脚本
└── machine-id           # 设备标识占位
.github/workflows/docker-publish.yml   # 自动构建并发布到 Docker Hub
```

## 注意事项

- 镜像面向群晖 DSM 设计，`sh/address.sh` 等脚本会读取 `/proc/sys/kernel/syno_mac_addresses` 作为设备标识。在非群晖主机上运行时这些内核参数不存在，设备识别与部分功能未经验证。
- `application.yml` 中的 `baidu.appKey` / `secretKey` 为套件自带的百度开放平台应用信息，与个人账号无关。
- 本项目与百度、群晖均无关联，仅供学习与个人使用。
