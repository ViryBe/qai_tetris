#!/bin/bash

# Set getopt options
NAME='tetris_argeval.bash'
# Short options, add a column for required arg, two for optional
OPTIONS=hp:l:u:s:n:o:
# Long options, names separated with commas
LONGOPTIONS=help,param:,low:,up:,step:,nval:,ngames:,ntetr:,out:
# Usage string
USAGE="Usage: $0 PARAM BOUNDS BOUNDSP -o <out> [OPTIONS]
Param:
\t-p|--param\t<epsilon|gamma|alphap>\tthe parameter tested
Bounds:
\t-l|--low\t<low>\tlower bound
\t-u|--up\t\t<up>\tguess what...
Bounds parameters: one of the following
\t-s|--step\t<float>\tthe step between two consecutive values
\t-n|--nval\t<int>\tthe number of values desired
Options:
\t--ngames\t<int>\tnumber of games done in one training
\t--ntetr\t\t<int>\tnumber of tetrominos in a game"

# Tetris player related options
TETRIS_CMD='tetris_player.opt'

BASEFNAME='gplot'
OUTFILE='gplot_param.log'

# Options of the tetris_player
PARAM='' 		# parameter to be tested
RANGESPEC='' 	# step or number of values
RANGEPVAL=0		# value of parsing spec
LOW=''			# low bound of the range
UP=''			# up bound of the range
NTETR=10000		# number of tetrominos to be played
NGAMES=512		# number of games per training
PVAL=( )		# param values, array
FILES=( )		# name of files

TEMP=$(getopt -o $OPTIONS --long $LONGOPTIONS -n $NAME -- "$@")

if [[ $? -ne 0 ]]; then
	echo "Terminating..." >&2
	exit 1
fi

eval set -- "$TEMP"
unset TEMP
while true; do
	case "$1" in
		'-p'|'--param')
			PARAM=$2
			shift 2
			continue
			;;
		'-l'|'--low')
			echo "low bound: $2"
			LOW=$2
			shift 2
			continue
			;;
		'-u'|'--up')
			echo "up bound: $2"
			UP=$2
			shift 2
			continue
			;;
		'-s'|'--step')
			echo "step $2"
			if [[ $RANGESPEC != '' ]]; then
				echo 'number of values already specified'
				echo "$USAGE"
				exit 1
			fi
			RANGESPEC='step'
			RANGEPVAL=$2
			shift 2
			continue
			;;
		'-n'|'--nval')
			echo "nval $2"
			if [[ $RANGESPEC != '' ]]; then
				echo 'step already specified'
				echo -e "$USAGE"
				exit 1
			fi
			RANGESPEC='nval'
			RANGEPVAL=$2
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
		'-o'|'--out')
			OUTFILE=$2
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

# Fills an array with to be tested parameter values
function make_values () {
	case $RANGESPEC in
		'step')
			step=$RANGEPVAL
			nval=$(echo "($UP - $LOW) / $step" | bc)
			;;
		'nval')
			nval=$((RANGEPVAL - 1))
			step=$(echo "($UP - $LOW) / $nval" | bc -l) # -l for floating point
			;;
		*)
			echo 'rangespec not properly set'
			echo -e "$USAGE"
			exit 1
			;;
	esac

	for i in $(seq 0 $nval) ; do
		nv=$(echo "$LOW + $i * $step" | bc)
		PVAL[$i]=$nv
		FILES[$i]="${BASEFNAME}$PARAM$i.log"
	done ;
	return 0
}

# Run tetris_player and save output to files
function run_tetris () {
	ntr=${#PVAL[@]}
	for i in $(seq 0 $((ntr - 1))) ; do
		./$TETRIS_CMD -ngames $NGAMES -ntetr $NTETR -$PARAM ${PVAL[$i]} > \
			"${FILES[$i]}"

		echo "Done training with $PARAM=${PVAL[$i]} ($((i + 1))/$ntr)"
	done ;
	return 0
}

make_values
run_tetris
for i in $(seq 0 $((${#PVAL[@]} - 1))); do
	sed -i "s/^#.*$/${PVAL[$i]}/" "${FILES[$i]}"
done ;
paste "${FILES[@]}" > "$OUTFILE"

# plot
gnuplot -p -e "set key autotitle columnheader;\
	set title '$PARAM' ;\
	plot for [col=1:${#PVAL[@]}] '$OUTFILE' using 0:col"
