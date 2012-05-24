<?php
//A simple PHP page to retreive a logged image from a video file.
//Requires php5-ffmpeg
//URL: frame.php?camera=$CAMERA&date=YYYY-MM-DD&time=HH:mm:ss

function time_to_seconds ($str) { // $hour must be a string type: "HH:mm:ss"
    $parse = array();
    if (!preg_match ('#^(?<hours>[\d]{2}):(?<mins>[\d]{2}):(?<secs>[\d]{2})$#',$str,$parse)) throw new RuntimeException ("Time must be provided in format HH:mm:ss");
    return (int) $parse['hours'] * 3600 + (int) $parse['mins'] * 60 + (int) $parse['secs'];
}

$logpath = "/mnt/webcam-log/log/";

$camera = $_REQUEST["camera"];
$date = $_REQUEST["date"];
$time = $_REQUEST["time"];

$video = new ffmpeg_movie($logpath.$camera."/".$date."/log.avi");
$frames = $video->getFrameCount();

$length_of_day = time_to_seconds("24:00:00");
$real_fps = $frames / $length_of_day;

$frame = time_to_seconds($time) * $real_fps;

$frame = $video->getFrame($frame);
header("Content-type: image/jpeg");

echo imagejpeg($frame->toGDImage());

?>
