require 'rack'
require 'nokogiri'

module Rack
  class Prettify

    attr_reader :output_type

    XSLT_PATH = ::File.expand_path('../prettify/prettify.xslt', __FILE__)

    def initialize(app, options={})
      @app = app
      self.output_type = options[:output_type] || :xhtml
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @status, @headers, @response = @app.call(env)
      return [@status, @headers, @response] unless content_is_html?

      parse and prettify

      if @headers['Content-Length']
        @headers['Content-Length'] = @prettified.length.to_s
      end
      
      [@status, @headers, [@prettified]]
    end

    private
    def output_type=(output_type)
      @output_type = output_type

      unless [:xhtml, :html].include?(@output_type)
        msg = ":output_type needs to be :html or :xhtml"
        raise ArgumentError, msg
      end
    end

    def content_is_html?
      @headers['Content-Type'] =~ /html/
    end

    def parse
      set_document
      set_original_dtd
      set_original_html_tag
    end

    def prettify
      apply_xslt_transformation_to_document
      set_prettified_as_xhtml_or_html
      process_prettified
    end

    def set_document
      body = ""
      @response.each { |part| body << part }
      if body.split("\n")[0] !~ /^<!DOCTYPE/
        body = "<!DOCTYPE html>\n" + body
      end
      @document = Nokogiri::HTML(body)
    end

    def set_original_dtd
      dtd = @document.children.first
      @original_dtd = dtd.is_a?(Nokogiri::XML::DTD) ? dtd.to_xhtml : nil
    end

    def set_original_html_tag
      @original_html_tag = "<html>"

      original_tag = @document.at_css('html')
      keys         = original_tag.keys
      return @original_html_tag if keys.empty?

      attributes = keys.inject([]) do |memo, key|
        memo << %Q{#{key}="#{original_tag[key]}"}
      end

      @original_html_tag = %Q{<html #{attributes.join(' ')}>}
    end

    def apply_xslt_transformation_to_document
      prettify_xslt = Nokogiri::XSLT(::File.open(XSLT_PATH))
      @document     = prettify_xslt.transform(@document)
    end

    def set_prettified_as_xhtml_or_html
      @prettified = @document.__send__("to_#{@output_type}")
    end

    def process_prettified
      @prettified = @prettified.gsub(/^$\n/, '')
      @prettified = @prettified.gsub(/<html .*?>/, @original_html_tag)
      @prettified = [@original_dtd, "\n", @prettified].compact.join
    end

  end
end
