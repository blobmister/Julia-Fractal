cmake_minimum_required(VERSION 3.23)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(Julia)

add_executable(main main.cxx)

add_library(head INTERFACE)

target_include_directories(head
    INTERFACE
        ${CMAKE_CURRENT_SOURCE_DIR}
)


target_sources(head
    INTERFACE
        FILE_SET HEADERS
        FILES
            complex.h
)

target_link_libraries(main
    PRIVATE
        head
)
