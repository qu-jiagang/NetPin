CC = g++
CFLAGS = -std=c++11 -Wall -Wextra -O2
TARGET = network_selector
SOURCES = simple_network_selector.cpp
OBJECTS = $(SOURCES:.cpp=.o)

# 默认目标
all: $(TARGET)

# 编译目标程序
$(TARGET): $(OBJECTS)
	$(CC) $(OBJECTS) -o $(TARGET)

# 编译源文件
%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

# 清理编译文件
clean:
	rm -f $(OBJECTS) $(TARGET)

# 安装到系统
install: $(TARGET)
	sudo cp $(TARGET) /usr/local/bin/
	sudo chmod +x /usr/local/bin/$(TARGET)

# 卸载
uninstall:
	sudo rm -f /usr/local/bin/$(TARGET)

# 运行测试
test: $(TARGET)
	@echo "Testing network interface listing..."
	./$(TARGET) -l
	@echo ""
	@echo "Showing help..."
	./$(TARGET) -h

# 显示帮助
help:
	@echo "Available targets:"
	@echo "  all       - Build the network selector tool"
	@echo "  clean     - Remove build files"
	@echo "  install   - Install to /usr/local/bin"
	@echo "  uninstall - Remove from /usr/local/bin"
	@echo "  test      - Run basic tests"
	@echo "  help      - Show this help"

.PHONY: all clean install uninstall test help 