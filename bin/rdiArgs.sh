#!/bin/bash
#
# COPYRIGHT NOTICE
# Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
#

#
# Default to OS platform options
#
if [ "$RDI_OS_ARCH" == "64" ]; then
  RDI_PLATFORM=lnx64
  RDI_JAVA_PLATFORM=amd64
else
  RDI_PLATFORM=lnx32
  RDI_JAVA_PLATFORM=i386
fi
export RDI_PLATFORM RDI_JAVA_PLATFORM

export RDI_OPT_EXT=.o

argSize=0
RDI_ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -m32)
      RDI_PLATFORM=lnx32
      RDI_JAVA_PLATFORM=i386
      export RDI_PLATFORM RDI_JAVA_PLATFORM
      shift
      ;;
    -m64)
      if [ "$RDI_OS_ARCH" == "64" ]; then
        RDI_PLATFORM=lnx64
        RDI_JAVA_PLATFORM=amd64
        export RDI_PLATFORM RDI_JAVA_PLATFORM
      else 
        echo "WARNING: 64bit architecture not detected. Defaulting to 32bit."
      fi
      shift
      ;;
    -exec)
      #
      # We don't create an RDI_EXE_COMMANDS function and just overload the RDI_PROG variable,
      # so additional debug options can be used with -exec.
      #
      # For example: 
      #  -dbg -gdb -exec foo 
      #
      # Will launch the debuggable foo executable in gdb.
      #
      shift
      RDI_PROG=$1
      shift
      ;;
    *)
      RDI_ARGS[$argSize]="$1"
      argSize=$(($argSize + 1))
      shift
      ;;
  esac
done

if [ -z "$RDI_VERBOSE" ]; then
    RDI_VERBOSE=False
fi

# Default don't check TclDebug by
if [ -z "$XIL_CHECK_TCL_DEBUG" ]; then
  export XIL_CHECK_TCL_DEBUG=False
fi

RDI_DATADIR="$RDI_APPROOT/data"
IFS=$':'
for SUB_PATCH in $RDI_PATCHROOT; do
    if [ -d "$SUB_PATCH/data" ]; then
        RDI_DATADIR="$SUB_PATCH/data:$RDI_DATADIR"
    fi
done
IFS=$' \t\n'

RDI_JAVAROOT="$RDI_APPROOT/tps/$RDI_PLATFORM/jre"

#Locate RDI_JAVAROOT in patch areas.
IFS=$':'
for SUB_PATCH in $RDI_PATCHROOT; do
    if [ -d "$SUB_PATCH/tps/$RDI_PLATFORM/jre" ]; then
        RDI_JAVAROOT="$SUB_PATCH/tps/$RDI_PLATFORM/jre"
    fi
done
IFS=$' \t\n'

export RDI_DATADIR

#
# Strip /planAhead off %RDI_APPROOT% to discovery the
# common ISE installation.
#
# For separated vivado installs ISE is located under %RDI_APPROOT%/ids_lite
#
if [ "$XIL_PA_NO_XILINX_OVERRIDE" != "1" ]; then
  if [ "$XIL_PA_NO_DEFAULT_OVERRIDE" != "1" ]; then
    unset XILINX
  fi
  if [ -d "$RDI_APPROOT/ids_lite/ISE" ]; then
    XILINX="$RDI_APPROOT/ids_lite/ISE"
    export XILINX
  else
    if [ -d "$RDI_BASEROOT/ISE" ]; then
      XILINX="$RDI_BASEROOT/ISE"
      export XILINX
    fi
  fi
fi

RDI_INSTALLVERSION=`basename "$RDI_APPROOT"`
RDI_INSTALLROOT=`dirname "$RDI_APPROOT"`
RDI_INSTALLROOT=`dirname "$RDI_INSTALLROOT"`
if [ "$XIL_PA_NO_XILINX_SDK_OVERRIDE" != "1" ]; then
  if [ -d "$RDI_INSTALLROOT/SDK/$RDI_INSTALLVERSION" ]; then
    XILINX_SDK="$RDI_INSTALLROOT/SDK/$RDI_INSTALLVERSION"
    export XILINX_SDK
  elif [ -d "$RDI_BASEROOT/SDK" ]; then
    XILINX_SDK="$RDI_BASEROOT/SDK"
    export XILINX_SDK
  fi
