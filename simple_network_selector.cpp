#include <iostream>
#include <string>
#include <vector>
#include <cstdlib>
#include <unistd.h>

class NetworkSelector {
private:
    std::string namespace_name;
    
public:
    NetworkSelector() {
        namespace_name = "net_sel_" + std::to_string(getpid());
    }
    
    ~NetworkSelector() {
        system(("ip netns del " + namespace_name).c_str());
    }
    
    bool runWithInterface(const std::string& interface, const std::string& program, const std::vector<std::string>& args) {
        std::cout << "Setting up " << interface << " network for program: " << program << std::endl;
        
        // 创建命名空间
        if (system(("ip netns add " + namespace_name).c_str()) != 0) {
            std::cerr << "Failed to create network namespace" << std::endl;
            return false;
        }
        
        // 将接口移动到命名空间
        if (system(("ip link set " + interface + " netns " + namespace_name).c_str()) != 0) {
            std::cerr << "Failed to move interface to namespace" << std::endl;
            return false;
        }
        
        // 配置接口
        if (system(("ip netns exec " + namespace_name + " ip link set " + interface + " up").c_str()) != 0) {
            std::cerr << "Failed to bring up interface" << std::endl;
            return false;
        }
        
        // 运行程序
        std::string cmd = "ip netns exec " + namespace_name + " " + program;
        for (const auto& arg : args) {
            cmd += " " + arg;
        }
        
        std::cout << "Running: " << cmd << std::endl;
        return system(cmd.c_str()) == 0;
    }
    
    static void listInterfaces() {
        std::cout << "Available network interfaces:" << std::endl;
        system("ip link show | grep -E '^[0-9]+:' | awk '{print $2}' | sed 's/://'");
    }
};

void printUsage(const char* program) {
    std::cout << "Usage: " << program << " [OPTIONS] <PROGRAM> [ARGS...]" << std::endl;
    std::cout << "Options:" << std::endl;
    std::cout << "  -i, --interface <name>     Use specified network interface" << std::endl;
    std::cout << "  -l, --list                 List available interfaces" << std::endl;
    std::cout << "  -h, --help                 Show this help message" << std::endl;
    std::cout << std::endl;
    std::cout << "Examples:" << std::endl;
    std::cout << "  " << program << " -i wlan0 curl http://example.com" << std::endl;
    std::cout << "  " << program << " -i eth0 ping google.com" << std::endl;
    std::cout << "  " << program << " -l" << std::endl;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        printUsage(argv[0]);
        return 1;
    }
    
    std::string interface = "";
    std::string target_program = "";
    std::vector<std::string> program_args;
    
    // 解析命令行参数
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        
        if (arg == "-i" || arg == "--interface") {
            if (i + 1 < argc) {
                interface = argv[++i];
            } else {
                std::cerr << "Error: Interface name required" << std::endl;
                return 1;
            }
        } else if (arg == "-l" || arg == "--list") {
            NetworkSelector::listInterfaces();
            return 0;
        } else if (arg == "-h" || arg == "--help") {
            printUsage(argv[0]);
            return 0;
        } else {
            if (target_program.empty()) {
                target_program = arg;
            } else {
                program_args.push_back(arg);
            }
        }
    }
    
    if (interface.empty()) {
        std::cerr << "Error: Must specify interface (-i)" << std::endl;
        printUsage(argv[0]);
        return 1;
    }
    
    if (target_program.empty()) {
        std::cerr << "Error: No program specified to run" << std::endl;
        printUsage(argv[0]);
        return 1;
    }
    
    NetworkSelector selector;
    bool success = selector.runWithInterface(interface, target_program, program_args);
    
    return success ? 0 : 1;
} 