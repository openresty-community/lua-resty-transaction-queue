local trans_queue = require("transaction_queue")

local delay = 0.01  -- in seconds
local new_timer = ngx.timer.every
local log = ngx.log
local ERR = ngx.ERR
local NOTICE = ngx.NOTICE

local trans_queue_callback = function(task)
  log(ngx.NOTICE, "start to exec task, task.callback:", task.callback)
  local ok, callback = pcall(require, task.callback) 
  if ok and callback.execute ~= nil then
    local ok, err = pcall(callback.execute, task) 
    if ok then
      log(ngx.NOTICE, "execute task succ")
    else
      log(ERR, "execute task faild, err:", err)
    end
  else
    log(ERR, "require module faild, module name:", task.callback, ", err:", callback)
    package.loaded[task.callback] = nil
  end
end

local trans_queue_timer_callback = function()
  local task, err = trans_queue:get()  
  while (task ~= nil)
  do
    log(ngx.NOTICE, "get task succ, task.callback:", task.callback)
    ngx.thread.spawn(trans_queue_callback, task)
    task, err = trans_queue:get()
  end
end

local hdl, err = new_timer(delay, trans_queue_timer_callback)
if not hdl then
  log(ERR, "failed to create timer: ", err)
  return
end
