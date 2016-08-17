# gt.m4 - Macros to locate and utilise giella-core scripts and required tools
# for the Divvun and Giellatekno infrastructure. -*- Autoconf -*-
# serial 1 (gtsvn-1)
# 
# Copyright © 2011 Divvun/Samediggi/UiT <bugs@divvun.no>.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; version 3 of the License.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
# As a special exception to the GNU General Public License, if you
# distribute this file as part of a program that contains a
# configuration script generated by Autoconf, you may include it under
# the same distribution terms that you use for the rest of that program.

# the prefixes gt_*, _gt_* are reserved here for giellatekno variables and
# macros. It is the same as gettext and probably others, but I expect no
# collisions really.

################################################################################
# Define functions for checking paths and the GIELLA core environment:
################################################################################
AC_DEFUN([gt_PROG_SCRIPTS_PATHS],
         [
AC_ARG_VAR([GTMAINTAINER], [define if you are maintaining the infra to get additional complaining about infra integrity])
AM_CONDITIONAL([WANT_MAINTAIN], [test x"$GTMAINTAINER" != x])

AC_PATH_PROG([GTCORESH], [gt-core.sh], [false],
             [$GTCORE/scripts$PATH_SEPARATOR$GTHOME/gtcore/scripts$PATH_SEPARATOR$PATH])

AC_MSG_CHECKING([whether GTCORE is found])
AS_IF([test "x$GTCORE"    = x -a \
            "x$GTCORESH" != xfalse ],
            [GTCORE=$(${GTCORESH}); AC_MSG_RESULT([yes - via script])],
	  [test "x$GTCORE" != x], [AC_MSG_RESULT([yes - via environment])],
      [AC_MSG_RESULT([no])])

# GTCORE env. variable is required by the infrastructure to find scripts:
AC_ARG_VAR([GTCORE], [directory for giella core scripts; giella-core path should always be declared by gtsetup.sh])

AS_IF([test "x$GTCORE" = x], 
      [cat<<EOT

Could not set GTCORE and thus not find required scripts in:
       $GTCORE/scripts 
       $GTHOME/gtcore/scripts 
       $PATH 

       Please do the following: 
       1. svn co https://victorio.uit.no/langtech/trunk/gtcore
       2. then either:
         a: cd gtcore && ./autogen.sh && ./configure && make install
          or:
         b: add the following to your ~/.bash_profile or ~/.profile:

       export \$GTCORE=/path/to/gtcore/checkout/dir

       (replace the path with the real path from 1. above)

EOT
       AC_MSG_ERROR([GTCORE could not be set])])

##### Check the version of the giella-core, and stop with error message if too old:
# This is the error message:
giella_core_too_old_message="

The giella-core is too old, we require at least $_giella_core_min_version.

*** ==> PLEASE ENTER THE FOLLOWING COMMANDS: <== ***

cd $GTCORE
svn up
./autogen.sh # required only the first time
./configure  # required only the first time
make
sudo make install # optional, only needed if installed
                  # earlier or installed on a server.
"

# Identify the version of giella-core:
AC_PATH_PROG([GIELLA_CORE_VERSION], [gt-version.sh], [no],
    [$GTCORE/scripts$PATH_SEPARATOR$GTHOME/gtcore/scripts$PATH_SEPARATOR$PATH])
AC_MSG_CHECKING([the version of the Giella Core])
AS_IF([test "x${GIELLA_CORE_VERSION}" != xno],
        [_giella_core_version=$( ${GIELLA_CORE_VERSION} )],
        [AC_MSG_ERROR([gt-version.sh could not be found, installation is incomplete!])
    ])
AC_MSG_RESULT([$_giella_core_version])

AC_MSG_CHECKING([whether the Giella Core version is at least $_giella_core_min_version])
# Compare it to the required version, and error out if too old:
AX_COMPARE_VERSION([$_giella_core_version], [ge], [$_giella_core_min_version],
                   [giella_core_version_ok=yes], [giella_core_version_ok=no])
AS_IF([test "x${giella_core_version_ok}" != xno], [AC_MSG_RESULT([$giella_core_version_ok])],
[AC_MSG_ERROR([$giella_core_too_old_message])])

################################
### Giella-shared dir:
################
# 1. check env GIELLA_SHARED, then GIELLA_HOME, then GTHOME, then GTCORE
# 2. check --with-giella-shared option
# 3. check uing pkg-config
# 4. error if not found

AC_MSG_CHECKING([whether we can find giella-shared data])

AC_ARG_WITH([giella-shared],
            [AS_HELP_STRING([--with-giella-shared=DIRECTORY],
                            [search giella-shared data in DIRECTORY @<:@default=PATH@:>@])],
            [with_giella_shared=$withval],
            [with_giella_shared=false])

AS_IF([test "x$GIELLA_SHARED" = "x"], [
    AS_IF([test "x$GIELLA_HOME" != "x"], [
        GIELLA_SHARED=$GIELLA_HOME/giella-shared
    ], [
        # GTHOME for backwards compatibility - it is deprecated:
        AS_IF([test "x$GTHOME" != "x"], [
            GIELLA_SHARED=$GTHOME/giella-shared
        ], [
            # GTCORE for backwards compatibility - it is deprecated:
            AS_IF([test "x$GTCORE" != "x"], [
                GIELLA_SHARED=$GTCORE/giella-shared
            ], [
                AS_IF([test "x$with_giella_shared" != "xfalse"], [
                    GIELLA_SHARED=$with_giella_shared
                ],[
                   PKG_CHECK_MODULES([GIELLA], [giella-common], [],
                   [AC_MSG_ERROR([Could not find giella-common data dir])])
                ])
            ])
        ])
    ])
])
AC_MSG_RESULT([$GIELLA_SHARED])

# GIELLA_SHARED is required by the infrastructure to find shared data:
AC_ARG_VAR([GIELLA_SHARED], [directory for giella shared data, like shared proper noun lists and shared regexes])

################################
### Some software that we either depend on or we need for certain functionality: 
################

################ Weighted fst's ################
AC_PATH_PROG([BC], [bc], [no], [$PATH$PATH_SEPARATOR$with_bc])

################ YAML-based testing ################
AC_ARG_ENABLE([yamltests],
              [AS_HELP_STRING([--enable-yamltests],
                              [enable yaml tests @<:@default=check@:>@])],
              [enable_yamltests=$enableval],
              [enable_yamltests=check])

AS_IF([test "x$enable_yamltests" = "xcheck"], 
     [AM_PATH_PYTHON([3.3],, [:])
     AX_PYTHON_MODULE(yaml)
     AC_MSG_CHECKING([whether to enable yaml-based test])
     AS_IF([test "$PYTHON" = ":"],
           [enable_yamltests=no
            new_enough_python_available=no
            AC_MSG_RESULT([no, python is missing or old])
            ],
           [AS_IF([test "x$HAVE_PYMOD_YAML" != "xyes"],
                  [enable_yamltests=no
                   new_enough_python_available=yes
                   AC_MSG_RESULT([no, yaml is missing])
                   ],
                  [enable_yamltests=yes
                   new_enough_python_available=yes
                   AC_MSG_RESULT([yes])])])])

AM_CONDITIONAL([CAN_YAML_TEST], [test "x$enable_yamltests" != xno])

################ Generated documentation ################
# Check for awk with required feature:
AC_CACHE_CHECK([for awk that supports gensub], [ac_cv_path_GAWK],
  [AC_PATH_PROGS_FEATURE_CHECK([GAWK], [awk mawk nawk gawk],
    [[awkout=`$ac_path_GAWK 'BEGIN{gensub(/a/,"b","g");}'; exvalue=$?; echo $exvalue`
      test "x$awkout" = x0 \
      && ac_cv_path_GAWK=$ac_path_GAWK ac_path_GAWK_found=:]],
    [AC_MSG_ERROR([could not find awk that supports gensub - please install GNU awk])])])
AC_SUBST([GAWK], [$ac_cv_path_GAWK])

# Check for Forrest:
AC_PATH_PROG([FORREST], [forrest], [], [$PATH$PATH_SEPARATOR$with_forrest])
AC_MSG_CHECKING([whether we can enable in-source documentation building])
AS_IF([test "x$GAWK" != x], [
    AS_IF([test "x$JV" != xfalse], [
    	AS_IF([test "x$FORREST" != x], [gt_prog_docc=yes], [gt_prog_docc=no])
    ],[gt_prog_docc=no])
],[gt_prog_docc=no])
AC_MSG_RESULT([$gt_prog_docc])
AM_CONDITIONAL([CAN_DOCC], [test "x$gt_prog_docc" != xno])

################ can rsync oxt template? ################
AC_PATH_PROG([RSYNC], [rsync], [no], [$PATH$PATH_SEPARATOR$with_rsync])
AC_MSG_CHECKING([whether we can rsync LO-voikko oxt template locally])
AS_IF([test "x$GTHOME" != "x" -a \
            "x$RSYNC"  != "x" -a \
          -d "${GTHOME}/prooftools/toollibs/LibreOffice-voikko" ],
      [can_local_sync=yes], [can_local_sync=no])
AC_MSG_RESULT([$can_local_sync])
AM_CONDITIONAL([CAN_LOCALSYNC], [test "x$can_local_sync" != xno ])

AC_PATH_PROG([WGET],  [wget],  [no], [$PATH$PATH_SEPARATOR$with_wget])

]) # gt_PROG_SCRIPTS_PATHS

