require 'spec_helper'

describe Rack::Prettify do
 
   before(:each) do
     @env       = Rack::MockRequest.env_for '/'
     @resources = [xhtml_page, html5_page]
   end
 
   it "should have a default output_type of :xhtml" do
     @resources.each do |resource|
       Rack::Prettify.new(resource.rack_app).output_type.should == :xhtml
     end
   end

   it "should raise an error if an invalid output_type is supplied" do
     opts = { :output_type => 'blah' }
     @resources.each do |resource|
       lambda { Rack::Prettify.new(resource.rack_app, opts) }.
         should raise_error
     end
   end
  
   context "when receiving a request for a non-html resource" do
     it "should fall through to the app" do
       response = rack_app_response(javascript_resource, @env)
       response.should == "alert('Hello World!');\n"
     end
   end

   context "when receiving a request for an html resource" do
  
     it "should parse the document" do
       @resources.each do |resource|
         app   = Rack::Prettify.new(resource.rack_app)
         duped = Rack::Prettify.new(resource.rack_app)
         app.should_receive(:dup).and_return(duped)
         duped.should_receive(:parse)
         app.call(@env)
       end
     end
  
     context "when prettifying the document" do
 
       it "should insert an HTML5 DOCTYPE if there was no original DOCTYPE" do
         [html_5_page_without_doctype, xhtml_page_without_doctype].each do |r|
           response = rack_app_response(r, @env)
           response.split("\n")[0].should match("<!DOCTYPE html>")
         end
       end
 
       it "should output the DOCTYPE on a single line" do
         doctype_regex = /^<!DOCTYPE .*?>$/
         @resources.each do |resource|
           response = rack_app_response(resource, @env)
           response.split("\n")[0].should match(doctype_regex)
         end
       end

       it "should not adjust the DOCTYPE declaration" do
         doctype_regex = /(^<!DOCTYPE .*?>$)/m
         @resources.each do |resource|
           match = resource.original_content.match(doctype_regex)[0]
           doctype = match.split("\n").join.gsub(/\s+/, ' ')
           response = rack_app_response(resource, @env)
           response.split("\n")[0].should match(doctype)
         end
       end

       it "should not adjust the <html> tag" do
         html_tag_regex = /(^<html.*?>$)/
         @resources.each do |resource|
           original_html_tag = resource.original_content.match(html_tag_regex)[1]
           response = rack_app_response(resource, @env)
           response.split("\n")[1].should == original_html_tag
         end
       end

       it "should get rid of blank lines" do
         @resources.each do |resource|
           rack_app_response(resource, @env).should_not match(/^$\n/)
         end
       end

       it "should return expected, prettified output" do
         @resources.each do |resource|
           opts = { :output_type => :html }
           rack_app_response(resource, @env, opts).should == resource.expected_html

           opts = { :output_type => :xhtml }
           rack_app_response(resource, @env, opts).should == resource.expected_xhtml
         end
       end

       it "should update the content length if it was set" do
         @resources.each do |resource|
           app = Rack::Builder.new do
             use Rack::Lint
             use Rack::ContentLength
             use Rack::Prettify
             run resource.rack_app
           end
           status, headers, response = app.call(@env)
           expected_length = resource.expected_xhtml.length.to_s
           headers['Content-Length'].should == expected_length
         end
       end


       context "private methods" do
         context "#set_prettified_as_xhtml_or_html" do
           [:xhtml, :html].each do |kind|
             context "when output_type is #{kind}" do
               it "should call the Nokogiri #to_#{kind} method" do
                 opts = { :output_type => kind }
                 @resources.each do |resource|
                   app = Rack::Prettify.new(resource.rack_app, opts)
                   document = Nokogiri::HTML(resource.original_content)
                   app.instance_variable_set(:@document, document)
                   document.should_receive("to_#{kind}")
                   app.__send__(:set_prettified_as_xhtml_or_html)
                 end
               end
             end
           end
         end
       end

     end
  
   end
 
end
