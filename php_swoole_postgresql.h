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
  |         Tianfeng Han <rango@swoole.com>                              |
  +----------------------------------------------------------------------+
 */
#ifndef SWOOLE_POSTGRESQL_H_
#define SWOOLE_POSTGRESQL_H_

#include "ext/swoole/config.h"
#include "ext/swoole/ext-src/php_swoole_cxx.h"
#include "config.h"

#define PHP_SWOOLE_EXT_PLUS_VERSION     "4.8.0"
#define PHP_SWOOLE_EXT_PLUS_VERSION_ID  40800

#if SWOOLE_VERSION_ID < 40800
#error "Ext version does not match the Swoole version"
#endif

#include <libpq-fe.h>

#include <zend_portability.h>

#endif