################################################################################
# Define functions for checking the availability of the Xerox tools:
################################################################################
AC_DEFUN([gt_PROG_XFST],
[AC_ARG_WITH([xfst],
            [AS_HELP_STRING([--with-xfst=DIRECTORY],
                            [search xfst in DIRECTORY @<:@default=PATH@:>@])],
            [with_xfst=$withval],
            [with_xfst=yes])
AC_PATH_PROG([PRINTF], [printf], [echo -n])
AC_PATH_PROG([XFST], [xfst], [false], [$PATH$PATH_SEPARATOR$with_xfst])
AC_PATH_PROG([TWOLC], [twolc], [false], [$PATH$PATH_SEPARATOR$with_xfst])
AC_PATH_PROG([LEXC], [lexc], [false], [$PATH$PATH_SEPARATOR$with_xfst])
AC_PATH_PROG([LOOKUP], [lookup], [false], [$PATH$PATH_SEPARATOR$with_xfst])
AC_MSG_CHECKING([whether to enable xfst building])
AS_IF([test x$with_xfst != xno], [
    AS_IF([test "x$XFST"   != xfalse -a \
                "x$TWOLC"  != xfalse -a \
                "x$LEXC"   != xfalse -a \
                "x$LOOKUP" != xfalse  ], [gt_prog_xfst=yes],
          [gt_prog_xfst=no])
], [gt_prog_xfst=no])
AC_MSG_RESULT([$gt_prog_xfst])
AM_CONDITIONAL([CAN_XFST], [test "x$gt_prog_xfst" != xno])
]) # gt_PROG_XFST

