require 'rack'
require_relative '/lib/asset_server'
require_relative '/lib/show_exceptions'
require_relative 'routes'

DBConnection.open

otr_app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  OTR_ROUTER.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use ShowExceptions
  use StaticAssets
  run otr_app
end

run app
