require "rubygems"
require "bundler"
require 'rack/prettify'

Bundler.setup
Bundler.require(:test)

FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')

def fixture(name)
  File.read(File.join(FIXTURES_PATH, name))
end

class RackResource
  attr_accessor :original_content, :expected_html, :expected_xhtml

  def initialize(args={})
    @original_content = args[:original_content]
    @content_type     = args[:content_type]
    @expected_html    = args[:expected_html]
    @expected_xhtml   = args[:expected_xhtml]
  end

  def rack_app(opts={})
    headers = { 'Content-Type' => @content_type }.merge(opts)
    lambda { |env| [200, headers, StringIO.new(@original_content)] }
  end
end

def xhtml_page
  original       = fixture('xhtml.html')
  expected_html  = fixture('xhtml_prettified_as_html.html')
  expected_xhtml = fixture('xhtml_prettified_as_xhtml.html')

  opts = {
    :original_content => original,
    :content_type     => 'text/html',
    :expected_html    => expected_html,
    :expected_xhtml   => expected_xhtml
  }

  RackResource.new(opts)
end

def html5_page
  original       = fixture('html5.html')
  expected_html  = fixture('html5_prettified_as_html.html')
  expected_xhtml = fixture('html5_prettified_as_xhtml.html')

  opts = {
    :original_content => original,
    :content_type     => 'text/html',
    :expected_html    => expected_html,
    :expected_xhtml   => expected_xhtml
  }

  RackResource.new(opts)
end

def page_without_doctype(page)
  resource = page

  doctype_regex = /^<!DOCTYPE .*?>$/m
  resource.original_content = resource.original_content.sub(doctype_regex, '')
  resource.expected_html    = resource.expected_html.sub(doctype_regex, '')
  resource.expected_xhtml   = resource.expected_xhtml.sub(doctype_regex, '')

  resource
end

def html_5_page_without_doctype
  page_without_doctype(html5_page)
end

def xhtml_page_without_doctype
  page_without_doctype(xhtml_page)
end

def javascript_resource
  opts = {
    :original_content => "alert('Hello World!');\n",
    :content_type     => "javascript/application"
  }

  RackResource.new(opts)
end

def embedded_javascript_page
  original       =
    fixture('embedded_javascript.html')

  # Ideally, this should be "embedded_javascript_prettified_as_html.html".
  expected_html  =
    fixture('non_indented_embedded_javascript_prettified_as_html.html')

  # Ideally, this should be "embedded_javascript_prettified_as_xhtml.html".
  expected_xhtml =
    fixture('non_indented_embedded_javascript_prettified_as_xhtml.html')

  opts = {
    :original_content => original,
    :content_type     => 'text/html',
    :expected_html    => expected_html,
    :expected_xhtml   => expected_xhtml
  }

  RackResource.new(opts)
end

def rack_app_response(resource, env, opts={})
  app = Rack::Builder.new do
    use Rack::Lint
    use Rack::Prettify, opts
    run resource.rack_app
  end

  body = ""
  app.call(env).last.each { |part| body << part }
  body
end
