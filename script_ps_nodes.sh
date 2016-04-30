#OUTPUT_STATS=out_stats.dat
#PLOT_THROUGHPUT=out_throughput.dat
THROUGHPUT_IMG=throughput_img_psn.png

rm out_stats_psn_*
rm plot_throughput_psn_*

for packetSize in 50 100 500 1000 1500
do
	for node in $(seq 5) 
	do
		echo -ne "Computing throughput for $node nodes with packet size $packetSize ... "
		./waf --run "scratch/wireless --nodes=$node --packetSize=$packetSize" >> out_stats_psn_$packetSize.dat
		echo "Complete"
	done

	sed -i "/\b\(waf\|build\|Compiling\)\b/d" out_stats_psn_$packetSize.dat
	cut -f1,5 out_stats_psn_$packetSize.dat > plot_throughput_psn_$packetSize.dat
done

gnuplot <<- EOF
set xrange [0:]
set xlabel "Number of nodes"
set ylabel "Average Throughput (Mbps)"
set title "Average throughput vs Packet size (different num. of nodes)"
set term png
set output "$THROUGHPUT_IMG"
set style data linespoints
plot 'plot_throughput_psn_50.dat' w l lc rgb 'yellow' title "50 bytes", \
'plot_throughput_psn_100.dat' w l lc rgb 'green' title "100 bytes",'plot_throughput_psn_500.dat' w l lc rgb 'blue' title "500 bytes",'plot_throughput_psn_1000.dat' w l lc rgb 'red' title "1000 bytes",  'plot_throughput_psn_1500.dat' w l lc rgb 'orange' title "1500 bytes"
EOF
xdg-open $THROUGHPUT_IMG
