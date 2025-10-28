#!/usr/bin/env bash
set -ex
OPENSCADURL=https://files.openscad.org/snapshots/OpenSCAD-2025.10.26.ai28706-x86_64.AppImage 
OPENSCADDIR=.openscad
OPENSCADBIN="$OPENSCADDIR/openscad"
OPENSCADPATH="$OPENSCADDIR/libs"
NOPSCADLIB_COMMIT=c9baa0ed0faa23e849141c3d8c6728545d6af910
STLS_DIR=stls

prepare() (
	[ -d "$STLS_DIR" ] || mkdir -p "$STLS_DIR"

	# install openscad
	if [ ! -d "$OPENSCADDIR" ]; then 
		mkdir -p "$OPENSCADDIR"
		wget ${OPENSCADURL} -O "$OPENSCADBIN"
		chmod a+x "$OPENSCADBIN"

		# install NopSCADlib
		git init "$OPENSCADPATH/NopSCADlib"
		cd "$OPENSCADPATH/NopSCADlib"
		git remote add origin https://github.com/nophead/NopSCADlib
		git fetch --depth 1 origin ${NOPSCADLIB_COMMIT}
		git checkout ${NOPSCADLIB_COMMIT}
	fi

)

export OPENSCADPATH
prepare

if [ "$#" -eq 0 ]; then
	"$OPENSCADBIN" "$@"
elif [ "$1" = "build" ]; then
	rm -rf stls/*.stl
	"$OPENSCADBIN" --hardwarnings -D outputs=10 -D'$part="box"' -o stls/banana_6_extender_box.stl bananas_extender.scad
	"$OPENSCADBIN" --hardwarnings -D outputs=100 -D'$part="base"' -o stls/banana_6_extender_base.stl bananas_extender.scad

else
	echo Unknown command "$1"
	exit 1
fi
