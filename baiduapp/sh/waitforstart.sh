#!/bin/sh

REDIS_HOST="baiduredis"
MYSQL_HOST="baidumysql"   # 替换为你的目标主机或IP
MYSQL_PORT="3306"
REDIS_PORT="6379"     # 替换为你的目标端口

while ! nc -z $MYSQL_HOST $MYSQL_PORT; do   
  echo "Waiting for $MYSQL_HOST:$MYSQL_PORT..."
  sleep 1           # 每次检查之间的等待时间，可以按需修改
done
echo "$MYSQL_HOST:$MYSQL_PORT is available now."

while ! nc -z $REDIS_HOST $REDIS_PORT; do   
  echo "Waiting for $REDIS_HOST:$REDIS_PORT..."
  sleep 1           # 每次检查之间的等待时间，可以按需修改
done
echo "$REDIS_HOST:$REDIS_PORT is available now."
