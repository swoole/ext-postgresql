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

    public function testPrepare()
    {
        run(function () {
            $pg = $this->getConn();
            $prepare_result = $pg->prepare('key', "INSERT INTO weather(city, temp_lo, temp_hi, prcp, date) 
                        VALUES ($1, $2, $3, $4, $5)  RETURNING id");
            $this->assertNotFalse($prepare_result, (string) $pg->error);
            $execute_result = $pg->execute('key', ['Beijing', rand(1000, 99999), 10, 0.75, '1993-11-23']);
            $this->assertNotFalse($execute_result, (string) $pg->error);
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

    public function testNotConnected()
    {
        run(function () {
            $pg = new Swoole\Coroutine\PostgreSQL();

            $this->assertFalse($pg->escape(''));
            $this->assertFalse($pg->escapeLiteral(''));
            $this->assertFalse($pg->escapeIdentifier(''));
            $this->assertFalse($pg->query(''));
            $this->assertFalse($pg->prepare('', ''));
            $this->assertFalse($pg->execute('', []));
            $this->assertFalse($pg->metaData(''));
        });
    }
}
