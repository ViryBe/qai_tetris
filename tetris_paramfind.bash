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
TETRIS_CMD="$( dirname ${BASH_SOURCE[0]} )/tetris_player.opt"

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

ALP=( 0.0001 0.0005 0.0007 0.0010 0.0012 0.0015 0.0020 0.0050 0.0100 )
EPS=( 0.0005 0.0010 0.0015 0.0020 0.0025 0.0100 0.0200 0.1000 0.1500 )
GAM=( 0.5500 0.6000 0.6500 0.7000 0.7500 0.8000 0.8500 0.9000 0.9500 1.0000 )

for a in ${ALP[@]} ; do
	for e in ${EPS[@]} ; do
		for g in ${GAM[@]} ; do
			$TETRIS_CMD -ngames $NGAMES -ntetr $NTETR -alphap $a -epsilon $e \
				-gamma $g >> $OUT
			echo "a=$a e=$e g=$g" >> $OUT
			echo "a=$a e=$e g=$g"
		done ;
	done ;
done ;