################################################################################
# Define functions for checking the availability of Voikko tools:
################################################################################
AC_DEFUN([gt_PROG_VFST],
[AC_ARG_WITH([voikko],
            [AS_HELP_STRING([--with-voikko=DIRECTORY],
                            [search voikko in DIRECTORY @<:@default=PATH@:>@])],
            [with_voikko=$withval],
            [with_voikko=yes])
AC_PATH_PROG([VOIKKOSPELL],     [voikkospell],     [false],
                                            [$PATH$PATH_SEPARATOR$with_voikko])
AC_PATH_PROG([VOIKKOHYPHENATE], [voikkohyphenate], [false],
                                            [$PATH$PATH_SEPARATOR$with_voikko])
AC_PATH_PROG([VOIKKOGC],        [voikkogc],        [false],
                                            [$PATH$PATH_SEPARATOR$with_voikko])
AC_PATH_PROG([VOIKKOVFSTC],     [voikkovfstc],     [false],
                                            [$PATH$PATH_SEPARATOR$with_voikko])
AC_MSG_CHECKING([whether to enable voikko building])
AS_IF([test x$with_voikko != xno], [
    AS_IF([test "x$VOIKKOSPELL"      != xfalse -a \
                "x$VOIKKOHYPHENATE"  != xfalse -a \
                "x$VOIKKOGC"         != xfalse -a \
                "x$VOIKKOVFSTC"      != xfalse  ], [gt_prog_voikko=yes],
          [gt_prog_voikko=no])
], [gt_prog_voikko=no])
AC_MSG_RESULT([$gt_prog_voikko])
AM_CONDITIONAL([CAN_VFST], [test "x$gt_prog_voikko" != xno])
]) # gt_PROG_VFST

################################################################################
# Define functions for checking the availability of the Foma tools:
################################################################################
AC_DEFUN([gt_PROG_FOMA],
[AC_ARG_WITH([foma],
            [AS_HELP_STRING([--with-foma=DIRECTORY],
                            [search foma in DIRECTORY @<:@default=PATH@:>@])],
            [with_foma=$withval],
            [with_foma=no])

# If Xerox tools and Hfst are not found, assume we want Foma:
AS_IF([test x$gt_prog_xfst = xno -a x$gt_prog_hfst = xno], [with_foma=yes])

AC_PATH_PROG([PRINTF], [printf], [echo -n])
AC_PATH_PROG([FOMA], [foma], [false], [$PATH$PATH_SEPARATOR$with_foma])
AC_PATH_PROG([FLOOKUP], [flookup], [false], [$PATH$PATH_SEPARATOR$with_foma])
AC_PATH_PROG([CGFLOOKUP], [cgflookup], [false], [$PATH$PATH_SEPARATOR$with_foma])
AC_MSG_CHECKING([whether to enable foma building])
AS_IF([test x$with_foma != xno], [
    AS_IF([test "x$FOMA"      != xfalse -a \
                "x$FLOOKUP"   != xfalse -a \
                "x$CGFLOOKUP" != xfalse  ], [gt_prog_foma=yes],
          [gt_prog_foma=no])
], [gt_prog_foma=no])
AC_MSG_RESULT([$gt_prog_foma])
AM_CONDITIONAL([CAN_FOMA], [test "x$gt_prog_foma" != xno])
AM_CONDITIONAL([HAS_FOMA], [test "x$FOMA" != xfalse ])
]) # gt_PROG_FOMA

