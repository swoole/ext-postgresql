<?php

use Swoole\Coroutine\PostgreSQL;
use function Swoole\Coroutine\run;
use PHPUnit\Framework\TestCase;

class PostgreSQLTest extends TestCase
{
    public function testEscape()
    {
        run(function () {
            $pg = new Swoole\Coroutine\PostgreSQL();
            $conn = $pg->connect(TEST_DB_URI);
            $this->assertNotFalse($conn, (string)$pg->error);
            $result = $pg->escape("' or 1=1 & 2");
            $this->assertNotFalse($result, (string)$pg->error);
            $this->assertEquals("'' or 1=1 & 2", $result);
        });
    }

    public function testQuery()
    {
        run(function () {
            $pg = new Swoole\Coroutine\PostgreSQL();
            $conn = $pg->connect(TEST_DB_URI);
            $this->assertNotFalse($conn, (string)$pg->error);

            $result = $pg->query('SELECT * FROM weather;');
            $this->assertNotFalse($result, (string)$pg->error);

            $arr = $pg->fetchAll($result);
            $this->assertIsArray($arr);
            $this->assertEquals($arr[0]['city'], 'San Francisco');

        });
    }
}
