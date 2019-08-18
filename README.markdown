Name
====

lua-resty-transaction-queue - Lua Transaction Queue for the ngx_lua

Table of Contents
=================

* [Name](#name)
* [Status](#status)
* [Description](#description)
* [Synopsis](#synopsis)
* [Usage](#usage)
* [配置 Transation Queue](##配置-transation-queue)
    * [设置包路径](#设置包路径)
    * [设置初始化方法](#设置初始化方法)
    * [设置队列长度](#设置队列长度)
    * [设置异步请求优先级](#设置异步请求优先级)
    * [设置异步请求回调模块](#设置异步请求回调模块)
    * [设置异步请求队列处理方法](#设置异步请求队列处理犯法)
* [开发异步请求回调模块](#开发异步请求回调模块)
* [Limitations](#limitations)
* [TODO](#todo)
* [Author](#author)
* [Copyright and License](#copyright-and-license)
* [See Also](#see-also)

Status
======

Description
===========

This Lua library  is a Transaction Queue for the ngx_lua nginx module:

https://github.com/openresty/lua-nginx-module/#readme

基于定时器的异步请求队列实现，worker 内共享，允许设置多个不同优先级别的异步队列及其队列长度，主要用于 HTTP 请求异步处理场景。Nginx接收到HTTP请求后可以先应答，后面再将请求异步提交到 Transaction Queue。

Synopsis
========

```lua
    lua_package_path "/path/to/lua-resty-tm/lib/?.lua;;";
    init_worker_by_lua_file transaction_queue_init.lua;

    server {
      set_by_lua_file $queue_size transaction_queue_set.lua 10;

      location /test {
        set $queue_priority 9;
        set $queue_handler "xxx";
        content_by_lua_file transaction_queue_handle.lua;
      }
    }
```

[Back to TOC](#table-of-contents)

Usage
=====
Transaction Queue 初始化时会在每个 worker 下注册一个定时器。当 Nginx 收到用户请求后，会调用 Transaction Queue 的默认请求处理方法，该方法会把请求放入到  Transaction Queue 中，并直接返回结果给用户。然后定时器会定期从  Transaction Queue 中获取请求并调用该请求的回调方法。

用户需按照文档开发异步请求回调模块，并配置 Transaction Queue。

配置 Transation Queue
=====================

设置包路径
----------

`syntax:  lua_package_path "/path/to/lua-resty-tm/lib/?.lua;;";`

`context:  http`

设置初始化方法
--------------

`syntax:  init_worker_by_lua_file transaction_queue_init.lua;`

`context: http`

`phase: starting-worker`

设置队列长度
------------

`syntax: set_by_lua_file $queue_size transaction_queue_set.lua 10;`

`context: server, server if, location, location if`

`phase: rewrite`

设置异步请求优先级
------------------

`syntax:  set $queue_priority 9;`

`context: location, location if`

`phase: rewrite`

设置异步请求回调模块
--------------------

`syntax:  set $queue_handler "xxx";`

`context: location, location if`

`phase: rewrite`

设置异步请求队列处理方法
------------------------

`syntax: content_by_lua_file transaction_queue_handle.lua;`

`context: location, location if`

`phase: content`

开发异步请求回调模块
====================

该模块需要返回一个 table，其中需包含一个 exeute 方法，该方法原型如下：

```lua
  function _M.execute(task)
  end

  execute 方法接收一个 table 参数，包含两个 kv 对，
  {
    uri：ngx.var.uri,
    args：ngx.req.get_uri_args(),
  }
```

示例

```lua
  local _M = { VERSION = '0.0.1' }
  local log = ngx.log
  local NOTICE = ngx.NOTICE

  function _M.execute(task)
    log(NOTICE, "uri:", task.uri)
    for k, v in pairs(task.args) do
    log(NOTICE, "task args, k:", k, ", value:", v)
    end
  end

  return _M
```

Limitations
===========

[Back to TOC](#table-of-contents)

TODO
====

[Back to TOC](#table-of-contents)

Author
======

[Back to TOC](#table-of-contents)

Copyright and License
=====================

[Back to TOC](#table-of-contents)

See Also
========

[Back to TOC](#table-of-contents)