################################################################################
# Define functions for checking the availability of the VISLCG3 tools:
################################################################################
AC_DEFUN([gt_PROG_VISLCG3],
[AC_ARG_WITH([vislcg3],
            [AS_HELP_STRING([--with-vislcg3=DIRECTORY],
                            [search vislcg3 in DIRECTORY @<:@default=PATH@:>@])],
            [with_vislcg3=$withval],
            [with_vislcg3=check])
AC_PATH_PROG([VISLCG3], [vislcg3], [no], [$PATH$PATH_SEPARATOR$with_vislcg3])
AC_PATH_PROG([VISLCG3_COMP], [cg-comp], [no], [$PATH$PATH_SEPARATOR$with_vislcg3])

AS_IF([test "x$VISLCG3" != xno], [
_giella_core_vislcg3_min_version=m4_default([$1], [0.9.9.011351])
AC_MSG_CHECKING([whether vislcg3 is at least $_giella_core_vislcg3_min_version])
_vislcg3_version=$( ${VISLCG3} --version 2>&1 | grep -Eo '@<:@0-9@:>@+\.@<:@0-9.@:>@+' )
AX_COMPARE_VERSION([$_vislcg3_version], [ge], [$_giella_core_vislcg3_min_version],
                   [gt_prog_vislcg3=yes
                    AC_MSG_RESULT([yes - $_vislcg3_version])
                   ], [gt_prog_vislcg3=no
                    AC_MSG_RESULT([no - $_vislcg3_version])
                   ])
],
[gt_prog_vislcg3=no])
AC_MSG_CHECKING([whether we can enable vislcg3 targets])
AS_IF([test "x$gt_prog_vislcg3" != xno], [AC_MSG_RESULT([yes])],
      [AC_MSG_RESULT([no])])
AM_CONDITIONAL([CAN_VISLCG], [test "x$gt_prog_vislcg3" != xno])
]) # gt_PROG_VISLCG3

################################################################################
# Define functions for checking the availability of Saxon:
################################################################################
AC_DEFUN([gt_PROG_SAXON],
[AC_ARG_WITH([saxon],
             [AS_HELP_STRING([--with-saxon=DIRECTORY],
                             [search saxon wrapper script in DIRECTORY @<:@default=PATH@:>@])],
             [with_saxon=$withval],
             [with_saxon=check])
AC_PATH_PROG([SAXON], [saxonb-xslt saxon9 saxon8 saxon], [false], [$PATH$PATH_SEPARATOR$with_saxon])
AC_PATH_PROG([JV], [java], [false])
AC_CHECK_FILE([$HOME/lib/saxon9he.jar],
    AC_SUBST(SAXONJAR, [$HOME/lib/saxon9he.jar]),
    [AC_CHECK_FILE([$HOME/lib/saxon9.jar],
        AC_SUBST(SAXONJAR, [$HOME/lib/saxon9.jar]),
        [AC_CHECK_FILE([/opt/local/share/java/saxon9he.jar],
            AC_SUBST(SAXONJAR, [/opt/local/share/java/saxon9he.jar]),
            [AC_CHECK_FILE([/usr/share/java/Saxon-HE.jar],
                AC_SUBST(SAXONJAR, [/usr/share/java/Saxon-HE.jar]),
                [AC_CHECK_FILE([/usr/share/java/saxon.jar],
                AC_SUBST(SAXONJAR, [/usr/share/java/saxon.jar]),
                    [_saxonjar=no])
                    ])])])]
)
AS_IF([test "x$_saxonjar" != xno], [
_saxon_min_version="8.0"
_saxon_version=$( java -jar $SAXONJAR -? 2>&1 | fgrep -i 'saxon' | grep -Eo '@<:@0-9@:>@+\.@<:@0-9.@:>@+' )
AC_MSG_CHECKING([whether the Saxon JAR is at least $_saxon_min_version])
AX_COMPARE_VERSION([$_saxon_version], [ge], [$_saxon_min_version],
                   [_saxonjar=yes
                    AC_MSG_RESULT([yes - $_saxon_version])
                   ], [_saxonjar=no
                    AC_MSG_RESULT([no - $_saxon_version])
                   ])
],
[_saxonjar=no])
AC_MSG_CHECKING([whether we can enable xslt2 transformations])
AS_IF([test x$with_saxon != xno], [
    AS_IF([test "x$SAXON" != xfalse], [gt_prog_saxon=yes],
          [gt_prog_saxon=no])
    AS_IF([test x$JV != xfalse], [gt_prog_java=yes], [gt_prog_java=no])
    AS_IF([test x$gt_prog_java != xno -a x$_saxonjar != xno],
          [gt_prog_xslt=yes], [gt_prog_xslt=no])
], [gt_prog_xslt=no])
AC_MSG_RESULT([$gt_prog_xslt])
AM_CONDITIONAL([CAN_SAXON], [test "x$gt_prog_saxon" != xno])
AM_CONDITIONAL([CAN_JAVA], [test "x$gt_prog_java" != xno -a "x$_saxonjar" != xno]) 
]) # gt_PROG_SAXON

