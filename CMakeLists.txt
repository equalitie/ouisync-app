cmake_minimum_required(VERSION 3.16.0)

set(APP_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})

set (NATIVE_DIR ${APP_ROOT_DIR}/ios/ouisync/src)
set (CALLBACK_MANAGER_DIR ${APP_ROOT_DIR}/ios/Classes/Shared)
set (SOURCE_DIR ${APP_ROOT_DIR}/ios/Classes)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcoroutines-ts -stdlib=libc++ -std=c++17")

add_subdirectory(
    ${CMAKE_CURRENT_SOURCE_DIR}/ios/ouisync
)

add_library( nativeapp
     SHARED
     ${CALLBACK_MANAGER_DIR}/CallbackManager.h
     ${CALLBACK_MANAGER_DIR}/CallbackManager.cpp
)

target_include_directories(nativeapp PUBLIC ${CALLBACK_MANAGER_DIR} ${NATIVE_DIR})
target_link_libraries(nativeapp PUBLIC libouisync)