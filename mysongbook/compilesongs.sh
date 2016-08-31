#!/bin/bash

if [ $# -gt 0 ] ; then
	echo "Usage: compilesongs.sh"
	exit -1
fi

FILES=""

MYVIEWER=evince
TMP_BUILD_DIR=/tmp/songbuild

CURRENT_DIR=$PWD
TEXCMD=pdflatex
TEXMODE=
TRG_FORMAT=pdf
IM_TRG_FORMAT=pdf
FEXT=tex
BUILD_TEX=automaticsongbuild

mkdir -p $TMP_BUILD_DIR
for f in $(find songs/ -type f -name \*.$FEXT); do
	FILE="${f##*/}"
	FILEBASE=${f%.*}
	DIR="${f:0:${#f} - ${#FILE}}"
	TRGNAME=$FILEBASE.$IM_TRG_FORMAT
	FILES="$FILES $TRGNAME"

	cp MySongBookPreamble.tex $TMP_BUILD_DIR/$BUILD_TEX.tex
	echo "\\begin{document}" >> $TMP_BUILD_DIR/$BUILD_TEX.tex
	cat $DIR/$FILE >> $TMP_BUILD_DIR/$BUILD_TEX.tex
	echo "\\end{document}" >> $TMP_BUILD_DIR/$BUILD_TEX.tex
	$TEXCMD -interaction=errorstopmode -output-directory=$TMP_BUILD_DIR -output-format $IM_TRG_FORMAT $TMP_BUILD_DIR/$BUILD_TEX.tex
	$TEXCMD -interaction=nonstopmode -output-directory=$TMP_BUILD_DIR -output-format $IM_TRG_FORMAT $TMP_BUILD_DIR/$BUILD_TEX.tex
	mv $TMP_BUILD_DIR/$BUILD_TEX.$IM_TRG_FORMAT $TRGNAME

	if [ 0 == 1 ] ; then
	if [ -f $TRGNAME ] ; then
		echo "opening viewer..."
		if [ ! "$(which xdotool)" = "" ] ; then
			WID="$(xdotool search --name $TRGNAME | head -1)"
			if [ "$WID" = "" ] ; then
				$MYVIEWER $TRGNAME &
			else
				$MYVIEWER $TRGNAME &
				xdotool windowactivate --sync $WID
			fi
		else
			$MYVIEWER $TRGNAME &
		fi
	fi
	fi
done
rm -Rf $TMP_BUILD_DIR

TRGNAME=MySongBook.pdf
GSCMD="gs -sDEVICE=pdfwrite -q -dNOPAUSE -dBATCH -sOutputFile=$TRGNAME"
$GSCMD $FILES
if [ -f $TRGNAME ] ; then
	echo "opening viewer..."
	if [ ! "$(which xdotool)" = "" ] ; then
		WID="$(xdotool search --name $TRGNAME | head -1)"
		if [ "$WID" = "" ] ; then
			$MYVIEWER $TRGNAME &
		else
			$MYVIEWER $TRGNAME &
			xdotool windowactivate --sync $WID
		fi
	else
		$MYVIEWER $TRGNAME &
	fi
fi


