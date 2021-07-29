<?php

use Swoole\Event;

go(function () {
    $pg = new Swoole\Coroutine\PostgreSQL();
    $conn = $pg->connect("host=127.0.0.1;port=5432;dbname=test;user=postgres;password=postgres");
    if (!$conn) {
        var_dump($pg->error);
        return;
    }

    $prepare_result = $pg->prepare('key', "INSERT INTO weather(city, temp_lo, temp_hi, prcp, date) 
                        VALUES ($1, $2, $3, $4, $5)  RETURNING id");
    var_dump($prepare_result);
    $execute_result = $pg->execute('key', ['Beijing', rand(1000, 99999), 10, 0.75, '1993-11-23']);

    var_dump($execute_result);
});

Event::wait();
