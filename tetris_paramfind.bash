#!/bin/bash
NAME=$0

OPTIONS=ho:

LGOPTIONS=help,ngames:,ntetr:,out:

USAGE="Usage: $0 [--ngames <ngames>] [--ntetr <ntetr>] [-o <out> ]
Param:
\t-o|--out\t<file>\toutput
\t--ngames\t<ngames>\tnumber of games played for each training
\t--ntetr\t<ntetr>\tnumber of tetrominos in each game"

NGAMES=512
NTETR=10000
OUT='/dev/stdout'

TEMP=$( getopt -o $OPTIONS --long $LGOPTIONS -n $NAME -- "$@" )

if [[ $? -ne 0 ]] ; then
	echo "Termingating..." >&2
	exit 1
fi

eval set -- "$TEMP"
unset TEMP

while true ; do
	case "$1" in
		'-o'|'--out')
			OUT=$2
			shift 2
			continue
			;;
		'--ngames')
			NGAMES=$2
			shift 2
			continue
			;;
		'--ntetr')
			NTETR=$2
			shift 2
			continue
			;;
		'--')
			shift
			break
			;;
		'-h'|'--help'|*)
			echo -e "$USAGE"
			exit 1
			;;
	esac
done

ALP=( 0.002 0.004 0.006 )
EPS=( 0.0002 0.0006 0.0012 )
GAM=( 0.7 0.8 0.9 )

for a in ${ALP[@]} ; do
	for e in ${EPS[@]} ; do
		for g in ${GAM[@]} ; do
			$TETRIS_CMD -ngames $NGAMES -ntetr $NTETR -alphap $a -epsilon $e \
				-gamma $g > $OUT
			echo "a=$a,e=$e,g=$g"
		done ;
	done ;
done ;
