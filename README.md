# 网络选择器 (Network Selector)

这是一个用于在Ubuntu系统中为指定程序选择使用无线网还是有线网的工具。该工具使用C++开发，利用Linux网络命名空间技术实现网络接口的隔离和选择。

## 项目概述

为Ubuntu系统开发的网络接口选择工具，使用C++和Linux网络命名空间技术。支持为指定程序分配特定的网络接口，使用Linux网络命名空间技术，确保网络隔离。

## 功能特性

- 支持为指定程序分配特定的网络接口
- 使用Linux网络命名空间技术，确保网络隔离
- 支持无线网和有线网的切换
- 自动管理网络接口的配置
- 提供网络接口列表和状态查看功能

## 系统要求

- Ubuntu Linux (或其他支持ip netns的Linux发行版)
- root权限或sudo权限
- g++编译器
- iproute2工具包

## 编译安装

### 1. 编译程序

```bash
make
```

### 2. 安装到系统

```bash
sudo make install
```

### 3. 卸载

```bash
sudo make uninstall
```

## 使用方法

### 基本语法

```bash
network_selector [OPTIONS] <PROGRAM> [ARGS...]
```

### 选项说明

- `-i, --interface <name>`: 指定要使用的网络接口
- `-l, --list`: 列出所有可用的网络接口
- `-h, --help`: 显示帮助信息

### 使用示例

#### 1. 查看可用的网络接口

```bash
./network_selector -l
```

#### 2. 使用WiFi接口运行curl命令

```bash
./network_selector -i wlan0 curl http://example.com
```

#### 3. 使用有线网接口运行ping命令

```bash
./network_selector -i eth0 ping google.com
```

#### 4. 使用WiFi接口运行浏览器

```bash
./network_selector -i wlan0 firefox
```

#### 5. 使用有线网接口运行下载工具

```bash
./network_selector -i eth0 wget http://example.com/file.zip
```

## 工作原理

该工具使用Linux的网络命名空间技术来实现网络接口的隔离：

1. **创建命名空间**: 为每个程序创建独立的网络命名空间
2. **移动接口**: 将指定的网络接口移动到命名空间中
3. **配置网络**: 在命名空间中配置网络接口和路由
4. **运行程序**: 在命名空间中运行指定的程序
5. **清理资源**: 程序结束后自动清理命名空间

## 注意事项

1. **权限要求**: 该工具需要root权限或sudo权限来操作网络接口
2. **接口可用性**: 确保指定的网络接口存在且可用
3. **程序兼容性**: 某些程序可能不支持在命名空间中运行
4. **网络配置**: 工具会自动配置网络，但可能需要手动调整某些设置

## 故障排除

### 常见问题

1. **权限错误**
   ```bash
   Error: Failed to create network namespace
   ```
   解决方案: 使用sudo运行程序

2. **接口不存在**
   ```bash
   Error: Failed to move interface to namespace
   ```
   解决方案: 检查接口名称是否正确，使用`-l`选项查看可用接口

3. **网络配置失败**
   ```bash
   Error: Failed to configure interface in namespace
   ```
   解决方案: 检查网络接口是否已正确配置IP地址和网关

### 调试方法

1. 查看网络接口状态:
   ```bash
   ip addr show
   ```

2. 查看路由表:
   ```bash
   ip route show
   ```

3. 查看命名空间:
   ```bash
   ip netns list
   ```

## 开发说明

### 文件结构

- `simple_network_selector.cpp`: 主程序源代码
- `Makefile`: 编译配置文件
- `README.md`: 说明文档

### 编译选项

- `-std=c++11`: 使用C++11标准
- `-Wall -Wextra`: 启用警告信息
- `-O2`: 优化编译

### 扩展功能

可以考虑添加的功能：

1. 支持多个网络接口的负载均衡
2. 网络流量监控和统计
3. 配置文件支持
4. GUI界面
5. 网络质量检测

## 许可证

本项目采用MIT许可证，详见LICENSE文件。

## 贡献

欢迎提交Issue和Pull Request来改进这个工具。

## 联系方式

如有问题或建议，请通过GitHub Issues联系。 