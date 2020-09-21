<?php
if (getenv('POSTGRES_HOST')) {
    $host = getenv('POSTGRES_HOST');
    $port = getenv('POSTGRES_PORT');
    define('TEST_DB_URI', "host={$host};port={$port};dbname=postgres;user=postgres;password=postgres");
} else {
    define('TEST_DB_URI', 'host=127.0.0.1;port=5432;dbname=test;user=postgres;password=postgres');
}
