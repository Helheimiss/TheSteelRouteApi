cmake_minimum_required(VERSION 4.1)
project(TheSteelRouteApi VERSION 0.1.0)

if (WIN32)
    set(CMAKE_PREFIX_PATH "C:/msys64/mingw64${CMAKE_PREFIX_PATH}")
endif ()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#set(CMAKE_CXX_COMPILE_FEATURES OFF)

set(BUILD_CTL OFF)
set(BUILD_EXAMPLES OFF)
set(JWT_BUILD_EXAMPLES OFF)

find_package(Qt6 REQUIRED COMPONENTS Core Sql)
add_subdirectory(libs/drogon)
add_subdirectory(libs/jwt-cpp)


add_executable(${PROJECT_NAME}
        src/main.cpp
        src/Database.cpp
        src/api.cpp
)
target_include_directories(${PROJECT_NAME} PRIVATE include)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Sql drogon jwt-cpp::jwt-cpp)