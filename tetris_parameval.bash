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
\t--ntetr\t\t<int>\tnumber of tetrominos in a game
\t-o|--out\t\tfile to output"

# Tetris player related options
TETRIS_CMD="$( dirname ${BASH_SOURCE[0]} )/tetris_player.opt"

BASEFNAME='gplot'   # beginning of file names
BCSCALE=4           # number of decimals after dot

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
OUTFILE=''      # name of output file

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
			LOW=$2
			shift 2
			continue
			;;
		'-u'|'--up')
			UP=$2
			shift 2
			continue
			;;
		'-s'|'--step')
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
            # -l for floating point
			step=$(echo "scale=$BCSCALE ; ($UP - $LOW) / $nval" | bc -l)
			;;
		*)
			echo 'rangespec not properly set'
			echo -e "$USAGE"
			exit 1
			;;
	esac

	for i in $(seq 0 $nval) ; do
		nv=$(echo "scale=$BCSCALE ; $LOW + $i * $step" | bc -l)
		PVAL[$i]=$nv
		FILES[$i]="${BASEFNAME}$PARAM$i.log"
	done ;
	return 0
}

# Run tetris_player and save output to files
function run_tetris () {
	ntr=${#PVAL[@]}
	for i in $(seq 0 $((ntr - 1))) ; do
		$TETRIS_CMD -ngames $NGAMES -ntetr $NTETR -$PARAM ${PVAL[$i]} > \
			"${FILES[$i]}"

        if [[ $? -eq 0 ]] ; then
          echo "Done training with $PARAM=${PVAL[$i]} ($((i + 1))/$ntr)"
        else
          echo "Error calling function"
          exit 1
        fi
	done ;
	return 0
}

# Set name if not provided
if [[ $OUTFILE == '' ]] ; then
  OUTFILE="$BASEFNAME_$PARAM.dat"
fi

make_values
run_tetris
for i in $(seq 0 $((${#PVAL[@]} - 1))); do
	sed -i "s/^#.*$/${PVAL[$i]}/" "${FILES[$i]}"
done ;
paste "${FILES[@]}" > "$OUTFILE"
for file in ${FILES[@]} ; do
  rm $file
done;

# plot
gnuplot -p -e "set key autotitle columnheader;\
	set title '$PARAM' ;\
	plot for [col=1:${#PVAL[@]}] '$OUTFILE' using 0:col"
