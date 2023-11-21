AC_INIT([global], [1], [alekseyz@jhu.edu])
AC_CANONICAL_HOST
AC_CONFIG_MACRO_DIR([m4])
AM_INIT_AUTOMAKE([subdir-objects foreign parallel-tests color-tests])
AM_SILENT_RULES([yes])
AC_CONFIG_SRCDIR([.])
AC_CONFIG_HEADERS([config.h])
AC_PROG_LIBTOOL

# Change default compilation flags
AS_IF([test -z "$CXXFLAGS"], [cxxflags_given=no], [cxxflags_given=yes])
AC_LANG(C++)
AC_PROG_CC
AC_PROG_CXX

# Checks for libraries.
CXXFLAGS="-std=c++0x $CXXFLAGS"
AS_IF([test x$cxxflags_given = xno], [CXXFLAGS="-DNDEBUG $CXXFLAGS"])
EXTRA_CXXFLAGS="-std=c++0x"
AC_SUBST([EXTRA_CXXFLAGS])
ALL_CXXFLAGS="$EXTRA_CXXFLAG"
AC_SUBST([ALL_CXXFLAGS])

AC_CHECK_LIB([pthread], [pthread_create])
AC_SEARCH_LIBS([clock_gettime], [rt], [AC_DEFINE([HAVE_CLOCK_GETTIME], [1], [Define to 1 if you have the 'clock_gettime' function])])

# Check for openmp
AC_ARG_ENABLE([openmp], [AS_HELP_STRING([--disable-openmp], [Disable OpenMP, even if available])])
AS_IF([test "x$enable_openmp" != "xno"],
      # OpenMP enabled. Check if available
      [AX_OPENMP([AC_DEFINE(HAVE_OPENMP,1,[Define if OpenMP is enabled])])]
      [EXTRA_CXXFLAGS="$EXTRA_CXXFLAGS $OPENMP_CXXFLAGS"],
      # OpenMP disabled. Ignore pragma warnings
      [EXTRA_CXXFLAGS="$EXTRA_CXXFLAGS -Wno-unknown-pragmas"])

# Check for Boost, and install if asked to
AS_IF([test x$BOOST_ROOT = xinstall],
      AS_IF([test ! -f include/boost/version.hpp],
            [AS_BOX([Installing Boost 1.59.0 from the Internet into include/boost])]
            [AS_MKDIR_P([include])]
            [curl -L http://downloads.sourceforge.net/project/boost/boost/1.59.0/boost_1_59_0.tar.bz2 | tar -jx -C include --strip-components=1 boost_1_59_0/boost]
            [AS_IF([test x$? != x0], [AC_MSG_FAILURE([failed to install Boost from the Internet])])])
      [BOOST_ROOT=`pwd -P`/include])

# For ufasta, disable regex unconditionally
AM_CONDITIONAL([HAVE_BOOST_REGEX], [false])

# Flags for samtools
AC_SUBST([SAMTOOLS_CFLAGS], ['-I$(includedir)/samtools'])
AC_SUBST([SAMTOOLS_LIBS], ['-L$(libdir) -lbam'])

# On MacOS X, use _NSGetExecutablePath to find path to own executable
AC_MSG_CHECKING([for _NSGetExecutablePath])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <mach-o/dyld.h>]],
                                   [[_NSGetExecutablePath(0, 0);]])],
                  [AC_MSG_RESULT([yes])]
                  [AC_DEFINE([HAVE_NSGETEXECUTABLEPATH], [1], [Used to find executable path on MacOS X])],
                  [AC_MSG_RESULT([no])])

# Checks for library functions.
AC_FUNC_MMAP
AC_CHECK_FUNCS([mremap])

# Check for zlib
AC_CHECK_HEADER([zlib.h], [], [AC_MSG_FAILURE([Cannot find zlib.h header. Install zlib development files (e.g. zlib1g-dev)])])
AC_CHECK_LIB([z], [zlibVersion], [], [AC_MSG_FAILURE([Cannot find zlib library. Install zlib libray])])

# Check bzip2 library
AC_CHECK_HEADER([bzlib.h], [], [AC_MSG_FAILURE([Cannot find bzilb.h header. Install bzip2 development files (e.g. bzip2-devel)])])
AC_CHECK_LIB([bz2], [BZ2_bzlibVersion], [], [AC_MSG_FAILURE([Cannot find bzip2 library. Install bzip2 library])])


# Use valgrind to check memory allocation with mmap
#AC_ARG_ENABLE([valgrind],
#              [AS_HELP_STRING([--enable-valgrind], [Instrument mmap memory allocation with valgrind])])
#AS_IF([test "x$enable_valgrind" = xyes],
#      [AC_DEFINE([HAVE_VALGRIND], [1], [Define is using Valgrind])]
#      [PKG_CHECK_MODULES([VALGRIND], [valgrind >= 1.8.0])])

# Check for builtin functions
AC_MSG_CHECKING([for __builtin_prefetch])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[int x = 0;]],
                                [[__builtin_prefetch(&x);]])],
               [AC_MSG_RESULT([yes])]
               [AC_DEFINE([HAVE_BUILTIN_PREFETCH], [1], [Defined if __builtin_prefetch is supported])],
               [AC_MSG_RESULT([no])])

# For Samtools, don't compile ncurses stuff
AC_SUBST([CURSES_LIB], [0])

# Check for yaggo
AC_ARG_VAR([YAGGO], [Yaggo switch parser generator])
AS_IF([test "x$YAGGO" = "x"], [AC_PATH_PROG([YAGGO], [yaggo], [false])])

# Output configuration files
AC_CONFIG_FILES([Makefile])
m4_map_args_w([samtools ufasta eviann],
              [AC_CONFIG_FILES(], [/Makefile)])
AC_OUTPUT
