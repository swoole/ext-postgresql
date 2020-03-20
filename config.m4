dnl $Id$
dnl config.m4 for extension swoole_postgresql

dnl  +----------------------------------------------------------------------+
dnl  | Swoole                                                               |
dnl  +----------------------------------------------------------------------+
dnl  | This source file is subject to version 2.0 of the Apache license,    |
dnl  | that is bundled with this package in the file LICENSE, and is        |
dnl  | available through the world-wide-web at the following url:           |
dnl  | http://www.apache.org/licenses/LICENSE-2.0.html                      |
dnl  | If you did not receive a copy of the Apache2.0 license and are unable|
dnl  | to obtain it through the world-wide-web, please send a note to       |
dnl  | license@swoole.com so we can mail you a copy immediately.            |
dnl  +----------------------------------------------------------------------+
dnl  | Author: Tianfeng Han  <mikan.tenny@gmail.com>                        |
dnl  +----------------------------------------------------------------------+

PHP_ARG_ENABLE(swoole_postgresql, swoole_postgresql support,
[  --enable-swoole_postgresql           Enable swoole_postgresql support], [enable_swoole_postgresql="yes"])

PHP_ARG_ENABLE(asan, whether to enable asan,
[  --enable-asan             Enable asan], no, no)

PHP_ARG_WITH(libpq_dir, dir of libpq,
[  --with-libpq-dir[=DIR]      Include libpq support (requires libpq >= 9.5)], no, no)

AC_MSG_CHECKING([if compiling with clang])
AC_COMPILE_IFELSE([
    AC_LANG_PROGRAM([], [[
        #ifndef __clang__
            not clang
        #endif
    ]])],
    [CLANG=yes], [CLANG=no]
)
AC_MSG_RESULT([$CLANG])

if test "$CLANG" = "yes"; then
    CFLAGS="$CFLAGS -std=gnu89"
fi

if test "$PHP_swoole_postgresql" != "no"; then

    PHP_ADD_LIBRARY(pthread)
    PHP_SUBST(SWOOLE_POSTGRESQL_SHARED_LIBADD)

    AC_CHECK_LIB(pq, PQconnectdb, AC_DEFINE(HAVE_POSTGRESQL, 1, [have postgresql]))

    if test "$PHP_ASAN" != "no"; then
        PHP_DEBUG=1
        CFLAGS="$CFLAGS -fsanitize=address -fno-omit-frame-pointer"
    fi

    if test "$PHP_TRACE_LOG" != "no"; then
        AC_DEFINE(SW_LOG_TRACE_OPEN, 1, [enable trace log])
    fi

    if test "$PHP_LIBPQ" != "no" || test "$PHP_LIBPQ_DIR" != "no"; then
        if test "$PHP_LIBPQ_DIR" != "no"; then
            AC_DEFINE(HAVE_LIBPQ, 1, [have libpq])
            AC_MSG_RESULT(libpq include success)
            PHP_ADD_INCLUDE("${PHP_LIBPQ_DIR}/include")
            PHP_ADD_LIBRARY_WITH_PATH(pq, "${PHP_LIBPQ_DIR}/${PHP_LIBDIR}")
            PGSQL_INCLUDE=$PHP_LIBPQ_DIR/include
        fi
        AC_DEFINE(SW_USE_POSTGRESQL, 1, [enable coroutine-postgresql support])
        PHP_ADD_LIBRARY(pq, 1, SWOOLE_POSTGRESQL_SHARED_LIBADD)
    fi

    CFLAGS="-Wall -pthread $CFLAGS"
    LDFLAGS="$LDFLAGS -lpthread"

    PHP_ADD_LIBRARY(pthread, 1, SWOOLE_POSTGRESQL_SHARED_LIBADD)

    swoole_source_file="swoole_postgresql_coro.cc"

    PHP_NEW_EXTENSION(swoole_postgresql, $swoole_source_file, $ext_shared,,, cxx)

    PHP_ADD_INCLUDE([$ext_srcdir])
    PHP_ADD_INCLUDE([$ext_srcdir/include])
    PHP_ADD_INCLUDE([$phpincludedir/ext/swoole])
    PHP_ADD_INCLUDE([$phpincludedir/ext/swoole/include])
    
    PHP_ADD_EXTENSION_DEP(swoole_postgresql, swoole)

    PHP_REQUIRE_CXX()
    
    CXXFLAGS="$CXXFLAGS -Wall -Wno-unused-function -Wno-deprecated -Wno-deprecated-declarations -std=c++11"
fi
