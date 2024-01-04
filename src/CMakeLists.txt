cmake_minimum_required(VERSION 3.17)

project (cpp-app)

include_directories(
    ${YAML_CPP_INCLUDE_DIR}
)

add_executable(cpp-app main.cpp)
target_link_libraries( cpp-app Threads::Threads yaml-cpp::yaml-cpp )

install(TARGETS cpp-app DESTINATION stage/bin/${BIN_PATH})
