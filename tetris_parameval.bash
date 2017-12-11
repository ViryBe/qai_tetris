#!/usr/bin/bash

# Set getopt options
NAME='tetris_argeval.bash'
# Short options, add a column for required arg, two for optional
OPTIONS=egal:u:s:n:
# Long options, names separated with commas
LONGOPTIONS=epsilon,gamma,alphap,low:,up:,step:,nval:,ngames:

# Tetris player related options
TETRIS_CMD='tetris_player.opt'

# Options of the tetris_player
PARAM='' 		# parameter to be tested
RANGESPEC='' 	# step or number of values
RANGEPVAL=0		# value of parsing spec
LOW=''			# low bound of the range
UP=''			# up bound of the range
PVAL=( )		# param values, array
declare -A RHEIGHTS 	# heights in a matrix

TEMP=$(getopt -o $OPTIONS --long $LONGOPTIONS -n $NAME -- "$@")

if [[ $? -ne 0 ]]; then
	echo "Terminating..." >&2
	exit 1
fi

eval set -- "$TEMP"
unset TEMP
while true; do
	case "$1" in
		'-e'|'--epsilon')
			echo "selected epsilon"
			if [[ $PARAM != '' ]]; then
				echo 'parameter already set!'
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
				exit 1
			fi
			RANGESPEC='nval'
			RANGEPVAL=$2
			shift 2
			continue
			;;
		'--')
			shift
			break
			;;
		*)
			echo 'Internal error!' >&2
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
			nval=$RANGEPVAL
			step=$(echo "($UP - $LOW) / $nval" | bc)
			;;
		*)
			echo 'rangespec not properly set'
			exit 1
			;;
	esac

	for i in $(seq 1 $nval) ; do
		nv=$(echo "$i * $step" | bc)
		PVAL+=( $nv )
	done ;
	return 0
}

function run_tetris () {
	for p in $PVAL ; do
		exec "$TETRIS_CMD -ngames 512 -ntetr 10000 -$PARAM $p"
	done ;
	return 0
}

make_values
run_tetris
