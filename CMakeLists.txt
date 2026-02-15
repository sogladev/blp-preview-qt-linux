cmake_minimum_required(VERSION 3.16)
project(blp-imageformat-plugin)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui)

add_library(blp MODULE
    src/blpplugin.cpp
    src/blpplugin.h
    src/blphandler.cpp
    src/blphandler.h
)

target_link_libraries(blp PRIVATE Qt6::Core Qt6::Gui)

