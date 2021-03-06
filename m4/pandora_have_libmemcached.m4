dnl  Copyright (C) 2009 Sun Microsystems
dnl This file is free software; Sun Microsystems
dnl gives unlimited permission to copy and/or distribute it,
dnl with or without modifications, as long as this notice is preserved.

AC_DEFUN([_PANDORA_SEARCH_LIBMEMCACHED],[
  AC_REQUIRE([AC_LIB_PREFIX])

  dnl --------------------------------------------------------------------
  dnl  Check for libmemcached
  dnl --------------------------------------------------------------------

  AC_ARG_ENABLE([libmemcached],
    [AS_HELP_STRING([--disable-libmemcached],
      [Build with libmemcached support @<:@default=on@:>@])],
    [ac_enable_libmemcached="$enableval"],
    [ac_enable_libmemcached="yes"])

  AS_IF([test "x$ac_enable_libmemcached" = "xyes"],[
    AC_LIB_HAVE_LINKFLAGS(memcached,,[
      #include <libmemcached/memcached.h>
    ],[
      memcached_st memc;
      memcached_dump_func *df;
      memcached_lib_version();
    ])
    AC_LIB_HAVE_LINKFLAGS(memcachedprotocol,,[
      #include <libmemcached/protocol_handler.h>
    ],[
      struct memcached_protocol_st *protocol_handle;
      protocol_handle= memcached_protocol_create_instance();
    ])
  ],[
    ac_cv_libmemcached="no"
    ac_cv_libmemcachedprotocol="no"
  ])
  
  AC_CACHE_CHECK([if libmemcached has memcached_server_fn],
    [pandora_cv_libmemcached_server_fn],
    [AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
#include <libmemcached/memcached.h>
memcached_server_fn callbacks[1];
    ]])],
    [pandora_cv_libmemcached_server_fn=yes],
    [pandora_cv_libmemcached_server_fn=no])])
  AS_IF([test "x$pandora_cv_libmemcached_server_fn" = "xyes"],[
    AC_DEFINE([HAVE_MEMCACHED_SERVER_FN],[1],[If we have the new memcached_server_fn typedef])
  ])

  AM_CONDITIONAL(HAVE_LIBMEMCACHED, [test "x${ac_cv_libmemcached}" = "xyes"])
  
])

AC_DEFUN([PANDORA_HAVE_LIBMEMCACHED],[
  AC_REQUIRE([_PANDORA_SEARCH_LIBMEMCACHED])
])

AC_DEFUN([PANDORA_REQUIRE_LIBMEMCACHED],[
  AC_REQUIRE([PANDORA_HAVE_LIBMEMCACHED])
  AS_IF([test x$ac_cv_libmemcached = xno],
      AC_MSG_ERROR([libmemcached is required for ${PACKAGE}]))
])

AC_DEFUN([PANDORA_REQUIRE_LIBMEMCACHEDPROTOCOL],[
  AC_REQUIRE([PANDORA_HAVE_LIBMEMCACHED])
  AS_IF([test x$ac_cv_libmemcachedprotocol = xno],
      AC_MSG_ERROR([libmemcachedprotocol is required for ${PACKAGE}]))
])
