#!/bin/bash

# Set getopt options
NAME='tetris_argeval.bash'
# Short options, add a column for required arg, two for optional
OPTIONS=hegal:u:s:n:o:
# Long options, names separated with commas
LONGOPTIONS=help,epsilon,gamma,alphap,low:,up:,step:,nval:,ngames:,ntetr:,out:
# Usage string
USAGE="Usage: $0 PARAM BOUNDS BOUNDSP -o|--out <out> [OPTIONS]
Param: one of the following
\t-e|--epsilon\tfrequency of random choice
\t-g|--gamma\tsight length of the agent
\t-a|--alphap\tlearning rate parameter
Bounds:
\t-l|--low <low>\tlower bound
\t-u|--up <up>\tguess what...
Bounds parameters: one of the following
\t-s|--step <float>\tthe step between two consecutive values
\t-n|--nval <int>\tthe number of values desired
Options:
\t--ngames <int>\tnumber of games done in one training
\t--ntetr <int>\tnumber of tetrominos in a game"

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
		'-h'|'--help')
			echo -e "$USAGE"
			exit 1
			;;
		'-e'|'--epsilon')
			echo "selected epsilon"
			if [[ $PARAM != '' ]]; then
				echo 'parameter already set!'
				echo "$USAGE"
				exit 1
			fi
			PARAM='epsilon'
			shift
			continue
			;;
		'-g'|'--gamma')
			echo "selected gamma"
			if [[ $PARAM != '' ]]; then
				echo 'parameter already set!'
				echo "$USAGE"
				exit 1
			fi
			PARAM='gamma'
			shift
			continue
			;;
		'-a'|'--alphap')
			echo 'selected alpha'
			if [[ $PARAM != '' ]]; then
				echo 'parameter already set!'
				echo -e "$USAGE"
				exit 1
			fi
			PARAM='alphap'
			shift
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
		*)
			echo 'Internal error!' >&2
			echo -e "$USAGE"
			exit 1
			;;
	esac
done
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

function run_tetris () {
	ntr=${#PVAL[@]}
	cnt=0
	gamesarr=( )
	for i in $(seq 0 $((ntr - 1))) ; do
		./$TETRIS_CMD -ngames $NGAMES -ntetr $NTETR -$PARAM ${PVAL[$i]} > \
			"${FILES[$i]}"

		cnt=$((cnt + 1))
		echo "Done training with $PARAM=${PVAL[$i]} ($cnt/$ntr)"
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
