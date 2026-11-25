cmake_minimum_required(VERSION 3.16)
project(AngryGL LANGUAGES C CXX)

# ---------------------------------------------------------------------------
# General settings
# ---------------------------------------------------------------------------
# premake did not set a standard; GLM/assimp need at least C++11, 17 is safe.
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Single-config generators (Makefiles/Ninja): default to Debug like premake's
# first configuration.
if(NOT CMAKE_CONFIGURATION_TYPES AND NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
endif()
set(CMAKE_CONFIGURATION_TYPES "Debug;Release" CACHE STRING "" FORCE)

set(ASSETS_DIR ${CMAKE_SOURCE_DIR}/assets)

# ---------------------------------------------------------------------------
# Third-party libraries (replaces the assimplib/sdllib/sdlmixerlib Makefile
# projects and their hand-written cmake invocations)
# ---------------------------------------------------------------------------
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)

# --- SDL2 ---
set(SDL_SHARED         OFF CACHE BOOL "" FORCE)
set(SDL_STATIC         ON  CACHE BOOL "" FORCE)
set(SDL_TEST           OFF CACHE BOOL "" FORCE)
set(SDL_TESTS          OFF CACHE BOOL "" FORCE)
set(SDL_TESTS_BUILD    OFF CACHE BOOL "" FORCE)
set(SDL_TESTS_INSTALL  OFF CACHE BOOL "" FORCE)
set(SDL_EXAMPLES       OFF CACHE BOOL "" FORCE)
add_subdirectory(thirdparty/sdl EXCLUDE_FROM_ALL)

# --- SDL2_mixer ---
set(SDL2MIXER_VENDORED  ON  CACHE BOOL "" FORCE)
set(SDL2MIXER_TESTS     OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_EXAMPLES  OFF CACHE BOOL "" FORCE)
set(SDLMIXER_TESTS      OFF CACHE BOOL "" FORCE)
set(SDLMIXER_EXAMPLES   OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_OPUS      OFF CACHE BOOL "" FORCE)
set(SDLMIXER_OPUS       OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_MOD       OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_MOD_XMP   OFF CACHE BOOL "" FORCE)
set(SDL2MIXER_INSTALL   OFF CACHE BOOL "" FORCE)
add_subdirectory(thirdparty/sdl_mixer EXCLUDE_FROM_ALL)

# --- assimp ---
set(ASSIMP_BUILD_ZLIB          ON  CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_TESTS         OFF CACHE BOOL "" FORCE)
set(ASSIMP_BUILD_ASSIMP_TOOLS  OFF CACHE BOOL "" FORCE)
set(ASSIMP_INSTALL             OFF CACHE BOOL "" FORCE)
add_subdirectory(thirdparty/assimp EXCLUDE_FROM_ALL)

# Resolve target names, which differ slightly between SDL/SDL_mixer versions.
if(TARGET SDL2::SDL2-static)
  set(ANGRYGL_SDL_TARGET SDL2::SDL2-static)
else()
  set(ANGRYGL_SDL_TARGET SDL2-static)
endif()

if(TARGET SDL2_mixer::SDL2_mixer-static)
  set(ANGRYGL_MIXER_TARGET SDL2_mixer::SDL2_mixer-static)
elseif(TARGET SDL2_mixer::SDL2_mixer)
  set(ANGRYGL_MIXER_TARGET SDL2_mixer::SDL2_mixer)
else()
  set(ANGRYGL_MIXER_TARGET SDL2_mixer)
endif()

# ---------------------------------------------------------------------------
# AngryGL
# ---------------------------------------------------------------------------
set(SRC_EXTS h hh hpp hxx c cc cpp cxx frag vert)
set(SRC_GLOBS "")
foreach(dir angrygl glad stb opengl)
  foreach(ext ${SRC_EXTS})
    list(APPEND SRC_GLOBS "${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.${ext}")
  endforeach()
endforeach()

file(GLOB_RECURSE ANGRYGL_SOURCES CONFIGURE_DEPENDS ${SRC_GLOBS})

# WindowedApp -> WIN32 subsystem on Windows, plain executable elsewhere
add_executable(AngryGL ${ANGRYGL_SOURCES})

# Shaders are listed in the IDE project but are not compiled
set_source_files_properties(${ANGRYGL_SOURCES} PROPERTIES HEADER_FILE_ONLY OFF)
foreach(shader_ext frag vert)
  file(GLOB_RECURSE _shaders CONFIGURE_DEPENDS
       "${CMAKE_CURRENT_SOURCE_DIR}/angrygl/*.${shader_ext}")
  set_source_files_properties(${_shaders} PROPERTIES HEADER_FILE_ONLY ON)
endforeach()

if(WIN32)
  set_target_properties(AngryGL PROPERTIES WIN32_EXECUTABLE ON)
endif()

# targetdir "bin/" (the $<0:> trick stops multi-config generators from
# appending a Debug/Release subfolder)
# set_target_properties(AngryGL PROPERTIES
#   RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin/$<0:>")

target_include_directories(AngryGL PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/glad/include
  ${CMAKE_CURRENT_SOURCE_DIR}/stb
  ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/stb
  ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/glm
  ${CMAKE_CURRENT_SOURCE_DIR}/include
)

target_compile_definitions(AngryGL PRIVATE
  GLM_ENABLE_EXPERIMENTAL
  $<$<CONFIG:Debug>:DEBUG>
  $<$<NOT:$<CONFIG:Debug>>:NDEBUG>
)

# Platform defines (WIN32 / WIN64 / LINUX)
if(WIN32)
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    target_compile_definitions(AngryGL PRIVATE WIN64)
  else()
    target_compile_definitions(AngryGL PRIVATE WIN32)
  endif()
elseif(UNIX AND NOT APPLE)
  target_compile_definitions(AngryGL PRIVATE LINUX)
endif()

# Debug symbols / optimisation (premake: symbols "On" / optimize "On")
if(MSVC)
  target_compile_options(AngryGL PRIVATE
    $<$<CONFIG:Debug>:/Zi>
    $<$<CONFIG:Release>:/O2>)
else()
  target_compile_options(AngryGL PRIVATE
    $<$<CONFIG:Debug>:-g>
    $<$<CONFIG:Release>:-O2>)
endif()

# Libraries. Include directories and transitive system libs (zlib, etc.)
# come along with the imported/subproject targets.
find_package(Threads REQUIRED)

target_link_libraries(AngryGL PRIVATE
  ${ANGRYGL_MIXER_TARGET}
  ${ANGRYGL_SDL_TARGET}
  assimp::assimp
)

if(UNIX AND NOT APPLE)
  target_link_libraries(AngryGL PRIVATE m ${CMAKE_DL_LIBS} Threads::Threads)
endif()

# Make sure the third-party targets are always built before the app
add_dependencies(AngryGL assimp)

message(STATUS "copying assets to build dir")
file(COPY ${ASSETS_DIR}
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR})