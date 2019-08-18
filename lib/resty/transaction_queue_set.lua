local trans_queue = require("transaction_queue")

local retcode, err =  trans_queue:set_queue_size(ngx.arg[1])
if retcode == 0 then
  ngx.log(ngx.NOTICE, "set queuce size succ, size:", ngx.arg[1])
else
  ngx.log(ngx.ERR, "set queuce size faild, err:", err)
end
