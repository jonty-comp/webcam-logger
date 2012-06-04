#!/bin/bash
logdir="/mnt/webcams/"

datestr=$(/bin/date -d yesterday +%Y-%m-%d)
#datestr="2012-05-29"

for D in $logdir*/
do
	vidstr=$(echo "${D}" | sed 's#/*$##')/$datestr/log.avi
	/usr/bin/mencoder "mf://${D}$datestr/*.jpg" -mf fps=25 -o $vidstr -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=800;
	if [ -e $vidstr ]
	then
		rm ${D}$datestr/*.jpg;
		echo Remove images;
	else
		echo Error: Video $vidstr could not be verified.;
	fi
done


