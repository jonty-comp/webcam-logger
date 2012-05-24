#!/bin/bash
# Script to process yesterday's image logs and encode them as an exciting video.
# Place in /etc/cron.daily or add to crontab
# Requires mencoder.  Would've used ffmpeg but it doesn't like timestamped image filenames

cd /mnt/webcam-log/log/

datestr=$(date -d yesterday +%Y-%m-%d)

for D in */
do
	vidstr=$(echo "${D}" | sed 's#/*$##')/$datestr/log.avi
	mencoder "mf://${D}$datestr/*.jpg" -mf fps=25 -o $vidstr -ovc lavc -lavcopts vcodec=msmpeg4v2:vbitrate=600;
	if [ -e $vidstr ]
	then
		rm ${D}$datestr/*.jpg;
	else
		echo Error: Video $vidstr could not be verified.;
	fi
done


