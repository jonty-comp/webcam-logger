#!/bin/bash
logdir="/mnt/data/webcams/"
today=$(date +%Y/%m/%d)

#Camera
for A in $logdir*/
do
	#Year
	for B in ${A}*/
	do
		#Month
		for C in ${B}*/
		do
			#Day
			for D in ${C}*/
			do
				if [ "${D: -11:10}" != "$today" ]
				then
					if find ${D}*.jpg -maxdepth 0 2>/dev/null | read
					then
						vidstr=$(echo "${D}" | sed 's#/*$##')/log.avi
						echo $vidstr
						/usr/bin/mencoder "mf://${D}*.jpg" -mf fps=25 -o $vidstr -ovc lavc -lavcopts vcodec=mpeg4:vbitrate=700; 2>&1 > /dev/null
						if [ -e $vidstr ]
						then
							rm ${D}$datestr/*.jpg;
							#echo Remove images;
						else
							echo Error: Video $vidstr could not be verified.;
						fi
					fi
				fi
			done
		done
	done
done
