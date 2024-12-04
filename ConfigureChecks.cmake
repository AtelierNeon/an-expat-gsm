include(CheckCCompilerFlag)
include(CheckCSourceCompiles)
include(CheckIncludeFile)
include(CheckIncludeFiles)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(TestBigEndian)

if(BUILD_WITH_COMPILER_PRECHECK AND WIN32)
    set(HAVE_FCNTL_H FALSE)
    set(HAVE_FCNTL_H TRUE)
    set(HAVE_INTTYPES_H TRUE)
    set(HAVE_MEMORY_H TRUE)
    set(HAVE_STDINT_H TRUE)
    set(HAVE_STDLIB_H TRUE)
    set(HAVE_STRINGS_H FALSE)
    set(HAVE_STRING_H TRUE)
    set(HAVE_SYS_STAT_H TRUE)
    set(HAVE_SYS_TYPES_H TRUE)
    set(HAVE_UNISTD_H FALSE)
else()
    check_include_file("dlfcn.h" HAVE_DLFCN_H)
    check_include_file("fcntl.h" HAVE_FCNTL_H)
    check_include_file("inttypes.h" HAVE_INTTYPES_H)
    check_include_file("memory.h" HAVE_MEMORY_H)
    check_include_file("stdint.h" HAVE_STDINT_H)
    check_include_file("stdlib.h" HAVE_STDLIB_H)
    check_include_file("strings.h" HAVE_STRINGS_H)
    check_include_file("string.h" HAVE_STRING_H)
    check_include_file("sys/stat.h" HAVE_SYS_STAT_H)
    check_include_file("sys/types.h" HAVE_SYS_TYPES_H)
    check_include_file("unistd.h" HAVE_UNISTD_H)
endif()

if(BUILD_WITH_COMPILER_PRECHECK AND WIN32)
    set(HAVE_GETPAGESIZE FALSE)
    set(HAVE_MMAP FALSE)
    set(HAVE_GETRANDOM FALSE)
else()
    check_symbol_exists("getpagesize" "unistd.h" HAVE_GETPAGESIZE)
    check_symbol_exists("mmap" "sys/mman.h" HAVE_MMAP)
    check_symbol_exists("getrandom" "sys/random.h" HAVE_GETRANDOM)
endif()

if(EXPAT_WITH_LIBBSD)
    set(CMAKE_REQUIRED_LIBRARIES "${LIB_BSD}")
    set(_bsd "bsd/")
else()
    set(_bsd "")
endif()
if(BUILD_WITH_COMPILER_PRECHECK AND WIN32)
    set(HAVE_ARC4RANDOM_BUF FALSE)
    set(HAVE_ARC4RANDOM FALSE)
else()
    check_symbol_exists("arc4random_buf" "${_bsd}stdlib.h" HAVE_ARC4RANDOM_BUF)
    if(NOT HAVE_ARC4RANDOM_BUF)
        check_symbol_exists("arc4random" "${_bsd}stdlib.h" HAVE_ARC4RANDOM)
    endif()
endif()
set(CMAKE_REQUIRED_LIBRARIES)

#/* Define to 1 if you have the ANSI C header files. */
if(BUILD_WITH_COMPILER_PRECHECK AND WIN32)
    set(STDC_HEADERS TRUE)
else()
    check_include_files("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS)
endif()

test_big_endian(WORDS_BIGENDIAN)
#/* 1234 = LIL_ENDIAN, 4321 = BIGENDIAN */
if(WORDS_BIGENDIAN)
    set(BYTEORDER 4321)
else(WORDS_BIGENDIAN)
    set(BYTEORDER 1234)
endif(WORDS_BIGENDIAN)

if(BUILD_WITH_COMPILER_PRECHECK AND WIN32)
    set(HAVE_OFF_T TRUE)
else()
    if(HAVE_SYS_TYPES_H)
        check_c_source_compiles("
            #include <sys/types.h>
            int main(void) {
                const off_t offset = -123;
                return 0;
            }"
            HAVE_OFF_T)
    endif()
endif()

if(NOT HAVE_OFF_T)
    set(off_t "long")
endif()

if(BUILD_WITH_COMPILER_PRECHECK AND WIN32)
    set(HAVE_SYSCALL_GETRANDOM FALSE)
else()
    check_c_source_compiles("
            #define _GNU_SOURCE
            #include <stdlib.h>  /* for NULL */
            #include <unistd.h>  /* for syscall */
            #include <sys/syscall.h>  /* for SYS_getrandom */
            int main(void) {
                syscall(SYS_getrandom, NULL, 0, 0);
                return 0;
            }"
        HAVE_SYSCALL_GETRANDOM)
endif()

if(BUILD_WITH_COMPILER_PRECHECK AND WIN32)
    set(FLAG_NO_STRICT_ALIASING FALSE)
    set(FLAG_VISIBILITY FALSE)
else()
    check_c_compiler_flag("-fno-strict-aliasing" FLAG_NO_STRICT_ALIASING)
    check_c_compiler_flag("-fvisibility=hidden" FLAG_VISIBILITY)
endif()

if(BUILD_WITH_COMPILER_PRECHECK AND WIN32)
    set(_EXPAT_LIBM_FOUND FALSE)
else()
    check_library_exists(m cos "" _EXPAT_LIBM_FOUND)
endif()
