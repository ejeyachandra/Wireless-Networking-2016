#OUTPUT_STATS=out_stats.dat
#PLOT_THROUGHPUT=out_throughput.dat
THROUGHPUT_IMG=throughput_img_npr.png

rm out_stats_npr_*
rm plot_throughput_npr_*

for rate in 1 2 5 11
do
	for numPackets in 50 100 500 1000 5000 10000 
	do
		echo -ne "Computing throughput for number of packets $numPackets with rate $rate Mbps ... "
		./waf --run "scratch/wireless --numPackets=$numPackets --rate=$rate" >> out_stats_npr_$rate.dat
		echo "Complete"
	done

	sed -i "/\b\(waf\|build\|Compiling\)\b/d" out_stats_npr_$rate.dat
	cut -f2,5 out_stats_npr_$rate.dat > plot_throughput_npr_$rate.dat
done

gnuplot <<- EOF
set xrange [0:]
set xlabel "Number of Packets"
set ylabel "Average Throughput (Mbps)"
set title "Average throughput vs Num. of packets (different data rates)"
set term png
set output "$THROUGHPUT_IMG"
set style data linespoints
plot 'plot_throughput_npr_1.dat' w l lc rgb 'yellow' title "1 Mbps", \
'plot_throughput_npr_2.dat' w l lc rgb 'green' title "2 Mbps",'plot_throughput_npr_5.dat' w l lc rgb 'blue' title "5.5 Mbps",'plot_throughput_npr_11.dat' w l lc rgb 'red' title "11 Mbps"
EOF
xdg-open $THROUGHPUT_IMG
