<?php
header('Content-Type: text/plain; charset=utf-8');
require_once('../../allowed.php');

$ip         = $_SERVER['REMOTE_ADDR'];
$is_allowed = isset($allowed_ips) && in_array($ip, $allowed_ips);
$status     = $is_allowed ? "ALLOWED" : "RESTRICTED";

echo "$ip=$status\n";
if (!$is_allowed) {
    echo "> MESSAGE: Please send this IP to the repo owner for whitelist access.\n";
}
