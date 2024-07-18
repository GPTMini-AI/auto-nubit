# nubit 批量控制

## 机器配置

下面的脚本基于 Ubuntu 22 系统

使用 mac 系统作为客户端

## 第一次执行脚本

```shell
nohup bash <(curl -s https://raw.githubusercontent.com/GPTMini-AI/auto-nubit/main/init.sh) > $HOME/init_server_output.log 2>&1 &
```

## 批量控制

配置好免密登录以后使用 add2rebot.sh 加入机器重启，重启使用的是云平台的 api，可以加定时任务