fi

IFS=$':'
for DEPENDENCY in $RDI_DEPENDENCY; do
  case "$DEPENDENCY" in
    XILINX_VIVADO)
      if [ -z "$XILINX_VIVADO" ]; then
        # locate parallel install
        if [ -d "$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION" ]; then
          XILINX_VIVADO="$RDI_INSTALLROOT/Vivado/$RDI_INSTALLVERSION"
          export XILINX_VIVADO
          PATH=$XILINX_VIVADO/bin:$PATH
          export PATH
        # locate parallel install
        elif [ -d "$RDI_BASEROOT/Vivado" ]; then
          XILINX_VIVADO="$RDI_BASEROOT/Vivado"
          export XILINX_VIVADO
          PATH=$XILINX_VIVADO/bin:$PATH
          export PATH
        else
          echo "WARNING: Default location for XILINX_VIVADO not found: $VIVADO_DEFAULT"
        fi
      fi
      ;;
    XILINX_VIVADO_HLS)
      if [ -z "$XILINX_VIVADO_HLS" ]; then
        # locate parallel install
        if [ -d "$RDI_INSTALLROOT/Vivado_HLS/$RDI_INSTALLVERSION" ]; then
          XILINX_VIVADO_HLS="$RDI_INSTALLROOT/Vivado_HLS/$RDI_INSTALLVERSION"
          export XILINX_VIVADO_HLS
          PATH=$XILINX_VIVADO_HLS/bin:$PATH
          export PATH
        # locate parallel install
        elif [ -d "$RDI_BASEROOT/Vivado_HLS" ]; then
          XILINX_VIVADO_HLS="$RDI_BASEROOT/Vivado_HLS"
          export XILINX_VIVADO_HLS
          PATH=$XILINX_VIVADO_HLS/bin:$PATH
          export PATH
        else
          echo "WARNING: Default location for XILINX_VIVADO_HLS not found: $HLS_DEFAULT"
        fi
      fi
      ;;
  esac
done
IFS=$' \t\n'
unset RDI_DEPENDENCY

if [ -d "$RDI_BASEROOT/common" ]; then
  XILINX_COMMON_TOOLS="$RDI_BASEROOT/common"
  export XILINX_COMMON_TOOLS
fi

RDI_EXEC_COMMANDS() {
  "$RDI_PROG" "$@"
  return
}

RDI_JAVA_COMMANDS() {
  IFS=$':'
  if [ -z "$RDI_EXECCLASS" ]; then
    RDI_EXECCLASS="ui/PlanAhead"
  fi
  if [ -z "$RDI_JAVAARGS" ]; then
    RDI_JAVAARGS="-Dsun.java2d.pmoffscreen=false -Xms128m -Xmx512m -Xss5m"
  fi
  for SUB_ROOT in $RDI_APPROOT; do
    if [ -d "$SUB_ROOT/lib/classes" ]; then
      if [ -z "$RDI_CLASSPATH" ]; then
        RDI_CLASSPATH="$SUB_ROOT/lib/classes/*"
      else
        RDI_CLASSPATH="$RDI_CLASSPATH:$SUB_ROOT/lib/classes/*"
      fi
    fi
  done
  IFS=$' \t\n'
  if [ "$RDI_VERBOSE" = "True" ]; then
    echo "\"$RDI_JAVAROOT/bin/java\" $RDI_JAVAARGS -classpath \"$RDI_CLASSPATH\" $RDI_EXECCLASS $@"
  fi
  RDI_START_FROM_JAVA=True
  export RDI_START_FROM_JAVA
  "$RDI_JAVAROOT/bin/java" $RDI_JAVAARGS -classpath "$RDI_CLASSPATH" "$RDI_EXECCLASS" "$@"
  return
}


# XSIP watermark, do not delete 67d7842dbbe25473c3c32b93c0da8047785f30d78e8a024de1b57352245f9689
