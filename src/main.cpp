#include "yaml-cpp/yaml.h"
#include <atomic>
#include <fmt/core.h>
#include <fstream>
#include <iostream>
#include <signal.h>
#include <spdlog/sinks/stdout_sinks.h>
#include <spdlog/spdlog.h>
#include <unistd.h>

static std::atomic_bool running = true;

void sig_handler(int)
{
    std::cout << "Shutting down container\n";
    running = false;
}

void usage()
{
    std::cerr << "Usage:\n"
              << "cpp-app [-n <name>][-f <configFile>][-l <logLevel>]\n";
}

int main(int argc, char **argv)
{
    int logLevel = spdlog::level::info;
    std::string configFile = "cpp-app.yaml";
    std::string name = "cpp-app";
    std::vector<std::string> pubEndpoints;
    std::string subEndpoint = "tcp://localhost:9210";
    int c;

    ::signal(SIGINT, &sig_handler);
    ::signal(SIGTERM, &sig_handler);

    while ((c = getopt(argc, argv, "f:n:l:p:s:P:S:h:m:i?")) != EOF)
    {
        switch (c)
        {
        case 'f':
            configFile = optarg;
            break;
        case 'n':
            name = optarg;
            break;
        case 'l':
            logLevel = std::stoi(optarg);
            break;
        case '?':
        default:
            usage();
            exit(1);
        }
    }
    auto logger = spdlog::stdout_logger_mt("cpp-app");
    // Log format:
    // 2018-10-08 21:08:31.633|020288|I|Thread Worker thread 3 doing something
    logger->set_pattern("%Y-%m-%d %H:%M:%S.%e|%t|%L|%v");

    std::ifstream ifs(configFile);
    if (ifs.good())
    {
        std::stringstream stream;
        stream << ifs.rdbuf();
        try
        {
            YAML::Node m_yaml = YAML::Load(stream.str());
            if (m_yaml["log-level"])
            {
                logLevel = m_yaml["log-level"].as<int>();
            }
            if (m_yaml["name"])
            {
                name = m_yaml["name"].as<std::string>();
            }
        }
        catch (...)
        {
            logger->error("Error parsing config file");
        }
    }

    name = fmt::format("{}-1", name);
    // Formulate uuid incorporating instance number

    // Update logging pattern to reflect the service name
    auto pattern = fmt::format("%Y-%m-%d %H:%M:%S.%e|{}|%t|%L|%v", name);
    logger->set_pattern(pattern);
    // Set the log level for filtering
    spdlog::set_level(static_cast<spdlog::level::level_enum>(logLevel));

    logger->info("cpp-app starting up");

    while (running.load())
    {

        std::this_thread::sleep_for(std::chrono::milliseconds(500));
    }

    logger->info("cpp-app stopping");
}