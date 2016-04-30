#OUTPUT_STATS=out_stats.dat
#PLOT_THROUGHPUT=out_throughput.dat
THROUGHPUT_IMG=throughput_img_psr.png

rm out_stats_psr_*
rm plot_throughput_psr_*

for rate in 1 2 5 11
do
	for packetSize in 50 100 500 1000 1500 
	do
		echo -ne "Computing throughput for packet size $packetSize with rate $rate Mbps ... "
		./waf --run "scratch/wireless --packetSize=$packetSize --rate=$rate" >> out_stats_psr_$rate.dat
		echo "Complete"
	done

	sed -i "/\b\(waf\|build\|Compiling\)\b/d" out_stats_psr_$rate.dat
	cut -f3,5 out_stats_psr_$rate.dat > plot_throughput_psr_$rate.dat
done

gnuplot <<- EOF
set xrange [0:]
set xlabel "Packet Size(bytes)"
set ylabel "Average Throughput (Mbps)"
set title "Average throughput vs Packet size (different data rates)"
set term png
set output "$THROUGHPUT_IMG"
set style data linespoints
plot 'plot_throughput_psr_1.dat' w l lc rgb 'yellow' title "1 Mbps", \
'plot_throughput_psr_2.dat' w l lc rgb 'green' title "2 Mbps",'plot_throughput_psr_5.dat' w l lc rgb 'blue' title "5.5 Mbps",'plot_throughput_psr_11.dat' w l lc rgb 'red' title "11 Mbps"
EOF
xdg-open $THROUGHPUT_IMG
