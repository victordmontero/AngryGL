-- author(s):Victor D.Montero(victordmontero)
-- premake5.lua
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
		"glfwlib"
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
	    --   "assimp/include",
		  "glad/include",
		--   "glfw",
		  "stb",
		--   "glm",
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
		-- "SD_ENABLE_IRRKLANG"
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
		"glfw/lib-mingw-w64"
	})
	
	links{
		"libglfw3",
		"libassimp"
	}

  filter  "platforms:Linux"
    defines{"LINUX"}
    system "linux"

	includedirs({
		"include",
		"thirdparty/glfw/include",
		"thirdparty/assimp/include",
		"thirdparty/assimp/out/include",
		"thirdparty/stb",
		"thirdparty/glm",
	})

	libdirs {
		"thirdparty/glfw/out/src",
		"thirdparty/assimp/out/bin"
	}
	
	links{
		"glfw3",
		"assimp"
	}

project "assimplib"
	kind "Makefile"
	objdir()
	
	location("thirdparty/assimp/")
	includedirs{"./include"}
	targetname "assimp"
 
	cleancommands {
		"{RMDIR} %{prj.location}/build/"
	}
	
	filter "configurations:Debug"
		 targetdir "%{prj.location}/out"
	
	buildcommands {
	   "cmake %{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir}"
	}
	
	rebuildcommands {
		"{RMDIR} %{prj.location}/out/",
		"cmake %{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir}"
	}
	
	filter "configurations:Release"
		 targetdir "%{prj.location}/out"
	
	buildcommands {
		"cmake -DCMAKE_BUILD_TYPE=Release %{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config Release"
	}
	
	rebuildcommands {
		"{RMDIR} %{prj.location}/out/",
		"cmake -DCMAKE_BUILD_TYPE=Release %{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config Release"
	}

project "glfwlib"
	kind "Makefile"
	objdir()
	
	location("thirdparty/glfw/")
	includedirs{"./include"}
	targetname "glfw"
 
	cleancommands {
		"{RMDIR} %{prj.location}/out/"
	}
	
	filter "configurations:Debug"
		 targetdir "%{prj.location}/out"
	
	buildcommands {
	   "cmake %{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir}"
	}
	
	rebuildcommands {
		"{RMDIR} %{prj.location}/out/",
		"cmake %{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir}"
	}
	
	filter "configurations:Release"
		 targetdir "%{prj.location}/out"
	
	buildcommands {
		"cmake -DCMAKE_BUILD_TYPE=Release %{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config Release"
	}
	
	rebuildcommands {
		"{RMDIR} %{prj.location}/out/",
		"cmake -DCMAKE_BUILD_TYPE=Release %{prj.location} -B %{cfg.targetdir}",
		"cmake --build %{cfg.targetdir} --config Release"
	}
