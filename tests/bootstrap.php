<?php
if (getenv('POSTGRES_HOST')) {
    $host = getenv('POSTGRES_HOST');
    $port = getenv('POSTGRES_PORT');
    define('TEST_DB_URI', "host={$host};port={$port};dbname=postgres;user=postgres;password=postgres");
} else {
    define('TEST_DB_URI', 'host=127.0.0.1;port=5432;dbname=test;user=postgres;password=postgres');
}

Swoole\Coroutine\run(function () {
    $pg = new Swoole\Coroutine\PostgreSQL();
    $pg->connect(TEST_DB_URI);
    $retval = $pg->query('DROP TABLE IF EXISTS weather');
    if (!$retval) {
        var_dump($retval, $pg->error, $pg->notices);
    }

    $retval = $pg->query('CREATE TABLE weather (
        id SERIAL primary key NOT NULL,
        city character varying(80),
        temp_lo integer,
        temp_hi integer,
        prcp real,
        date date)');

    if (!$retval) {
        var_dump($retval, $pg->error, $pg->notices);
    }

    $retval = $pg->query("INSERT INTO weather(city, temp_lo, temp_hi, prcp, date) VALUES ('San Francisco', 46, 50, 0.25, '1994-11-27') RETURNING id;");
    if (!$retval) {
        var_dump($retval, $pg->error, $pg->notices);
    }
});