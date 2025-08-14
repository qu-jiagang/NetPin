#!/bin/bash

# 网络选择器安装脚本
# 使用方法: ./install.sh

set -e

echo "=== 网络选择器安装脚本 ==="
echo

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "错误: 此脚本需要root权限"
    echo "请使用: sudo ./install.sh"
    exit 1
fi

# 检查系统要求
echo "1. 检查系统要求..."

# 检查是否为Linux系统
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "错误: 此工具仅支持Linux系统"
    exit 1
fi

# 检查g++编译器
if ! command -v g++ &> /dev/null; then
    echo "错误: 未找到g++编译器"
    echo "请安装g++: sudo apt-get install g++"
    exit 1
fi

# 检查iproute2
if ! command -v ip &> /dev/null; then
    echo "错误: 未找到iproute2工具"
    echo "请安装iproute2: sudo apt-get install iproute2"
    exit 1
fi

echo "系统要求检查通过！"
echo

# 编译程序
echo "2. 编译程序..."
make clean
make
if [ $? -ne 0 ]; then
    echo "编译失败！"
    exit 1
fi
echo "编译成功！"
echo

# 安装程序
echo "3. 安装程序..."
make install
if [ $? -ne 0 ]; then
    echo "安装失败！"
    exit 1
fi
echo "安装成功！"
echo



# 创建man页面
echo "4. 创建man页面..."
MAN_DIR="/usr/local/share/man/man1"
mkdir -p "$MAN_DIR"

cat > "$MAN_DIR/network_selector.1" << 'EOF'
.TH NETWORK_SELECTOR 1 "2024" "Network Selector" "User Commands"
.SH NAME
network_selector \- Select network interface for specific programs
.SH SYNOPSIS
.B network_selector
[\fB\-i\fR \fIinterface\fR] [\fB\-l\fR] [\fB\-h\fR] \fIprogram\fR [\fIargs\fR...]
.SH DESCRIPTION
Network Selector is a tool that allows you to run programs with specific network interfaces using Linux network namespaces.
.SH OPTIONS
.TP
.BR \-i ", " \-\-interface " " \fIinterface\fR
Specify the network interface to use
.TP
.BR \-l ", " \-\-list
List all available network interfaces
.TP
.BR \-h ", " \-\-help
Show help message
.SH EXAMPLES
.TP
Run curl with WiFi interface:
.B network_selector -i wlan0 curl http://example.com
.TP
Run ping with Ethernet interface:
.B network_selector -i eth0 ping google.com
.TP
List available interfaces:
.B network_selector -l
.SH FILES
.TP
.I /etc/network_selector.conf
Configuration file
.SH AUTHOR
Network Selector Team
.SH BUGS
Report bugs to: https://github.com/your-repo/issues
EOF

# 更新man数据库
if command -v mandb &> /dev/null; then
    mandb "$MAN_DIR" > /dev/null 2>&1
fi

echo "man页面已创建"
echo

# 创建桌面快捷方式
echo "6. 创建桌面快捷方式..."
DESKTOP_DIR="/usr/share/applications"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/network-selector.desktop" << 'EOF'
[Desktop Entry]
Name=Network Selector
Comment=Select network interface for programs
Exec=network_selector
Icon=network-wireless
Terminal=true
Type=Application
Categories=Network;System;
Keywords=network;interface;wifi;ethernet;
EOF

echo "桌面快捷方式已创建"
echo

# 设置权限
echo "7. 设置权限..."
chmod 755 /usr/local/bin/network_selector
chmod 644 /etc/network_selector.conf
chmod 644 "$MAN_DIR/network_selector.1"
chmod 644 "$DESKTOP_DIR/network-selector.desktop"

echo "权限设置完成"
echo

# 运行测试
echo "8. 运行基本测试..."
if ./test.sh > /dev/null 2>&1; then
    echo "基本测试通过！"
else
    echo "基本测试失败，但安装已完成"
fi
echo

echo "=== 安装完成 ==="
echo
echo "网络选择器已成功安装到系统中！"
echo
echo "使用方法:"
echo "  network_selector -i wlan0 curl http://example.com"
echo "  network_selector -i eth0 ping google.com"
echo "  network_selector -l"
echo
echo "配置文件: /etc/network_selector.conf"
echo "man页面: man network_selector"
echo
echo "如需卸载，请运行: sudo make uninstall"
echo 