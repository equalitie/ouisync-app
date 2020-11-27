cmake_minimum_required(VERSION 3.4.1)

set(APP_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})

set (NATIVE_DIR ${APP_ROOT_DIR}/ios/Classes)
set (CALLBACK_MANAGER_DIR ${APP_ROOT_DIR}/ios/Classes/Shared)

add_library( native_add

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ${CALLBACK_MANAGER_DIR}/CallBackManager.h
             ${CALLBACK_MANAGER_DIR}/CallBackManager.cpp
             ${NATIVE_DIR}/native_add.h
             ${NATIVE_DIR}/native_add.cpp)

target_include_directories(native_add PUBLIC ${CALLBACK_MANAGER_DIR})
target_include_directories(native_add PUBLIC ${NATIVE_DIR})

target_link_libraries(native_add ${native_add})