<?php
header("Access-Control-Allow-Origin: *");
// get the HTTP method, path and body of the request
$method = $_SERVER['REQUEST_METHOD'];

$host = '127.0.0.1';
$port = 3003;

// print results, insert id or affected row count
if ($method == 'GET') {
        $connection = @fsockopen($host, $port);

        if (is_resource($connection))
        {
            fclose($connection);
            echo json_encode(array('status' => 'up'));
        }
        else
        {
            echo json_encode(array('status' => 'down'));
        }
}

?>
