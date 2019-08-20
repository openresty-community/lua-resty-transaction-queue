local max_priority = 10
local min_priority = 1
local default_queue_size = 10
local _M = { 
  _VERSION = '1.0',
  queue_size = default_queue_size,
  queue = {},
}

function _M.set_queue_size(self, queue_size_arg)
  local queue_size = tonumber(queue_size_arg)
  if queue_size ~= nil and queue_size > 0 then
    self.queue_size = queue_size
    return 0
  else
    return -1, "args is not valid, queue_size should be a number and large than 0, queue_size:"..queue_size_arg
  end
end

function _M.get(self)
  if next(self.queue) then
    for priority = max_priority, min_priority, -1 do
      if self.queue[priority] ~= nil and next(self.queue[priority]) ~= nil then
        ngx.log(ngx.NOTICE, "get task from priority ", priority)
        return table.remove(self.queue[priority], 1)
      end
    end
  end
  return nil, "all queue is empty"
end

function _M.get_with_priority(self, priority_arg)
  local priority = tonumber(priority_arg)
  if priority == nil or priority < min_priority or priority > max_priority then
    return nil, "args is not valid, priority should be a number and need in ["..min_priority..", "..max_priority.."], priority:"..priority_arg
  end

  if self.queue[priority] ~= nil and next(self.queue[priority]) ~= nil then
    return table.remove(self.queue[priority], 1)
  else
    return nil, "this queus is empty, priority:"..priority
  end
end

function _M.add(self, uri, args, callback, priority_arg)
  local priority = tonumber(priority_arg) or min_priority
  if priority < min_priority or priority > max_priority then
    return -1, "args is not valid, priority should be a number and need in ["..min_priority..", "..max_priority.."], priority:"..priority_arg
  end

  if uri == nil or callback == nil then
    return -1, "args is not valid, uri or callback is nil, uri:"..url..", callback:"..callback
  end

  if self.queue[priority] == nil then
    self.queue[priority] = {}
  elseif #self.queue[priority] >= self.queue_size then
    return -1, "this queue is reach queue max size:"..self.queue_size
  end

  local task = {
    uri = uri,
    args = args,
    callback = callback,
  }

  ngx.log(ngx.NOTICE, "add task to queus succ, priority:", priority)
  table.insert(self.queue[priority], task)
  return 0
end

return _M
