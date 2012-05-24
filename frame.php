<?php
function time_to_seconds ($str) { // $hour must be a string type: "HH:mm:ss"
    $parse = array();
    if (!preg_match ('#^(?<hours>[\d]{2}):(?<mins>[\d]{2}):(?<secs>[\d]{2})$#',$str,$parse)) throw new RuntimeException ("Time must be provided in format HH:mm:ss");
    return (int) $parse['hours'] * 3600 + (int) $parse['mins'] * 60 + (int) $parse['secs'];
}

$logpath = "/mnt/webcam-log/log/";

$camera = $_REQUEST["camera"];
$date = $_REQUEST["date"];
$time = $_REQUEST["time"];

header("Content-type: image/jpeg");

if($date == date("Y-m-d")) {
	$imagefile = strtotime($date." ".$time);
	$fullpath = $logpath.$camera."/".$date."/".$imagefile.".jpg";
	while(!$image) {
		$imagefile -= 1;
		$fullpath = $logpath.$camera."/".$date."/".$imagefile.".jpg";
		$image = imagecreatefromjpeg($fullpath);
	}
} else {
	$video = new ffmpeg_movie($logpath.$camera."/".$date."/log.avi");
	$frames = $video->getFrameCount();

	$length_of_day = time_to_seconds("24:00:00");
	$real_fps = $frames / $length_of_day;

	$frame = time_to_seconds($time) * $real_fps;

	$frame = $video->getFrame($frame);

	$image = $frame->toGDImage();
}

echo imagejpeg($image);
?>
