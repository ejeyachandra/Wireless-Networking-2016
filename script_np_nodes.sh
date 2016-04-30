#OUTPUT_STATS=out_stats.dat
#PLOT_THROUGHPUT=out_throughput.dat
THROUGHPUT_IMG=throughput_img_npn.png

rm out_stats_npn_*
rm plot_throughput_npn_*

for numPackets in 50 100 500 1000 5000 10000
do
	for node in $(seq 5) 
	do
		echo -ne "Computing throughput for $node nodes with number of packets = $numPackets ... "
		./waf --run "scratch/wireless --nodes=$node --numPackets=$numPackets" >> out_stats_npn_$numPackets.dat
		echo "Complete"
	done

	sed -i "/\b\(waf\|build\|Compiling\)\b/d" out_stats_npn_$numPackets.dat
	cut -f1,5 out_stats_npn_$numPackets.dat > plot_throughput_npn_$numPackets.dat
done

gnuplot <<- EOF
set xrange [0:]
set xlabel "Number of nodes"
set ylabel "Average Throughput (Mbps)"
set title "Average throughput vs Num. of packets (different num. of nodes)"
set term png
set output "$THROUGHPUT_IMG"
set style data linespoints
plot 'plot_throughput_npn_50.dat' w l lc rgb 'yellow' title "50 packets", \
'plot_throughput_npn_100.dat' w l lc rgb 'green' title "100 packets",'plot_throughput_npn_500.dat' w l lc rgb 'blue' title "500 packets",'plot_throughput_npn_1000.dat' w l lc rgb 'red' title "1000 packets",  'plot_throughput_npn_5000.dat' w l lc rgb 'orange' title "5000 packets", 'plot_throughput_npn_10000.dat' w l lc rgb 'black' title "10000 packets"
EOF
xdg-open $THROUGHPUT_IMG
