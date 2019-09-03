<?php

$dbh = new PDO('pgsql:dbname=test;
                           host=127.0.0.1; 
                           user=postgres;
                           password=postgres');
$res = $dbh->query('SELECT * FROM weather');
var_dump($res->fetchAll());