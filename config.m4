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

PHP_ARG_WITH(openssl_dir, dir of openssl,
[  --with-openssl-dir[=DIR]    Include OpenSSL support (requires OpenSSL >= 0.9.6)], no, no)

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

if test "$PHP_SWOOLE_POSTGRESQL" != "no"; then

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
            PHP_ADD_LIBRARY(pq, 1, SWOOLE_POSTGRESQL_SHARED_LIBADD)
        else
            dnl TODO macros below can be reused to find curl things
            dnl prepare pkg-config
            if test -z "$PKG_CONFIG"; then
                AC_PATH_PROG(PKG_CONFIG, pkg-config, no)
            fi
            AC_MSG_CHECKING(for libpq)
            if test "x${LIBPQ_LIBS+set}" = "xset" || test "x${LIBPQ_CFLAGS+set}" = "xset"; then
                AC_MSG_RESULT([using LIBPQ_CFLAGS and LIBPQ_LIBS])
            elif test -x "$PKG_CONFIG" ; then
                dnl find pkg using pkg-config cli tool
                libpq_pkg_config_path="$PHP_SWOOLE_PGSQL/lib/pkgconfig"
                if test "xyes" = "x$PHP_SWOOLE_PGSQL" ; then
                    libpq_pkg_config_path=/lib/pkgconfig
                fi
                if test "x" != "x$PKG_CONFIG_PATH"; then
                    libpq_pkg_config_path="$libpq_pkg_config_path:$PKG_CONFIG_PATH"
                fi

                libpq_version_full=`env PKG_CONFIG_PATH=${libpq_pkg_config_path} $PKG_CONFIG --modversion libpq`
                AC_MSG_RESULT(${libpq_version_full})
                LIBPQ_CFLAGS="`env PKG_CONFIG_PATH=${libpq_pkg_config_path} $PKG_CONFIG --cflags libpq`"
                LIBPQ_LIBS="`env PKG_CONFIG_PATH=${libpq_pkg_config_path} $PKG_CONFIG --libs libpq`"
            fi

            _libpq_saved_cflags="$CFLAGS"
            CFLAGS="$CFLAGS $LIBPQ_CFLAGS"
            AC_CHECK_HEADER(libpq-fe.h, [], [
                dnl this is too long, wht so chaos?
                cat >&2 <<EOF
libpq headers was not found.
set LIBPQ_CFLAGS and LIBPQ_LIBS environment or
install following package to obtain them:
libpq-dev (for debian and its varients)
postgresql-devel (for rhel varients)
libpq-devel (for newer fedora)
postgresql-libs (for arch and its varients)
postgresql-dev (for alpine)
postgresql (for homebrew)
EOF
                AC_MSG_ERROR([postgresql support needs libpq headers to build])
            ])
            CFLAGS="$_libpq_saved_cflags"

            _libpq_saved_libs=$LIBS
            LIBS="$LIBS $LIBPQ_LIBS"
            AC_CHECK_LIB(pq, PQlibVersion, [ ], [
                cat >&2 <<EOF
libpq libraries was not found.
set LIBPQ_CFLAGS and LIBPQ_LIBS environment or
install following package to obtain them:
libpq-dev (for debian and its varients)
postgresql-devel (for rhel varients)
libpq-devel (for newer fedora)
postgresql-libs (for arch and its varients)
postgresql-dev (for alpine)
postgresql (for homebrew)
EOF
                AC_MSG_ERROR([postgresql support needs libpq libraries to build])
            ])
            LIBS="$_libpq_saved_libs"

            dnl FIXME: this should be SWOOLE_CFLAGS="$SWOOLE_CFLAGS $LIBPQ_CFLAGS"
            dnl or SWOOLE_PGSQL_CFLAGS="$SWOOLE_CFLAGS $LIBPQ_CFLAGS" and SWOOLE_PGSQL_CFLAGS only applies to ext-src/swoole_postgresql_coro.cc
            EXTRA_CFLAGS="$EXTRA_CFLAGS $LIBPQ_CFLAGS"
            PHP_EVAL_LIBLINE($LIBPQ_LIBS, SWOOLE_POSTGRESQL_SHARED_LIBADD)

            # AC_DEFINE(SW_USE_PGSQL, 1, [do we enable postgresql coro support])
        fi
        AC_DEFINE(SW_USE_POSTGRESQL, 1, [enable coroutine-postgresql support])
    fi

    if test "$PHP_OPENSSL" != "no" || test "$PHP_OPENSSL_DIR" != "no"; then
        if test "$PHP_OPENSSL_DIR" != "no"; then
            AC_DEFINE(SW_USE_OPENSSL, 1, [have openssl])
            PHP_ADD_INCLUDE("${PHP_OPENSSL_DIR}/include")
        fi
    fi

    CFLAGS="-Wall -pthread $CFLAGS"
    LDFLAGS="$LDFLAGS -lpthread"

    PHP_ADD_LIBRARY(pthread, 1, SWOOLE_POSTGRESQL_SHARED_LIBADD)

    swoole_source_file="swoole_postgresql.cc"

    PHP_NEW_EXTENSION(swoole_postgresql, $swoole_source_file, $ext_shared,, "$EXTRA_CFLAGS -DENABLE_PHP_SWOOLE_POSTGRESQL", cxx)

    PHP_ADD_INCLUDE([$ext_srcdir])
    PHP_ADD_INCLUDE([$ext_srcdir/include])
    PHP_ADD_INCLUDE([$phpincludedir/ext/swoole])
    PHP_ADD_INCLUDE([$phpincludedir/ext/swoole/include])
    
    PHP_ADD_EXTENSION_DEP(swoole_postgresql, swoole)

    PHP_REQUIRE_CXX()
    
    CXXFLAGS="$CXXFLAGS -Wall -Wno-unused-function -Wno-deprecated -Wno-deprecated-declarations -std=c++11"
fi