################################################################################
# Define functions for configuration of the build targets:
################################################################################
AC_DEFUN([gt_ENABLE_TARGETS],
[
# Foma-speller requires gzip, Voikko requires zip:
AC_PATH_PROG([ZIP],  [zip],      [false], [$PATH$PATH_SEPARATOR$with_zip])
AC_PATH_PROG([GZIP], [gzip],     [false], [$PATH$PATH_SEPARATOR$with_gzip])
AC_PATH_PROGS([TAR], [tar gtar], [false], [$PATH$PATH_SEPARATOR$with_tar])
AC_PATH_PROG([XZ],   [xz],       [false], [$PATH$PATH_SEPARATOR$with_xz])
AM_CONDITIONAL([CAN_XZ], [test "x$ac_cv_prog_XZ" != xfalse])

# Enable hyperminimisation of the lexical transducer - default is 'no'
AC_ARG_ENABLE([hyperminimisation],
              [AS_HELP_STRING([--enable-hyperminimisation],
                              [enable hyperminimisation of lexical fst @<:@default=no@:>@])],
              [enable_hyperminimisation=$enableval],
              [enable_hyperminimisation=no])
AM_CONDITIONAL([WANT_HYPERMINIMISATION], [test "x$enable_hyperminimisation" != xno])

# Enable symbol alignment of the lexical transducer - default is 'no'
AC_ARG_ENABLE([alignment],
              [AS_HELP_STRING([--enable-alignment],
                              [enable symbol alignment when parsing lexc @<:@default=no@:>@])],
              [enable_alignment=$enableval],
              [enable_alignment=no])
AM_CONDITIONAL([WANT_LEXC_ALIGNMENT], [test "x$enable_alignment" != xno])

#enable_twostep_intersect
AC_ARG_ENABLE([twostep-intersect],
              [AS_HELP_STRING([--enable-twostep-intersect],
                              [enable two-step compose-intersect (more correct in rare cases, might be slower) @<:@default=no@:>@])],
              [enable_twostep_intersect=$enableval],
              [enable_twostep_intersect=no])
AM_CONDITIONAL([WANT_TWOSTEP_INTERSECT], [test "x$enable_twostep_intersect" != xno])

#enable_reversed_intersect
AC_ARG_ENABLE([reversed-intersect],
              [AS_HELP_STRING([--enable-reversed-intersect],
                              [enable reversed compose-intersect (faster and takes less RAM in some cases) @<:@default=no@:>@])],
              [enable_reversed_intersect=$enableval],
              [enable_reversed_intersect=no])
AM_CONDITIONAL([WANT_REVERSED_INTERSECT], [test "x$enable_reversed_intersect" != xno])

# Enable morphological analysers - default is 'yes'
AC_ARG_ENABLE([analysers],
              [AS_HELP_STRING([--enable-analysers],
                              [build morphological analysers @<:@default=yes@:>@])],
              [enable_analysers=$enableval],
              [enable_analysers=yes])
AM_CONDITIONAL([WANT_MORPHOLOGY], [test "x$enable_analysers" != xno])

# Enable morphological generators - default is 'yes'
AC_ARG_ENABLE([generators],
              [AS_HELP_STRING([--enable-generators],
                              [build morphological generators @<:@default=yes@:>@])],
              [enable_generators=$enableval],
              [enable_generators=yes])
AM_CONDITIONAL([WANT_GENERATION], [test "x$enable_generators" != xno])

# Enable glossing morphological analysers - default is 'no'
AC_ARG_ENABLE([glossers],
              [AS_HELP_STRING([--enable-glossers],
                              [build glossing morphological analysers @<:@default=no@:>@])],
              [enable_glossers=$enableval],
              [enable_glossers=no])
AM_CONDITIONAL([WANT_GLOSSERS], [test "x$enable_glossers" != xno])

# Enable text transcriptors - default is 'yes'
AC_ARG_ENABLE([transcriptors],
              [AS_HELP_STRING([--enable-transcriptors],
                              [build text transcriptors @<:@default=yes@:>@])],
              [enable_transcriptors=$enableval],
              [enable_transcriptors=yes])
AM_CONDITIONAL([WANT_TRANSCRIPTORS], [test "x$enable_transcriptors" != xno])

# Enable syntactic parsing - default is 'yes'
AC_ARG_ENABLE([syntax],
              [AS_HELP_STRING([--enable-syntax],
                              [build syntax parsing tools @<:@default=yes@:>@])],
              [enable_syntax=$enableval],
              [enable_syntax=yes])
AS_IF([test "x$enable_syntax" = "xyes" -a "x$gt_prog_vislcg3" = "xno"],
             [enable_syntax=no
              AC_MSG_ERROR([vislcg3 tools missing or too old, please install or disable syntax tools!])])
AM_CONDITIONAL([WANT_SYNTAX], [test "x$enable_syntax" != xno])
# $gt_prog_vislcg3

# Enable all spellers - default is 'no'
AC_ARG_ENABLE([spellers],
              [AS_HELP_STRING([--enable-spellers],
                              [build any/all spellers @<:@default=no@:>@])],
              [enable_spellers=$enableval],
              [enable_spellers=no])
AM_CONDITIONAL([WANT_SPELLERS], [test "x$enable_spellers" != xno])

# Enable hfst desktop spellers - default is 'yes' (but dependent on --enable-spellers)
AC_ARG_ENABLE([hfst-dekstop-speller],
              [AS_HELP_STRING([--enable-hfst-dekstop-speller],
                              [build hfst desktop spellers (dependent on --enable-spellers) @<:@default=yes@:>@])],
              [enable_desktop_hfstspeller=$enableval],
              [enable_desktop_hfstspeller=yes])
AS_IF([test "x$enable_spellers" = xno -o "x$gt_prog_hfst" = xno], [enable_desktop_hfstspeller=no],
      [AS_IF([test "x$ZIP" = "xfalse"],
             [enable_desktop_hfstspeller=no
              AC_MSG_ERROR([zip missing - required for desktop zhfst spellers])])])
AM_CONDITIONAL([WANT_HFST_DESKTOP_SPELLER], [test "x$enable_desktop_hfstspeller" != xno])

# Enable minimised fst-spellers by default:
AC_ARG_ENABLE([minimised-spellers],
              [AS_HELP_STRING([--enable-minimised-spellers],
                              [minimise hfst spellers @<:@default=yes@:>@])],
              [enable_minimised_spellers=$enableval],
              [enable_minimised_spellers=yes])
AS_IF([test "x$enable_minimised_spellers" != "xyes"],
      [AC_SUBST([HFST_MINIMIZE_SPELLER], ["$ac_cv_path_HFST_REMOVE_EPSILONS \$(HFST_FLAGS) \
                                         | $ac_cv_path_HFST_PUSH_WEIGHTS -p initial \$(HFST_FLAGS) "])],
      [AC_SUBST([HFST_MINIMIZE_SPELLER], ["$ac_cv_path_HFST_REMOVE_EPSILONS \$(HFST_FLAGS) \
                                         | $ac_cv_path_HFST_PUSH_WEIGHTS -p initial \$(HFST_FLAGS) \
                                         | $ac_cv_path_HFST_DETERMINIZE --encode-weights \$(HFST_FLAGS) \
                                         | $ac_cv_path_HFST_MINIMIZE    --encode-weights "])])

# Enable Foma-based spellers, requires gzip - default is no
AC_ARG_ENABLE([fomaspeller],
              [AS_HELP_STRING([--enable-fomaspeller],
                              [build foma speller (dependent on --enable-spellers) @<:@default=no@:>@])],
              [enable_fomaspeller=$enableval],
              [enable_fomaspeller=no])
AS_IF([test "x$enable_fomaspeller" = "xyes" -a "x$gt_prog_hfst" != xno], 
      [AS_IF([test "x$GZIP" = "xfalse"],
             [enable_fomaspeller=no
              AC_MSG_ERROR([gzip missing - required for foma spellers])])])
AM_CONDITIONAL([CAN_FOMA_SPELLER], [test "x$enable_fomaspeller" != xno])

# Enable hfst mobile spellers - default is 'yes' (but dependent on --enable-spellers)
AC_ARG_ENABLE([hfst-mobile-speller],
              [AS_HELP_STRING([--enable-hfst-mobile-speller],
                              [build hfst mobile spellers (dependent on --enable-spellers) @<:@default=yes@:>@])],
              [enable_mobile_hfstspeller=$enableval],
              [enable_mobile_hfstspeller=yes])
AS_IF([test "x$enable_spellers" = xno -o "x$gt_prog_hfst" = xno], [enable_mobile_hfstspeller=no],
      [AS_IF([test "x$XZ" = "xfalse"],
             [enable_mobile_hfstspeller=no
              AC_MSG_ERROR([xz is missing - required for mobile zhfst spellers])])])
AM_CONDITIONAL([WANT_HFST_MOBILE_SPELLER], [test "x$enable_mobile_hfstspeller" != xno])

# Enable Vfst-based spellers - default is no
AC_ARG_ENABLE([vfstspeller],
              [AS_HELP_STRING([--enable-vfstspeller],
                              [build vfst speller (dependent on --enable-hfst-mobile-speller) @<:@default=no@:>@])],
              [enable_vfstspeller=$enableval],
              [enable_vfstspeller=no])
AS_IF([test "x$enable_vfstspeller" = "xyes" -a "x$enable_mobile_hfstspeller" = xno],
              [enable_vfstspeller=no])
AM_CONDITIONAL([WANT_VFST_SPELLER], [test "x$enable_vfstspeller" != xno])

# Disable Hunspell production by default:
AC_ARG_ENABLE([hunspell],
              [AS_HELP_STRING([--enable-hunspell],
                              [enable hunspell building (dependent on --enable-spellers) @<:@default=no@:>@])],
              [enable_hunspell=$enableval],
              [enable_hunspell=no])
AS_IF([test "x$enable_spellers" = xno], [enable_hunspell=no])
AM_CONDITIONAL([WANT_HUNSPELL], [test "x$enable_hunspell" != xno])

# Enable fst hyphenator - default is 'no'
AC_ARG_ENABLE([fst-hyphenator],
              [AS_HELP_STRING([--enable-fst-hyphenator],
                              [build fst-based hyphenator @<:@default=no@:>@])],
              [enable_fst_hyphenator=$enableval],
              [enable_fst_hyphenator=no])
AM_CONDITIONAL([WANT_FST_HYPHENATOR], [test "x$enable_fst_hyphenator" != xno])

# Enable grammar checkers - default is 'no'
AC_ARG_ENABLE([grammarchecker],
              [AS_HELP_STRING([--enable-grammarchecker],
                              [enable grammar checker @<:@default=no@:>@])],
              [enable_grammarchecker=$enableval],
              [enable_grammarchecker=no])
AS_IF([test "x$enable_grammarchecker" = "xyes" -a "x$gt_prog_vislcg3" = "xno"], 
      [enable_grammarchecker=no
       AC_MSG_ERROR([vislcg3 missing or too old - required for the grammar checker])])
AM_CONDITIONAL([WANT_GRAMCHECK], [test "x$enable_grammarchecker" != xno])

# Enable dictionary transducers - default is 'no'
AC_ARG_ENABLE([dicts],
              [AS_HELP_STRING([--enable-dicts],
                              [enable dictionary transducers @<:@default=no@:>@])],
              [enable_dicts=$enableval],
              [enable_dicts=no])
AM_CONDITIONAL([WANT_DICTIONARIES], [test "x$enable_dicts" != xno])

# Enable Oahpa transducers - default is 'no'
AC_ARG_ENABLE([oahpa],
              [AS_HELP_STRING([--enable-oahpa],
                              [enable oahpa transducers @<:@default=no@:>@])],
              [enable_oahpa=$enableval],
              [enable_oahpa=no])
AM_CONDITIONAL([WANT_OAHPA], [test "x$enable_oahpa" != xno])

# Enable L2 fst's for Oahpa:
AC_ARG_ENABLE([L2],
              [AS_HELP_STRING([--enable-L2],
                              [enable L2 analyser for Oahpa @<:@default=no@:>@])],
              [enable_L2=$enableval],
              [enable_L2=no])
AS_IF([test x$enable_oahpa = xno], [enable_L2=no],
    [AS_IF([test x$enable_L2 != xno -a \
      "$(find ${srcdir}/src -name "*-L2.*" | head -n 1)" = "" ],
      [AC_MSG_ERROR([You asked for the L2 analyser, but no L2 files were found])])])
AM_CONDITIONAL([WANT_L2], [test "x$enable_L2" != xno])

# Enable downcasing error fst's for Oahpa:
AC_ARG_ENABLE([downcaseerror],
              [AS_HELP_STRING([--enable-downcaseerror],
                              [enable downcaseerror analyser for Oahpa @<:@default=no@:>@])],
              [enable_downcaseerror=$enableval],
              [enable_downcaseerror=no])
AS_IF([test x$enable_oahpa = xno], [enable_downcaseerror=no])
AM_CONDITIONAL([WANT_DOWNCASEERROR], [test "x$enable_downcaseerror" != xno])

# Enable IPA conversion - default is 'no'
AC_ARG_ENABLE([phonetic],
              [AS_HELP_STRING([--enable-phonetic],
                              [enable phonetic transducers @<:@default=no@:>@])],
              [enable_phonetic=$enableval],
              [enable_phonetic=no])
AM_CONDITIONAL([WANT_PHONETIC], [test "x$enable_phonetic" != xno])

# Enable Apertium transducers - default is 'no'
AC_ARG_ENABLE([apertium],
              [AS_HELP_STRING([--enable-apertium],
                              [enable apertium transducers @<:@default=no@:>@])],
              [enable_apertium=$enableval],
              [enable_apertium=no])
AS_IF([test "x$enable_apertium" = "xyes" -a "x$new_enough_python_available" = "xno"], 
      [enable_apertium=no
       AC_MSG_ERROR([Python3 missing or too old, Python 3.3 or newer required])])
AM_CONDITIONAL([WANT_APERTIUM], [test "x$enable_apertium" != xno])

# Enable building of abbr.txt:
AC_ARG_ENABLE([abbr],
              [AS_HELP_STRING([--enable-abbr],
                              [enable generation of abbr.txt @<:@default=no@:>@])],
              [enable_abbr=$enableval],
              [enable_abbr=no])
AS_IF([test x$enable_abbr != xno -a \
    "$(find ${srcdir}/src/morphology/stems/ -name "abbreviations.lexc" | head -n 1)" = "" ],
    [AC_MSG_ERROR([You asked for abbr.txt generation, but have no file \
src/morphology/stems/abbreviations.lexc])])
AS_IF([test x$enable_abbr == xyes -a x$enable_generators == xno],
    [AC_MSG_ERROR([You need to enable generators to build the abbr file])])
AM_CONDITIONAL([WANT_ABBR], [test "x$enable_abbr" != xno])

# Enable building tokenisers - default is 'no'
AC_ARG_ENABLE([tokenisers],
              [AS_HELP_STRING([--enable-tokenisers],
                              [enable tokenisers @<:@default=no@:>@])],
              [enable_tokenisers=$enableval],
              [enable_tokenisers=no])
AS_IF([test x$enable_tokenisers == xyes -a x$enable_analysers == xno],
    [AC_MSG_ERROR([You need to enable analysers to build tokenisers])])
AM_CONDITIONAL([WANT_TOKENISERS], [test "x$enable_tokenisers" != xno])

# Enable building morphers - default is 'no'
AC_ARG_ENABLE([morpher],
              [AS_HELP_STRING([--enable-morpher],
                              [enable morphological segmenter @<:@default=no@:>@])],
              [enable_morpher=$enableval],
              [enable_morpher=no])
AM_CONDITIONAL([WANT_MORPHER], [test "x$enable_morpher" != xno])

]) # gt_ENABLE_TARGETS

