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
* [Setting Transation Queue](#setting-transation-queue)
    * [Setting Package Path](#setting-package-path)
    * [Setting Init Method](#setting-init-method)
    * [Setting Queue Size](#setting-queue-size)
    * [Setting Request Priority](#setting-request-priority)
    * [Setting Request Callback](#setting-request-callback)
    * [Setting Request Handle](#setting-request-handle)
* [Developing Request Callback](#developing-request-callback)
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

This module is a priority message queue for request processing.  When Nginx receives a request, the request can be assigned a priority (1 ~ 10), and it will be dispatched to the message queue with the priority correspondingly.  Each Nginx worker has a timer, and the timer will fetch the request from the priority message queue regularly and call the user-defined callback function to process the request. Low priority requests are processed only after high priority requests have been processed.

Synopsis
========

```lua
    lua_package_path "/path/to/lua-resty-transaction-queue/lib/?.lua;;";
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
Transaction Queue will register a timer during initialization for each Nginx worker. When Nginx receives a requests, the request will be dispatched to the transaction queue and respond user immediately. After that, the request will be processed asynchronously by the timer with the user-defined callback function. 
User should configure the callback function and the priority for each request, and user can also configure the transaction queue,  such as queue size, etc.

[Back to TOC](#table-of-contents)

Setting Transation Queue
=====================

Setting Package Path
----------

`syntax:  lua_package_path "/path/to/lua-resty-tm/lib/?.lua;;";`

`context:  http`

[Back to TOC](#table-of-contents)

Setting Init Method
--------------

`syntax:  init_worker_by_lua_file transaction_queue_init.lua;`

`context: http`

`phase: starting-worker`

[Back to TOC](#table-of-contents)

Setting Queue Size
------------

`syntax: set_by_lua_file $queue_size transaction_queue_set.lua 10;`

`context: server, server if, location, location if`

`phase: rewrite`

[Back to TOC](#table-of-contents)

Setting Request Priority
------------------------

`syntax:  set $queue_priority 9;`

`context: location, location if`

`phase: rewrite`

[Back to TOC](#table-of-contents)

Setting Request Callback
------------------------

`syntax:  set $queue_handler "xxx";`

`context: location, location if`

`phase: rewrite`

[Back to TOC](#table-of-contents)

Setting Request Handle
----------------------

`syntax: content_by_lua_file transaction_queue_handle.lua;`

`context: location, location if`

`phase: content`

[Back to TOC](#table-of-contents)

Developing Request Callback
========================

The Callback Module need return a table, which mush include a execute method. 

The define of execute method is:
```lua
  function _M.execute(task)
  end

  The type of parameter task is table, which include two kv pairs, as follows:
  {
    uri：ngx.var.uri,
    args：ngx.req.get_uri_args(),
  }
```

The Callback Module Example:
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

[Back to TOC](#table-of-contents)

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
