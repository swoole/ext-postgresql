<?php

use Swoole\Event;

go(function () {
    $pg = new Swoole\Coroutine\PostgreSQL();
    $conn = $pg->connect("host=127.0.0.1;port=5432;dbname=test;user=postgres;password=postgres");
    if (!$conn) {
        var_dump($pg->error);
        return;
    }
    $result = $pg->query('SELECT * FROM weather;');
    if (!$result) {
        var_dump($pg->error);
        return;
    }
    $arr = $pg->fetchAll($result);
    var_dump($arr);
});

Event::wait();
