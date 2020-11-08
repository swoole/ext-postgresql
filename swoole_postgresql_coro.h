/*
  +----------------------------------------------------------------------+
  | Swoole                                                               |
  +----------------------------------------------------------------------+
  | This source file is subject to version 2.0 of the Apache license,    |
  | that is bundled with this package in the file LICENSE, and is        |
  | available through the world-wide-web at the following url:           |
  | http://www.apache.org/licenses/LICENSE-2.0.html                      |
  | If you did not receive a copy of the Apache2.0 license and are unable|
  | to obtain it through the world-wide-web, please send a note to       |
  | license@swoole.com so we can mail you a copy immediately.            |
  +----------------------------------------------------------------------+
  | Author: Zhenyu Wu  <936321732@qq.com>                                |
  +----------------------------------------------------------------------+
 */
#ifndef SWOOLE_POSTGRESQL_H_
#define SWOOLE_POSTGRESQL_H_

#include "ext/swoole/config.h"
#include "ext/swoole/ext-src/php_swoole_cxx.h"
#include "config.h"

#define PHP_SWOOLE_EXT_POSTGRESQL_VERSION     "4.5.7"
#define PHP_SWOOLE_EXT_POSTGRESQL_VERSION_ID  40507

#if SWOOLE_API_VERSION_ID < 0x202011a
#error "Ext version does not match the Swoole version"
#endif

#ifdef __APPLE__
#include <libpq-fe.h>
#endif

#ifdef __linux__
#include <postgresql/libpq-fe.h>
#endif

enum pg_query_type
{
    NORMAL_QUERY, META_DATA, PREPARE
};

struct pg_object {
    PGconn *conn;
    swoole::network::Socket *socket;
    PGresult *result;
    zval *object;
    zval _object;
    ConnStatusType status;
    enum pg_query_type request_type;
    int row;
    bool connected;
    double timeout;
    bool ignore_notices;
    bool log_notices;
    swoole::TimerNode *timer;
};

#define PGSQL_ASSOC           1<<0
#define PGSQL_NUM             1<<1
#define PGSQL_BOTH            (PGSQL_ASSOC|PGSQL_NUM)

/* from postgresql/src/include/catalog/pg_type.h */
#define BOOLOID     16
#define BYTEAOID    17
#define INT2OID     21
#define INT4OID     23
#define INT8OID     20
#define TEXTOID     25
#define OIDOID      26
#define FLOAT4OID   700
#define FLOAT8OID   701

#endif
