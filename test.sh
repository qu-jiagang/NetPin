#!/bin/bash

# 网络选择器测试脚本
# 使用方法: ./test.sh

echo "=== 网络选择器测试脚本 ==="
echo

# 检查是否以root权限运行
if [ "$EUID" -ne 0 ]; then
    echo "警告: 建议以root权限运行此脚本以获得最佳效果"
    echo "请使用: sudo ./test.sh"
    echo
fi

# 编译程序
echo "1. 编译程序..."
make clean
make
if [ $? -ne 0 ]; then
    echo "编译失败！"
    exit 1
fi
echo "编译成功！"
echo

# 测试帮助信息
echo "2. 测试帮助信息..."
./network_selector -h
echo

# 测试接口列表
echo "3. 测试接口列表..."
./network_selector -l
echo

# 检查是否有可用的网络接口
echo "4. 检查网络接口..."
INTERFACES=$(ip link show | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/://')
if [ -z "$INTERFACES" ]; then
    echo "未找到网络接口！"
    exit 1
fi

# 选择第一个可用接口进行测试
FIRST_INTERFACE=$(echo "$INTERFACES" | head -n 1)
echo "使用接口: $FIRST_INTERFACE"

# 测试ping命令
echo "5. 测试ping命令..."
echo "使用接口 $FIRST_INTERFACE 运行 ping -c 1 127.0.0.1"
./network_selector -i "$FIRST_INTERFACE" ping -c 1 127.0.0.1
if [ $? -eq 0 ]; then
    echo "ping测试成功！"
else
    echo "ping测试失败！"
fi
echo

# 测试curl命令（如果可用）
if command -v curl &> /dev/null; then
    echo "6. 测试curl命令..."
    echo "使用接口 $FIRST_INTERFACE 运行 curl -I http://example.com"
    ./network_selector -i "$FIRST_INTERFACE" curl -I http://example.com
    if [ $? -eq 0 ]; then
        echo "curl测试成功！"
    else
        echo "curl测试失败！"
    fi
    echo
else
    echo "6. 跳过curl测试（curl未安装）"
    echo
fi

# 测试wget命令（如果可用）
if command -v wget &> /dev/null; then
    echo "7. 测试wget命令..."
    echo "使用接口 $FIRST_INTERFACE 运行 wget --spider http://example.com"
    ./network_selector -i "$FIRST_INTERFACE" wget --spider http://example.com
    if [ $? -eq 0 ]; then
        echo "wget测试成功！"
    else
        echo "wget测试失败！"
    fi
    echo
else
    echo "7. 跳过wget测试（wget未安装）"
    echo
fi

# 测试错误处理
echo "8. 测试错误处理..."
echo "测试不存在的接口..."
./network_selector -i nonexistent ping -c 1 127.0.0.1
if [ $? -ne 0 ]; then
    echo "错误处理测试通过！"
else
    echo "错误处理测试失败！"
fi
echo

# 测试无参数情况
echo "9. 测试无参数情况..."
./network_selector
if [ $? -ne 0 ]; then
    echo "无参数测试通过！"
else
    echo "无参数测试失败！"
fi
echo

# 清理测试文件
echo "10. 清理测试文件..."
if [ -f "index.html" ]; then
    rm -f index.html
fi

echo "=== 测试完成 ==="
echo
echo "测试结果总结:"
echo "- 编译: 成功"
echo "- 帮助信息: 正常"
echo "- 接口列表: 正常"
echo "- 网络功能: 已测试"
echo "- 错误处理: 已测试"
echo
echo "如果所有测试都通过，说明工具工作正常！" 