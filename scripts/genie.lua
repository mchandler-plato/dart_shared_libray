
PROJECT_DIR = path.getabsolute("..")
local BUILD_DIR = path.join(PROJECT_DIR, ".build")
local DART_DIR = path.join(PROJECT_DIR, "dart-sdk", "sdk")
local ARCH = "x64"

function dartDllExample(_name)
    project (_name)
        uuid (os.uuid(_name))
        kind "ConsoleApp"

        local PLATFORM = "win64"
        configuration { "macosx" }
            PLATFORM = "mac"
        
        configuration {}

        targetdir (path.join(BUILD_DIR, PLATFORM .. "_" .. _ACTION, "bin", _name))
        debugdir (path.join(PROJECT_DIR, "examples", _name))
    
        files {
            path.join(PROJECT_DIR, "examples", _name, "**.cpp"),
            path.join(PROJECT_DIR, "examples", _name, "**.h")
        }

        links {
            "dart_dll"
        }

        includedirs {
            path.join(PROJECT_DIR, "src"),
            path.join(DART_DIR, "runtime", "include")
        }

        configuration "windows"
            postbuildcommands {  
                "xcopy /Y \"" .. (path.translate(path.join(PROJECT_DIR, "examples", _name, "*.dart"))) .. "\" \"$(TARGETDIR)\"",
                "xcopy /Y \"" .. (path.translate(path.join("$(TARGETDIR)", "..", "*.dll"))) .. "\" \"$(TARGETDIR)\"",
                "xcopy /Y \"" .. (path.translate(path.join("$(TARGETDIR)", "..", "*.dll"))) .. "\" \"$(TARGETDIR)\""
            }

        configuration {}
end

solution "dart_dll"
    configurations {
        "Debug",
        "Release",
    }
    platforms { "x64", "arm64" }

	configuration { "Release" }
		flags {
			"NoBufferSecurityCheck",
			"OptimizeSpeed",
		}
		defines {
			"NDEBUG",
		}
    
    configuration {}

    language "C++"

    flags {
        "Cpp14",
		"ExtraWarnings",
		"NoPCH",
		"NativeWChar",
		"NoRTTI",
		"NoExceptions",
		"NoEditAndContinue",
		"NoFramePointer",
		"Symbols",
	}

	defines {
		"__STDC_LIMIT_MACROS",
		"__STDC_FORMAT_MACROS",
		"__STDC_CONSTANT_MACROS",
	}

    location (path.join(BUILD_DIR, "projects", _ACTION))

    configuration { "windows", "x64" }
        defines {
            "_WIN"
        }

    configuration { "vs*" }
        defines { 
            "_HAS_EXCEPTIONS=0",
			"_SCL_SECURE=0",
			"_SECURE_SCL=0",
			"_SCL_SECURE_NO_WARNINGS",
			"_CRT_SECURE_NO_WARNINGS",
			"_CRT_SECURE_NO_DEPRECATE"
        }
        targetdir (path.join(BUILD_DIR, "win64_" .. _ACTION, "bin"))
        objdir (path.join(BUILD_DIR, "win64_" .. _ACTION, "obj"))

    configuration { "macosx" }
        targetdir (path.join(BUILD_DIR, "mac_" .. _ACTION, "bin"))
        objdir (path.join(BUILD_DIR, "mac_" .. _ACTION, "obj"))
        
    configuration {}

    project ("dart_dll")
        uuid (os.uuid("dart_dll"))
        kind "SharedLib"

        configuration { "windows" }
            defines {
                "DART_DLL_EXPORTING",
                "_ITERATOR_DEBUG_LEVEL=0"
            }

            -- Both Debug and Release need to use the Release Static CRT
            flags {
                "StaticRuntime",
                "OptimizeSpeed"
            }

            links {
                "libdart",
                "dbghelp",
                "bcrypt",
                "rpcrt4",
                "ws2_32",
                "Iphlpapi",
                "Psapi",
                "shlwapi"
            }
            libdirs {
                path.join(DART_DIR, "out", "ReleaseX64", "obj", "runtime", "bin")
            }
        
        configuration { "arm64" }
            ARCH = "arm64"

        configuration { "macosx" }
            links {
                "dart"
            }
            libdirs {
                path.join(DART_DIR, "xcodebuild", "Release" .. string.upper(ARCH) , "obj", "runtime", "bin")
            }
            linkoptions {
                "-framework Cocoa",
                "-framework QuartzCore",
                "-framework Security",
                "-nostdlib++ " .. path.getabsolute(path.join(DART_DIR, "buildtools", "mac-" .. ARCH, "clang", "lib", "libc++.a"))
            }
            xcodeprojectopts {
                COMPILER_INDEX_STORE_ENABLE = "NO",
                CC = path.getabsolute(path.join(DART_DIR, "buildtools", "mac-" .. ARCH, "clang", "bin", "clang")),
                CXX = path.getabsolute(path.join(DART_DIR, "buildtools", "mac-" .. ARCH, "clang", "bin", "clang++"))
            }

            buildoptions {
                "-Wno-unknown-pragmas"
            }
        
        configuration {}
        
        files {
            path.join(PROJECT_DIR, "src", "**.cpp"),
            path.join(PROJECT_DIR, "src", "**.h")
        }

        includedirs {
            path.join(DART_DIR, "runtime")
        }

        group("examples")
            dartDllExample("simple_example")
            dartDllExample("simple_example_ffi")
