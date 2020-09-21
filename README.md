# Swoole Coroutine Postgres Client

`ext-postgresql` is the Swoole Postgres Client library can be used with in the coroutine context without blocking.

### Pre-requirement

* `libpq` is required
* `swoole` version >= 4.4.0

### Build & Installation

```bash
git clone git@github.com:swoole/ext-postgresql.git
phpize
./configure
make && make install
```

Enable `swoole_postgresql` in php.ini by adding the following line:
```
extension=swoole_postgresql.so
```

### How to use the Postgres Client

```php
<?php
Co\run(function () {
    $db = new Swoole\Coroutine\PostgreSQL();
    $db->connect("host=127.0.0.1 port=5432 dbname=test user=root password=password");
    $db->prepare('fortunes', 'SELECT id, message FROM Fortune');
    $res = $db->execute('fortunes', []);
    $arr = $db->fetchAll($res);
    var_dump($arr);

    $db->prepare('select_query', 'SELECT id, randomnumber FROM World WHERE id = $1');
    $res = $db->execute('select_query', [123]);
    $ret = $db->fetchAll($res);
    var_dump($ret);
});
```

You can find more examples in the `/examples` folder.
 
 

  

