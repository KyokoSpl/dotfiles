cmake_minimum_required(VERSION 3.16)
project(mango-cheatsheet LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK4 REQUIRED gtk4)

add_executable(mango-cheatsheet src/main.cpp)

target_include_directories(mango-cheatsheet PRIVATE ${GTK4_INCLUDE_DIRS})
target_link_directories(mango-cheatsheet PRIVATE ${GTK4_LIBRARY_DIRS})
target_link_libraries(mango-cheatsheet PRIVATE ${GTK4_LIBRARIES})
target_compile_options(mango-cheatsheet PRIVATE ${GTK4_CFLAGS_OTHER})

# Copy styles directory next to binary after build
add_custom_command(TARGET mango-cheatsheet POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/styles
        ${CMAKE_BINARY_DIR}/styles
    COMMENT "Copying styles to build directory"
)

# Install targets
install(TARGETS mango-cheatsheet DESTINATION bin)
install(DIRECTORY styles/ DESTINATION share/mango-cheatsheet/styles)
