<?php
const HOST_NAME_DELIMITER = '-';
const HOST_NAME_EXPECTED_PARTS = 3;

function get_ready_name() {
    $host_name = gethostname();
    $host_name_parts = explode(HOST_NAME_DELIMITER, $host_name);
    return (count($host_name_parts) != HOST_NAME_EXPECTED_PARTS) ? $host_name_parts[1] : $host_name;
}

/**
 * Parses the Redis config file for parameters.
 * @param $file
 * @return array
 */
function parseRedisConf($file){
    $config = array();
    if(is_file($file)){
        $file = file_get_contents($file);
        foreach(preg_split("/((\r?\n)|(\r\n?))/", $file) as $line){
            if(substr($line, 0, 4) == "port" || substr($line, 0, 4) == "bind"){
                $exline = explode(" ", $line);
                $config[$exline[0]] = $exline[1];
            }
        }
    }
    return $config;
}


/**
 * Render the default settings page
 * @param array $context variables to render in the template
 */
function settings_page($context) {
?>
<!DOCTYPE html>
<html>
<head lang="en">
    <meta charset="UTF-8">
    <title>Your Hypernode test environment is ready for use</title>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="opensans.css"/>
    <link rel="stylesheet" href="bootstrap.min.css">
    <link rel="stylesheet" href="style.css">
</head>
<body>
<header>
    <nav class="navbar" role="navigation">
        <div id="vagrant">
            <div class="text-center"><h3>test environment for <?= $context['ready_name']; ?></h3></div>
        </div>
        <div class="container">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href=""><img alt="Hypernode"
                                                     src="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAARoAAABgCAMAAAD1o02bAAAAM1BMVEUAAAAngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr0ngr1G2G0/AAAAEHRSTlMAv0CA7xAgn2DfzzCPcFCvNjJDRwAABLtJREFUeF7tm2mTsyoQRpt1UdT+/7/2TsjyBMGKiXMnbwnnw5QFTEdPIc2S0EvkpJQfaUXHOs2JoAyBjnUMdF1OFwM5HblwiY62ixG8gbNdTEmX4wW/wI1tigm8AyG7mESXYzbEdDlK85uEmVrADPwBrmUz3c3CHzLRyfH8KdrSuQlcp79Skj9H06lRXGHQvCIEriDpzAgu8UXWckSuuYFYc8FSvGfaEJlqyxMzckma6IZivI1coFtL3bZ40RT9MFWbnhfHJVSokVu5zNN5CcfURDotho+pGei0zAfVsKGzEvnYMMyyoQnfdvJ2XEHRWeEa4uWUD4jG1paebOAMZ4xra4U5cZ1QKtBcZ2xtg69v9Wmu07ezLB8n9G3hTexZJ3zHmemMDPwLRNpkFD+M6TIKIa4tL2ULJebLdVIrlUg3o8WEXhjFHcQZHw0VGqaYKl35yyUq/KWxdmg6O6GZOVw+B4hnItaWBxG0icRSQjxaOqT8dN9mvUPtTHWqLmndMJps5mof9cXho/ZUxlwgpz7jPc6basZHXrPodIoBD2afGhaZGgc1MHPHV3TrcVON4l9BvqcmXeqHD1uqYbFPDR6YE3alJjLQthJT239Mjb8P3gEb7xc1g5TSC851DvKOgRoiM6eGQ6bGoR5TEzdP+laJmHMMNwtQM8kbI5YJRxnfVJOUuNubJaFGQJxb6QR49AUSiK9Y1N8fT9FtYawpjzk933vR+Y3+82EYj2fIXSeMUIO0KXaomZOMTI271SNQgO4ZMWEu5mrAKPgwzrytxlyHCZ3+FmrcO2pMpobttR6FER+o1jEDLqHmD4Aapy7c7wNPP6fM/arXBHXF73mh2F3rkQlnxFzWamJu0akr9u/UAJGdCw7oz8VYE4tsIlZq7PJ8evrYSLFQgy4LIZmarIMB+U01eGi7VmMUFh/baoQI9wwANaljujfUzP+kGo8jc6jRQgxouK0GeHpWk4K6/Wqmr6sZxAUNNdiUl5ma6vRMY2FTNIyUqbkG/fiFGrBWqyDVa6biX9/MUFARqKpmSJ+wmaFAWKnxUIPChMb4hZgDQsDisW+CusNqkE5LNYMneqVGSimw+QoLIVMT8mXbhJi4uWWfGsc78cfVUKkm5WlpiV6ruYfWJo/mMzUuWXzkeYuY6Ah+nxrey/I/qEH1PjW0IAKiDVBztyfJxNQbs5jWa7j9RTXiD9UAkauxGLARTXICasFcizlVH11+vucXv60G74tbRRPPakYGSy2mo7qaA2PN19VgcWwRDTOp8lhgMJWYkfaq8bwT+3U1uFwQDTrX62etypjaWdqtZvz1kyeDLagx7RGBSw0Uk0U1GOUz46OhJESXiIZ6AtYrJVf3pNS0+jCZYahAH0xQ/ScuE7WHOrjh2X/JQS3yOxO+dg96FbVI5B3M1CL2yKymp29PbWJ0H4S3GF+4GQx1N91MgXG8hVbUODZwFWWoeQRXkdQRxS+9Q3io6WqUUYFvCE8CaroaIpqj+EGNRJmargZ0NV1NV9PVdDVdTVfT1XQ1XU0L4Dt9riyaqHWU5gthrhU1jSvPDkRW1CyqPIyLxXZWP6QLZdFAzTKVXxdRZVE/vuQJI00fbaJ4xteKmqbzH5wjP7BojybsAAAAAElFTkSuQmCC"/></a>
            </div>
            <div class="collapse navbar-collapse">
                <ul class="nav navbar-nav navbar-right">
                    <li><a href="?info=true">PHP Info</a></li>
                    <li><a href="http://support.hypernode.com/" target="_blank">support</a></li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="jumbotron">
        <div class="container">
            <div class="row">
                <div class="center-block">
                    <h1>Your Hypernode test environment is ready for use</h1>
                    <p>Please follow our Getting Started guide at <a
                            href="http://support.hypernode.com/getting-started.html">support.hypernode.com</a>.</p>
                </div>
            </div>
            <div class="row">
                <div class="col-md-4">
                    <table class="table">
                        <thead>
                        <tr>
                            <th colspan="2">MySQL</th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td>Host</td>
                            <td>mysqlmaster</td>
                        </tr>
                        <tr>
                            <td>User</td>
                            <td><?= $context['mysql_config']['user'] ?></td>
                        </tr>
                        <tr>
                            <td>Pass</td>
                            <td><?= $context['mysql_config']['password'] ?></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col-md-4">
                    <table class="table">
                        <thead>
                        <tr>
                            <th colspan="2">
                                Redis
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td>Server</td>
                            <td>redismaster</td>
                        </tr>
                        <tr>
                            <td>Port</td>
                            <td><?= $context['redis_config']['port'] ?></td>
                        </tr>
                        </tbody>
                    </table>
                </div>
                <div class="col-md-4">
                    <table class="table">
                        <thead>
                        <tr>
                            <th colspan="2">
                                Varnish
                            </th>
                        </tr>
                        </thead>
                        <tbody>
                        <tr>
                            <td>Server list</td>
                            <td>varnish:6082 </td>
                        </tr>
                        <tr>
                            <td>Secret</td>
                            <td><?= $context['varnish_secret'] ?></td>
                        </tr>
                        <tr>
                            <td>Backend Host</td>
                            <td>varnish</td>
                        </tr>
                        <tr>
                            <td>Backend Port</td>
                            <td>8080</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</header>
<script src="jquery.min.js"></script>
<script src="bootstrap.min.js"></script>
</body>
</html>
<?php
}

/**
 * Formats an URL which redirects to the PHP info page.
 * @return string
 */
if(isset($_GET['info']) && $_GET['info'] == "true") {
    phpinfo();
} else {
    $context = array(
        "varnish_secret" => file_get_contents('/etc/varnish/secret'),
        "redis_config" => parseRedisConf('/etc/redis/redis.conf'),
        "mysql_config" => parse_ini_file('/data/web/.my.cnf'),
        "ready_name" => get_ready_name()
    );
    settings_page($context);
}
?>
