cmake_minimum_required(VERSION 3.17)

project(cpp-multiarch)

#---------------------------------------------------------------------------------------
# compiler config
#---------------------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if("${CMAKE_CXX_COMPILER_ID}" STREQUAL "GNU" OR "${CMAKE_CXX_COMPILER_ID}" MATCHES "Clang")
    add_compile_options("-Wall")
    add_compile_options("-Wextra")
    add_compile_options("-Wconversion")
    add_compile_options("-pedantic")
    add_compile_options("-Wfatal-errors")
    
endif()

# fmt library dependency
find_package(fmt CONFIG REQUIRED)

# spdlog library dependency
find_package(spdlog CONFIG REQUIRED)

# yaml-cpp library dependency
find_package(yaml-cpp 0.6.2 REQUIRED)

# Threads
find_package(Threads)

message("Building cpp-app for ${CMAKE_SYSTEM_PROCESSOR}")

# Build the bin path for the install target by mapping CMAKE_SYSTEM_PROCESSOR
# (x86_64 or aarch64) to the docker builx TARGETPLATFORM (linux/amd64 or
# linux/arm64)
if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "x86_64")
    set(BIN_PATH "linux/amd64")
elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64")
    set(BIN_PATH "linux/arm64")
endif()

add_subdirectory(src)