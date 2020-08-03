<?php

Co\run(function () {
    $pg = new Swoole\Coroutine\PostgreSQL();
    $conn = $pg->connect("host=127.0.0.1;port=5432;dbname=test;user=postgres;password=postgres");
    if (!$conn) {
        var_dump($pg->error);
        return;
    }
    $result = $pg->escape("' or 1=1 & 2");
    if (!$result) {
        var_dump($pg->error);
        return;
    }
    var_dump($result);
});
