rm -f a.out
iverilog -DBENCH -DSIM -DBOARD_FREQ=10 bench_iverilog.v $1 $2
vvp a.out
