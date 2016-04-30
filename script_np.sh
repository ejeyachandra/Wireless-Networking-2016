#OUTPUT_STATS=out_stats.dat
#PLOT_THROUGHPUT=out_throughput.dat
THROUGHPUT_IMG=throughput_image_numPackets.png

rm out_stats_np_*
rm plot_throughput_np_*

for numPackets in 50 100 500 1000 5000 10000 50000
do
#	for node in $(seq 5) 
#	do
		echo -ne "Computing throughput for 5 nodes with number of packets = $numPackets ... "
		./waf --run "scratch/wireless --numPackets=$numPackets" >> out_stats_np_$numPackets.dat
		echo "Complete"
#	done
#
	sed -i "/\b\(waf\|build\|Compiling\)\b/d" out_stats_np_$numPackets.dat
	cut -f2,5 out_stats_np_$numPackets.dat > plot_throughput_np_$numPackets.dat
done

gnuplot <<- EOF
set xlabel "Number of Packets"
set ylabel "Average Throughput (Mbps)"
set title "Average throughput vs Num. of packets"
set term png
set output "$THROUGHPUT_IMG"
set style fill solid
plot [-0.5:][0:800] 'plot_throughput_np_50.dat' u 2: xtic(1) with histogram title "50 packets", 'plot_throughput_np_100.dat' u 2: xtic(1) with histogram title "100 packets", 'plot_throughput_np_500.dat' u 2: xtic(1) with histogram title "500 packets", 'plot_throughput_np_1000.dat' u 2: xtic(1) with histogram title "1000 packets", 'plot_throughput_np_5000.dat' u 2: xtic(1) with histogram title "5000 packets", 'plot_throughput_np_10000.dat' u 2: xtic(1) with histogram title "10000 packets", 'plot_throughput_np_50000.dat' u 2: xtic(1) with histogram title "50000 packets"

EOF
xdg-open $THROUGHPUT_IMG
