#!/bin/sh
echo `date` $* > /tmp/nassdk.log
#获取所有参数
echo $0
echo $*
echo $1
echo $2
echo $3
echo $4
echo $5
echo $6
cd /
mkdir -p /tmp/$5
echo "文件夹/tmp/$5创建成功"
mkdir -p $6
echo "文件夹$6创建成功"
cd /sdk
#检测端口是否存在

set -x

RUN=$(ps -ef |grep "sdk.sh" |grep -v "grep"  |wc -l)
echo $RUN
if [ $RUN -gt 2 ];
then
 echo "已执行"
return
fi

while true
do

  NUM=$(ps -ef |grep $2 |grep -v "grep" | grep -v "sdk.sh" |wc -l)
  echo 端口:$NUM

  if [ $NUM -ge 1 ];
  then
    echo "端口存在"
  else
    echo "端口不存在"
    #./baiduNas -ip $1 -port $2 -macid $3 -type $4 -tmppath $5 -downloadpath $6 -logoff yes
    chmod +x ./baiduNas
    chmod +x ./P2PClient
    ./baiduNas -ip $1 -port $2 -macid $3 -type $4 -tmppath /tmp/$5 -downloadpath $6 > /tmp/baidunas.log 2>&1
    if [ $? -eq 0 ]; then
      echo "脚本执行结束"
      return
    fi
    echo "脚本异常退出，重试"
  fi
  sleep 5
  #./baiduNas -ip 0.0.0.0 -port 8001 -macid 7d02fcdee7073af7d43880be6cbf7a67 -type 202307211140578992 -tmppath /tmppath/ -downloadpath /downloadpath  -logoff yes
done
