#!/usr/bin/php
<?php

$filename = "/etc/nginx/sites-enabled/default";
$replace = array(
 "##RDS_HOSTNAME##"     => $_SERVER['RDS_HOSTNAME'],
 "##RDS_USERNAME##"     => $_SERVER['RDS_USERNAME'],
 "##RDS_PASSWORD##"     => $_SERVER['RDS_PASSWORD'],
 "##RDS_DB_NAME##"      => $_SERVER['RDS_DB_NAME'],
 "##AWS_ACCESS_ID##"    => $_SERVER['AWS_ACCESS_ID'],
 "##AWS_SECRET_KEY##"   => $_SERVER['AWS_SECRET_KEY'],
 "##BUCKET_NAME##"      => $_SERVER['BUCKET_NAME'],
 "##IMAGE_BUCKET_NAME##"=> $_SERVER['IMAGE_BUCKET_NAME'],
 "##REGION##"           => $_SERVER['REGION'],
 "##SQS_URL##"          => $_SERVER['SQS_URL'],
 "##DEBUG##"            => $_SERVER['DEBUG'],
);
$buff = file_get_contents($filename);
$buff = strtr($buff, $replace);
file_put_contents($filename, $buff);

exec("/usr/bin/supervisord -c /etc/supervisord.conf -n");
