#!/bin/sh
echo "nameserver 223.5.5.5" >> /etc/resolv.conf

# ---------------------------------------------------------------------------
# DSM 7.3 共享目录适配: 还原历史路径 /sdkpath/volumeN/<共享>
#
# 宿主机把统一入口 all_shares 整挂到本容器 /all_shares(compose 静态写死)。
# postinst(无需 root)在 /data/share_volumes.map 里给出 <共享名>\t<volumeN> 映射,
# 这里据此把 /sdkpath/volumeN/<共享> 软链到 /all_shares/<共享>;
# 映射表缺失/查不到的共享一律按 volume1 兜底。
# ---------------------------------------------------------------------------
setup_sdkpath_links() {
    MAP="/data/share_volumes.map"
    # application.yml 的 file_listener.path 固定为 /sdkpath, 旧版由 compose 挂载保证其存在,
    # 新版改成此处现场创建。无条件先建出根目录, 避免 all_shares 缺失时 Java 监听到不存在的
    # 路径(那会让 8090 起不来, 表现为前端接口全挂)。
    mkdir -p /sdkpath/volume1
    [ -d /all_shares ] || { echo "all_shares 未挂载, 跳过 sdkpath 软链"; return; }
    for share in /all_shares/*; do
        [ -e "$share" ] || continue
        name=$(basename "$share")
        vol=""
        if [ -f "$MAP" ]; then
            vol=$(awk -F'\t' -v n="$name" '$1==n{print $2; exit}' "$MAP")
        fi
        [ -n "$vol" ] || vol="volume1"
        mkdir -p "/sdkpath/$vol"
        # 幂等: 已存在的旧链接先删(容器重启/共享变化时刷新)
        [ -L "/sdkpath/$vol/$name" ] && rm -f "/sdkpath/$vol/$name"
        [ -e "/sdkpath/$vol/$name" ] || ln -s "/all_shares/$name" "/sdkpath/$vol/$name"
        echo "sdkpath 链接: /sdkpath/$vol/$name -> /all_shares/$name"
    done
}
setup_sdkpath_links

# Web 端口可配置: host 网络模式下没有端口映射, 通过 WEB_PORT 指定 nginx 监听端口, 默认 8080
WEB_PORT="${WEB_PORT:-8080}"
sed -i "s/listen [0-9]*;/listen ${WEB_PORT};/" /etc/nginx/nginx.conf
echo "nginx 监听端口: ${WEB_PORT}"

java -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Djava.security.egd=file:/dev/./urandom -jar /app.jar --spring.config.additional-location=/application.yml &
nginx -g "daemon on;"

while true
do
    java=$( ps -ef | grep java | grep -v grep | wc -l )
    nginx=$( ps -ef | grep nginx | grep -v grep | wc -l )
    if [ $java -eq 0 ];then
        echo "java exit"
        return
    fi
    if [ $nginx -eq 0 ];then
        echo "nginx exit"
        return
    fi
    sleep 10
done
