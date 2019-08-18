local trans_queue = require("transaction_queue")

local args, err = ngx.req.get_uri_args()
if err then
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  ngx.say("get request uri args failed, ", err)
  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

local retcode, err =  trans_queue:add(ngx.var.uri, args, ngx.var.queue_handler, ngx.var.queue_priority);

if retcode == 0 then
  ngx.say("add request to queue succ")
  ngx.exit(ngx.HTTP_OK)
else 
  ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
  ngx.say("add request to queue faild, retcode:", retcode, ", err:", err)
  ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end
