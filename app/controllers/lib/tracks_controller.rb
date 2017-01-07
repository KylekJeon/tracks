require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class TracksController
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @already_built_response = false
    @params = route_params.merge(req.params)
    @@protect_from_forgery ||= false
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    raise 'should not render or redirect twice in one action' if already_built_response?
    @res.status = 302
    @res.location = url

    @already_built_response = true
    session.store_session(@res)
  end

  def render_content(content, content_type)
    raise 'should not render or redirect twice in one action' if already_built_response?

    @res.write(content)
    @res.set_header("Content-Type", content_type)

    @already_built_response = true
    session.store_session(@res)
  end

  def render(template_name)
    dir_path = File.dirname(__FILE__)
    template_path_name = File.join(
      dir_path, "../..", "views", self.class.name.underscore, "#{template_name}.html.erb"
    )

    template_content = File.read(template_path_name)

    render_content(
      ERB.new(template_content).result(binding),
      'text/html'
    )
  end

  def session
    @session ||= Session.new(@req)
  end

  def invoke_action(name)

    if protect_from_forgery? && req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end

    self.send(name)
    render(name) unless already_built_response?

    nil
  end


  def form_authenticity_token
    @token ||= generate_authenticity_token
    res.set_cookie('authenticity_token', value: @token, path: '/')
    @token
  end

  protected

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  private

  attr_accessor :already_built_response

  def controller_name
    self.class.to_s.underscore
  end

  def protect_from_forgery?
    @@protect_from_forgery
  end

  def check_authenticity_token
    cookie = @req.cookies["authenticity_token"]
    unless cookie && cookie == params["authenticity_token"]
      raise "Invalid authenticity token"
    end
  end

  def generate_authenticity_token
    SecureRandom.urlsafe_base64(16)
  end
end
