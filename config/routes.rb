require 'rack'
require_relative './lib/router'
require_relative './lib/exceptions'
require_relative './lib/static_assets'


# requires all controller files automatically

dir_path = File.expand_path(File.dirname(__FILE__))
Dir["#{dir_path}/../app/controllers/*_controller.rb"].each {|file| require file }

router = Router.new
router.draw do
  get Regexp.new("^/kittens/new$"), KittensController, :new
  get Regexp.new("^/$"), KittensController, :index
  get Regexp.new("^/kittens/(?<kitten_id>\\d+)$"), KittensController, :show
  post Regexp.new("^/kittens$"), KittensController, :create
  delete Regexp.new("^/kittens/(?<kitten_id>\\d+)$"), KittensController, :destroy
end

app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  router.run(req, res)
  res.finish
end

app = Rack::Builder.new do
  use StaticAssets
  use Exceptions
  run app
end.to_app

Rack::Server.start(
  app: app,
  Port: 3000
)