################################################################################
# Define function to print the configure footer
################################################################################
AC_DEFUN([gt_PRINT_FOOTER],
[
cat<<EOF

-- Building $PACKAGE_STRING:

  -- Fst build tools: Xerox, Hfst or Foma - at least one must be installed
  -- Xerox is default on, the others off unless they are the only one present --
  * build Xerox fst's: $gt_prog_xfst
  * build HFST fst's: $gt_prog_hfst
  * build Foma fst's: $gt_prog_foma

  -- basic packages (on by default): --
  * analysers enabled: $enable_analysers
  * generators enabled: $enable_generators
  * transcriptors enabled: $enable_transcriptors
  * syntactic tools enabled: $enable_syntax
  * yaml tests enabled: $enable_yamltests
  * generated documentation enabled: $gt_prog_docc

  -- proofing tools (off by default): --
  * spellers enabled: $enable_spellers
    * desktop spellers:
      * hfst speller enabled: $enable_desktop_hfstspeller
      * foma speller enabled: $enable_fomaspeller
    * mobile spellers:
      * hfst speller enabled: $enable_mobile_hfstspeller
      * vfst speller enabled: $enable_vfstspeller
  * grammar checker enabled: $enable_grammarchecker

  -- specialised fst's (off by default): --
  * phonetic/IPA conversion enabled: $enable_phonetic
  * dictionary fst's enabled: $enable_dicts
  * Oahpa transducers enabled: $enable_oahpa
    * L2 analyser: $enable_L2
    * downcase error analyser: $enable_downcaseerror
  * Apertium transducers enabled: $enable_apertium
  * generate abbr.txt: $enable_abbr
  * build tokenisers: $enable_tokenisers
  * build glossing fst's: $enable_glossers
  * build morphololgical segmenter: $enable_morpher

For more ./configure options, run ./configure --help

To build, test and install:
    make
    make check
    make install
EOF
AS_IF([test x$gt_prog_xslt = xno -a \
      "$(find ${srcdir}/src/morphology/stems -name "*.xml" | head -n 1)" != "" ],
      [AC_MSG_WARN([You have XML source files, but XML transformation to LexC is
disabled. Please check the output of configure to locate any problems.
])])
AS_IF([test x$gt_prog_docc = xno],
      [AC_MSG_WARN([Could not find gawk, java or forrest. In-source documentation will not be extracted and validated. Please install the required tools.])])

dnl stick important warnings to bottom
dnl YAML test warning:
AS_IF([test "x$enable_yamltests" == "xno"],
      [AC_MSG_WARN([YAML testing could not be automatically enabled. To enable it, on MacOSX please do:

sudo port install python33
sudo port install py-yaml subport=py33-yaml

On other systems, install python 3.3+ and the corresponding py-yaml using suitable tools for those systems.])])

]) # gt_PRINT_FOOTER
# vim: set ft=config: 
