-- author(s):Victor D.Montero(victordmontero)
-- premake5.lua
-- stylua: ignore start
workspace "AngryGL"
   configurations { "Debug", "Release" }
   platforms { "Win32", "Win64", "Linux" }
   location "proj_%{_ACTION}"

project "AngryGL"
   kind "WindowedApp"
   language "C++"
   targetdir "bin/%{cfg.buildcfg}"
   objdir "obj"
 
   dependson {
		"assimplib",
		"sdllib",
		"sdlmixerlib"
	}
 
   files ({
	 "angrygl/**.h*",
	 "angrygl/**.c*",
	 "angrygl/**.frag",
	 "angrygl/**.vert",
	 "glad/**.h*",
	 "glad/**.c*",
	 "stb/**.h*",
	 "stb/**.c*",
	 "opengl/**.h*",
	 "opengl/**.c*",
	 "**.lua"
   })
   
   includedirs({
		  "glad/include",
		  "stb",
		  "thirdparty/sdl/include",
		  "thirdparty/sdl_mixer/include",
	      "./"
	})
	
	-- libdirs{
	-- 	"assimp/lib",
	-- 	"glfw/lib-vc2012"
	-- }
	
	-- links{
	-- 	"assimp-vc140-mt",
	-- 	"glfw3dll"
	-- }
	
	defines
	{
		"GLM_ENABLE_EXPERIMENTAL"
	}

  filter "configurations:Debug"
    defines { "DEBUG" }
    symbols "On"

  filter "configurations:Release"
    defines { "NDEBUG" }
    optimize "On"

  filter  "platforms:Win32"
    defines{"WIN32"}
    system "windows"
    architecture "x32"
	
	libdirs({
		-- "thirdparty/wxWidgets/lib/vc_lib"
	})

  filter  "platforms:Win64"
    defines{"WIN64"}
    system "windows"
    architecture "x64"
	
	libdirs({
		"thirdparty/sdl/lib-mingw-w64"
	})
	
	links{
		"libSDL2",
		"libSDL2_mixer",
		"libassimp"
	}

  filter  "platforms:Linux"
    defines{"LINUX"}
    system "linux"

	includedirs({
		"include",
		"thirdparty/sdl/include",
		"thirdparty/sdl_mixer/include",
		"thirdparty/assimp/include",
		"thirdparty/assimp/out/include",
		"thirdparty/stb",
		"thirdparty/glm",
	})

	libdirs {
		"thirdparty/sdl/out",
		"thirdparty/sdl_mixer/out",
		"thirdparty/assimp/out/lib",
		"thirdparty/assimp/out/contrib/zlib",
	}

  filter { "platforms:Linux", "configurations:Debug" }
	links { "SDL2_mixerd", "SDL2d", "assimp", "zlibstatic", "m", "dl", "pthread" }

  filter { "platforms:Linux", "configurations:Release" }
	links { "SDL2_mixer", "SDL2", "assimp", "zlibstatic", "m", "dl", "pthread" }

project "assimplib"
	kind "Makefile"
	objdir()
	
	location("thirdparty/assimp/")
	includedirs{"./include"}
	targetname "assimp"

	cmake_opt = " -DASSIMP_BUILD_ZLIB=ON -DBUILD_SHARED_LIBS=OFF -DASSIMP_BUILD_TESTS=OFF "
 
	cleancommands {
		"{RMDIR} %{prj.location}/build/"
	}
	
	buildcommands {
	        "cmake -DCMAKE_BUILD_TYPE=%{cfg.buildcfg}" .. cmake_opt .. "%{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config %{cfg.buildcfg}"
	}
	
	rebuildcommands {
		"{RMDIR} %{prj.location}/out/",
	        "cmake -DCMAKE_BUILD_TYPE=%{cfg.buildcfg}" .. cmake_opt .. "%{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config %{cfg.buildcfg}"
	}

	filter "configurations:Debug"
		 targetdir "%{prj.location}/out"
	filter "configurations:Release"
		 targetdir "%{prj.location}/out"

project "sdllib"
	kind "Makefile"
	objdir()
	
	location("thirdparty/sdl/")
	includedirs{"./include"}
	targetname "sdllib"

	-- sdllib
	cmake_opt = " -DBUILD_SHARED_LIBS=OFF -DSDL_TEST=OFF -DSDL_TESTS=OFF -DSDL_TESTS_BUILD=OFF -DSDL_TESTS_INSTALL=OFF -DSDL_EXAMPLES=OFF "

 
	cleancommands {
		"{RMDIR} %{prj.location}/build/"
	}
	
	buildcommands {
	        "cmake -DCMAKE_BUILD_TYPE=%{cfg.buildcfg}" .. cmake_opt .. "%{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config %{cfg.buildcfg}"
	}
	
	rebuildcommands {
		"{RMDIR} %{prj.location}/out/",
	        "cmake -DCMAKE_BUILD_TYPE=%{cfg.buildcfg}" .. cmake_opt .. "%{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config %{cfg.buildcfg}"
	}

	filter "configurations:Debug"
		 targetdir "%{prj.location}/out"
	filter "configurations:Release"
		 targetdir "%{prj.location}/out"

project "sdlmixerlib"
	kind "Makefile"
	objdir()
	
	location("thirdparty/sdl_mixer/")
	includedirs{"./include"}
	targetname "sdlmixerlib"

	-- sdlmixerlib
	cmake_opt = " -DBUILD_SHARED_LIBS=OFF -DSDL2MIXER_TESTS=OFF -DSDL2MIXER_EXAMPLES=OFF -DSDLMIXER_TESTS=OFF -DSDLMIXER_EXAMPLES=OFF -DSDL2MIXER_OPUS=OFF -DSDLMIXER_OPUS=OFF -DSDL2MIXER_MOD_XMP=OFF -DSDL2MIXER_MOD=OFF "

 
	cleancommands {
		"{RMDIR} %{prj.location}/build/"
	}
	
	buildcommands {
	        "cmake -DCMAKE_BUILD_TYPE=%{cfg.buildcfg}" .. cmake_opt .. "%{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config %{cfg.buildcfg}"
	}
	
	rebuildcommands {
		"{RMDIR} %{prj.location}/out/",
	        "cmake -DCMAKE_BUILD_TYPE=%{cfg.buildcfg}" .. cmake_opt .. "%{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config %{cfg.buildcfg}"
	}

	filter "configurations:Debug"
		 targetdir "%{prj.location}/out"
	filter "configurations:Release"
		 targetdir "%{prj.location}/out"
-- stylua: ignore end
