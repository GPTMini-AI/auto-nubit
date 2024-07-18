#!/bin/bash

# 机器列表文件
MACHINE_LIST="machines.txt"

# 确认机器列表文件存在
if [ ! -f "$MACHINE_LIST" ]; then
  echo "机器列表文件 $MACHINE_LIST 不存在"
  exit 1
fi

# 获取文件总行数（排除注释行和空行）
total_lines=$(grep -v -e '^\s*#' -e '^\s*$' "$MACHINE_LIST" | wc -l)

# 初始化行计数器
current_line=0

# 遍历机器列表文件中的每一行
while IFS=, read -r line; do
    # 去掉行首和行尾的空白字符
    line=$(echo "$line" | xargs)

    # 跳过注释行和空行
    if [[ "$line" =~ ^# ]] || [[ -z "$line" ]]; then
        continue
    fi

    # 从行中提取 IP 和端口
    IFS=, read -r ip port <<< "$line"

    # 更新行计数器
    current_line=$((current_line + 1))

    echo "Processing $ip:$port ($current_line/$total_lines)"

    # 定义要创建的 shell 文件内容
    SCRIPT_CONTENT="nohup bash -c 'bash <(curl -s https://nubit.sh) > \$HOME/nubit-light-\$(date +%s).log 2>&1 &'"

    # 创建 shell 文件并执行
    ssh -n  -p "$port" root@"$ip" "echo \"$SCRIPT_CONTENT\" > \$HOME/nubit.sh && chmod +x \$HOME/nubit.sh && /bin/bash \$HOME/nubit.sh"
    if [ $? -ne 0 ]; then
        echo "Failed to execute script on $ip:$port"
        continue
    fi

    echo "Executed script on $ip:$port"

    # 添加脚本到开机启动
    ssh -n  -p "$port" root@"$ip" "(crontab -l; echo '@reboot /bin/bash \$HOME/nubit.sh') | crontab -"
    if [ $? -ne 0 ]; then
        echo "Failed to add cron job on $ip:$port"
        continue
    fi

    echo "Successfully processed $ip:$port"

done < "$MACHINE_LIST"

echo "Processed $current_line out of $total_lines machines."
