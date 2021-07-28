<?php

use PHPUnit\Framework\TestCase;
use Swoole\Coroutine\PostgreSQL;
use function Swoole\Coroutine\run;

class PostgreSQLTest extends TestCase
{
    protected function getConn()
    {
        $pg = new Swoole\Coroutine\PostgreSQL();
        $conn = $pg->connect(TEST_DB_URI);
        $this->assertNotFalse($conn, (string) $pg->error);

        return $pg;
    }

    public function testEscape()
    {
        run(function () {
            $pg = $this->getConn();
            $result = $pg->escape("' or 1=1 & 2");
            $this->assertNotFalse($result, (string) $pg->error);
            $this->assertEquals("'' or 1=1 & 2", $result);
        });
    }

    public function testInsert()
    {
        run(function () {
            $pg = $this->getConn();
            $result = $pg->query("INSERT INTO weather(city, temp_lo, temp_hi, prcp, date) 
                        VALUES ('Shanghai', 88, 10, 0.75,'1993-11-27')  RETURNING id");
            $this->assertNotFalse($result, (string) $pg->error);
            $this->assertEquals(1, $pg->numRows($result));
            $this->assertGreaterThan(1, $pg->fetchAssoc($result)['id']);
        });
    }

    public function testQuery()
    {
        run(function () {
            $pg = $this->getConn();
            $result = $pg->query('SELECT * FROM weather;');
            $this->assertNotFalse($result, (string) $pg->error);

            $arr = $pg->fetchAll($result);
            $this->assertIsArray($arr);
            $this->assertEquals($arr[0]['city'], 'San Francisco');
        });
    }

    public function testNoFieldName()
    {
        run(function () {
            $pg = $this->getConn();
            $result = $pg->query('SELECT 11, 22');
            $this->assertNotFalse($result, (string) $pg->error);

            $arr = $pg->fetchAll($result);
            $this->assertIsArray($arr);
            $this->assertEquals($arr[0]['?column?'], 11);
            $this->assertEquals($arr[0]['?column?1'], 22);
        });
    }
}
