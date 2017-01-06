dir_path = File.expand_path(File.dirname(__FILE__))
Dir["#{dir_path}/../app/controllers/*_controller.rb"].each {|file| require file }
require_relative '../lib/router'

OTR_ROUTER = Router.new

OTR_ROUTER.draw do
  
end
