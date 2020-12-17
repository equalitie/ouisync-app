cmake_minimum_required(VERSION 3.16.0)

set(APP_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR})

set (NATIVE_DIR ${APP_ROOT_DIR}/ios/ouisync/src)
set (OUISYNC_CMAKE_DIR ${APP_ROOT_DIR}/ios/ouisync/)
set (CALLBACK_MANAGER_DIR ${APP_ROOT_DIR}/ios/Classes/Shared)

<<<<<<< HEAD


if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcoroutines-ts -stdlib=libc++ -std=c++17")
else()
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fcoroutines -std=c++2a -DBOOST_ASIO_HAS_STD_COROUTINE")
endif()

add_library( libouisync_app

             SHARED

             ${CALLBACK_MANAGER_DIR}/CallbackManager.h
             ${CALLBACK_MANAGER_DIR}/CallbackManager.cpp

             ${NATIVE_DIR}/branch_io.cpp
             ${NATIVE_DIR}/client.cpp
             ${NATIVE_DIR}/commit.cpp
             ${NATIVE_DIR}/file.cpp
             ${NATIVE_DIR}/file_locker.cpp
             ${NATIVE_DIR}/file_system_attrib.cpp
             ${NATIVE_DIR}/hash.cpp
             ${NATIVE_DIR}/local_branch.cpp
             ${NATIVE_DIR}/message.cpp
             ${NATIVE_DIR}/message_broker.cpp
             ${NATIVE_DIR}/network.cpp
             ${NATIVE_DIR}/object_id.cpp
             ${NATIVE_DIR}/options.cpp
             ${NATIVE_DIR}/random.cpp
             ${NATIVE_DIR}/refcount.cpp
             ${NATIVE_DIR}/remote_branch.cpp
             ${NATIVE_DIR}/repository.cpp
             ${NATIVE_DIR}/server.cpp
             ${NATIVE_DIR}/snapshot.cpp
             ${NATIVE_DIR}/user_id.cpp
             ${NATIVE_DIR}/object/blob.cpp
             ${NATIVE_DIR}/object/io.cpp
             ${NATIVE_DIR}/object/path.cpp
             ${NATIVE_DIR}/object/tag.cpp
             ${NATIVE_DIR}/object/tagged.cpp
             ${NATIVE_DIR}/object/tree.cpp)

target_include_directories(libouisync_app PUBLIC ${CALLBACK_MANAGER_DIR})
target_include_directories(libouisync_app PUBLIC ${NATIVE_DIR})

target_link_libraries(libouisync_app PUBLIC libouisync)

add_subdirectory(${OUISYNC_CMAKE_DIR} bin-dir)


add_link_options("LINKER:-v")
=======
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
>>>>>>> 3e220f9138d3d1e46843a2a63fc090d44048f9ab
