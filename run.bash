#!/bin/bash

# Init
export BOLT_CONFIG=.bolt.conf
EPS=0.5
GAM=0.2
ALP=18.0
NGAMES=20

./tetris_player.opt -demo false -ngames $NGAMES -gamma $GAM -epsilon $EPS \
	-alphap $ALP
