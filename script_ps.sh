#OUTPUT_STATS=out_stats.dat
#PLOT_THROUGHPUT=out_throughput.dat
THROUGHPUT_IMG=throughput_image_packetSize.png

rm out_stats_ps_*
rm plot_throughput_ps_*

for packetSize in 50 100 500 1000 1100 1200 1300 1400 1500
do
#	for node in $(seq 5) 
#	do
		echo -ne "Computing throughput for 5 nodes with packet size = $packetSize ... "
		./waf --run "scratch/wireless --packetSize=$packetSize" >> out_stats_ps_$packetSize.dat
		echo "Complete"
#	done
#
	sed -i "/\b\(waf\|build\|Compiling\)\b/d" out_stats_ps_$packetSize.dat
	cut -f3,5 out_stats_ps_$packetSize.dat > plot_throughput_ps_$packetSize.dat
done

gnuplot <<- EOF
set xlabel "Packet Size"
set ylabel "Average Throughput (Mbps)"
set title "Average throughput vs Packet Size"
set term png
set output "$THROUGHPUT_IMG"
set style fill solid
plot [-0.5:][0:950] 'plot_throughput_ps_50.dat' u 2: xtic(1) with histogram title "50 bytes", 'plot_throughput_ps_100.dat' u 2: xtic(1) with histogram title "100 bytes", 'plot_throughput_ps_500.dat' u 2: xtic(1) with histogram title "500 bytes", 'plot_throughput_ps_1000.dat' u 2: xtic(1) with histogram title "1000 bytes", 'plot_throughput_ps_1100.dat' u 2: xtic(1) with histogram title "1100 bytes", 'plot_throughput_ps_1200.dat' u 2: xtic(1) with histogram title "1200 bytes", 'plot_throughput_ps_1300.dat' u 2: xtic(1) with histogram title "1300 bytes", 'plot_throughput_ps_1400.dat' u 2: xtic(1) with histogram title "1400 bytes", 'plot_throughput_ps_1500.dat' u 2: xtic(1) with histogram title "1500 bytes"

EOF
xdg-open $THROUGHPUT_IMG
