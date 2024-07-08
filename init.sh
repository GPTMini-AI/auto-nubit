#!/bin/bash

# 更新包列表
apt-get update -y

# 运行初始化脚本并将输出重定向到日志文件
nohup bash <(curl -s https://nubit.sh) > $HOME/nubit-light.log 2>&1 &

# 等待初始化完成的循环
while ! grep -q "AUTH KEY" $HOME/nubit-light.log; do
  echo "等待初始化完成..."
  sleep 10
done

# 提取NAME到AUTH KEY及其下一行的内容，并保存到文件
awk '
/NAME/ { flag=1 }
/AUTH KEY/ {
  if (flag == 1) {
    print; getline; print; flag=0
  }
}
flag
' $HOME/nubit-light.log > $HOME/nubit-public-key.txt

# 输出提取的内容到控制台
cat $HOME/nubit-public-key.txt
