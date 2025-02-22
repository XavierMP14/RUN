set(MIN_OSX_DEPLOYMENT_TARGET "13.0")

if(DEFINED ENV{CI})
  set(DEFAULT_OSX_DEPLOYMENT_TARGET ${MIN_OSX_DEPLOYMENT_TARGET})
else()
  execute_process(
    COMMAND xcrun --sdk macosx --show-sdk-version
    OUTPUT_VARIABLE DEFAULT_OSX_DEPLOYMENT_TARGET
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_VARIABLE DEFAULT_OSX_DEPLOYMENT_TARGET_ERROR
    ERROR_STRIP_TRAILING_WHITESPACE
  )
  if(DEFAULT_OSX_DEPLOYMENT_TARGET_ERROR)
    message(WARNING "Failed to find macOS SDK version, did you run `xcode-select --install`?")
    message(FATAL_ERROR ${DEFAULT_OSX_DEPLOYMENT_TARGET_ERROR})
  endif()
endif()

optionx(CMAKE_OSX_DEPLOYMENT_TARGET STRING "The macOS SDK version to target" DEFAULT ${DEFAULT_OSX_DEPLOYMENT_TARGET})

if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_LESS ${MIN_OSX_DEPLOYMENT_TARGET})
  message(FATAL_ERROR "The target macOS SDK version, ${CMAKE_OSX_DEPLOYMENT_TARGET}, is older than the minimum supported version, ${MIN_OSX_DEPLOYMENT_TARGET}.")
endif()

execute_process(
  COMMAND sw_vers -productVersion
  OUTPUT_VARIABLE MACOS_VERSION
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_QUIET
)

if(MACOS_VERSION VERSION_LESS ${CMAKE_OSX_DEPLOYMENT_TARGET})
  message(FATAL_ERROR "Your computer is running macOS ${MACOS_VERSION}, which is older than the target macOS SDK ${CMAKE_OSX_DEPLOYMENT_TARGET}. To fix this, either:\n"
    " - Upgrade your computer to macOS ${CMAKE_OSX_DEPLOYMENT_TARGET} or newer\n"
    " - Download a newer version of the macOS SDK from Apple: https://developer.apple.com/download/all/?q=xcode\n"
    " - Set -DCMAKE_OSX_DEPLOYMENT_TARGET=${MACOS_VERSION}\n")
endif()

execute_process(
  COMMAND xcrun --sdk macosx --show-sdk-path
  OUTPUT_VARIABLE DEFAULT_CMAKE_OSX_SYSROOT
  OUTPUT_STRIP_TRAILING_WHITESPACE
  ERROR_VARIABLE DEFAULT_CMAKE_OSX_SYSROOT_ERROR
  ERROR_STRIP_TRAILING_WHITESPACE
)

if(CMAKE_OSX_SYSROOT_ERROR)
  message(WARNING "Failed to find macOS SDK path, did you run `xcode-select --install`?")
  message(FATAL_ERROR ${CMAKE_OSX_SYSROOT_ERROR})
endif()

optionx(CMAKE_OSX_SYSROOT STRING "The macOS SDK path to target" DEFAULT ${DEFAULT_CMAKE_OSX_SYSROOT})

list(APPEND CMAKE_ARGS 
  -DCMAKE_OSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET}
  -DCMAKE_OSX_SYSROOT=${CMAKE_OSX_SYSROOT}
)
