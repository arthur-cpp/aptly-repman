<?php
header('Content-Type: text/html; charset=utf-8');
require_once('../allowed.php');

$ip = $_SERVER['REMOTE_ADDR'];
$country = $_SERVER['HTTP_CF_IPCOUNTRY'] ?? 'Unknown Sector';

$is_allowed   = isset($allowed_ips) && in_array($ip, $allowed_ips);
$status_text  = $is_allowed ? "ACCESS ALLOWED" : "ACCESS RESTRICTED";
$status_class = $is_allowed ? "allowed" : "restricted";

// ASCII Art
$art = "
    ____  __________  ____      ___    ____  __  ___   _____ __  __
   / __ \/ ____/ __ \/ __ \    /   |  / __ \/  |/  /  / ___// / / /
  / /_/ / __/ / /_/ / / / /   / /| | / /_/ / /|_/ /   \__ \/ /_/ / 
 / _, _/ /___/ ____/ /_/ /   / ___ |/ ____/ /  / /   ___/ / __  /  
/_/ |_/_____/_/    \____/   /_/  |_/_/   /_/  /_/   /____/_/ /_/   
                                                                     
---------------------------------------------------------------------";
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>APT PACKAGE REPOSITORY</title>
    <link rel="icon" type="image/png" href="https://apm.sh/favicon.png">
    <style>
        body {
            background-color: #0d0d0d;
            color: #00ff41;
            font-family: "Courier New", Courier, monospace;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 75vh;
            margin: 0;
            overflow: hidden;
            zoom: 125%;
        }
        pre {
            line-height: 1.2;
            text-shadow: 0 0 5px #00ff41;
        }
        .highlight {
            color: #ff003c;
            text-shadow: 0 0 5px #ff003c;
        }
        .restricted { color: #ff003c; text-shadow: 0 0 5px #ff003c; }
        .allowed { color: #00ff41; text-shadow: 0 0 5px #00ff41; font-weight: bold; }
    </style>
</head>
<body>
    <pre>
<?php echo htmlspecialchars($art); ?>

[ NODE DETECTION SYSTEM ]
IDENTIFIED IP:     <span class="<?php echo $status_class; ?>"><?php echo $ip; ?></span>
ORIGIN SECTOR:     <?php echo htmlspecialchars($country); ?>

STATUS:            <span class="<?php echo $status_class; ?>"><?php echo $status_text; ?></span>
---------------------------------------------------------------------

>>> ATTENTION: ACCESS IS LIMITED.
>>> TO  OBTAIN  CONNECTION  PERMISSIONS,
>>> CONTACT THE OWNER OF THE REPOSITORY.

[ HOWTO ]
# check access granted (optional)
curl -L repo.site/check/

# install repo signing key
curl -fsSL https://repo.site/public.key | gpg --dearmor | \
     sudo tee /usr/share/keyrings/apm.gpg > /dev/null

# setup repo for apt
echo "deb [signed-by=/usr/share/keyrings/apm.gpg] https://repo.site/ \
$(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/apm.list

# install packet
sudo apt update && sudo apt install [packet]


[ END OF TRANSMISSION ]
    </pre>
</body>
</html>
