rack-prettify
=============

This piece of middleware automatically prettifies markup. It's not a validator and it won't adjust your `DOCTYPE` or `<html>` declarations. It just gets rid of blank lines, normalizes sequences of whitespace, adds closing tags where necessary, and re-indents your X(HTML). So, if your application produces ugly markup, or you use other middleware that regurgitates your markup, you can use rack-prettify to send your markup out into the world looking lean and clean.

Even though this middleware is built on top of the speedy [Nokogiri][1] library, it isn't really designed to be used in production for high-traffic sites. If you want to use it in such an environment, you better make sure you have a good caching system in place.

Why bother prettifying your (X)HTML output? A typical web user doesn't care about such things and doesn't even know what "View Source" means. And web developers wanting to look at the source will probably use freely available developer tools built for most modern web browsers (e.g., Web Inspector for WebKit browsers or Firebug for Firefox). Although these are great tools that automatically prettify the DOM tree, they display the *current* representation of the DOM (after it may have been manipulated by JavaScript) rather than the raw source. If you care about the raw source looking good and being readable, then rack-prettify can help.


Installation
------------

    $ gem install rack-prettify


Usage
-----

Simply `require 'rack/prettify'` where appropriate, or, if your framework plays nice with Bundler, make sure to add `gem "rack-prettify"` to your `Gemfile`. Then simply include the middleware in the Rack stack.

In Rails 3, for example, the `config/application.rb` might be adjusted accordingly:

    Module MyApp
      class Application < Rails::Application
        ...
        config.middleware.use Rack::Prettify
      end
    end

The order of middleware is very important. Make sure that Rack::Prettify is downstream of any other middleware that might rewrite the response body.

Rack::Prettify takes one option, `:output_type`, which is set to `:xhtml` by default. XHTML output simply means [XHTML self-closing tags][2] will be used. If, for some reason, you want your output to be HTML (i.e., no self-closing tags), simply use the `:html` option:

    use Rack::Prettify, :output_type => :html

Note that the `:output_type` option only affects self-closing tags--if your original HTML doesn't have closing `</p>` tags, for example, they *will* be added.


How It Works
------------

Rack::Prettify parses a `text/html` response using Nokogiri and transforms it to XML using an XSLT stylesheet. Because there's no "XHTML" output method in XSLT 1.0 (which is what Nokogiri uses), the transformed response is run through Nokogiri's `to_html` or `to_xhtml` method depending on the value of the `:output_type` option. Finally, the original `DOCTYPE` and `<html>` declarations are reinserted into the document. This means that you are responsible for writing these declarations correctly (though an HTML5 DOCTYPE will be added if no DOCTYPE is present).

The XSL stylesheet used by Rack::Prettify is a modification of [this stylesheet][3] that seems to have [made the rounds][4]. 


Considerations
--------------

Rack::Prettify is opinionated. The indentation is set to 2 spaces. That's not configurable. It also outputs nested elements on their own line. For example, suppose your original markup is this:

    <p>It is a tale full of <strong>sound</strong> and fury, signifying nothing.</p>

Rack::Prettify will give you:

    <p>
      It is a tale full of
      <strong>
        sound
      </strong>
      and fury, signifying nothing.
    </p>

Rack::Prettify is also aware of how browsers interpret whitespace. So, if your original markup was this:

    <p>It is a tale full of sound and <em>fury</em>, signifying nothing.</p>

and the comma was output on a separate line, the browser would render:

    It is a tale full of sound and fury , signifying nothing.

Not what we want. Instead, Rack::Prettify will give you this:

    <p>
      It is a tale full of sound and
      <em>fury</em>, signifying nothing.
    </p>


Known Issues
------------

Angle brackets within embedded JavaScript are escaped, thus breaking the JavaScript. For example, you might insert JavaScript in the body of your HTML (e.g., using the [Hivelogic Enkoder][5] to obfuscate an email address), which uses `/* <![CDATA[ */ ... /* ]]> */` to protect validators from balking. Rack::Prettify currently escapes the angle brackets which breaks the JavaScript. The suggested workaround is not to use CDATA declarations in embedded JavaScript. This is a bug. Patches are welcome.


[1]: http://nokogiri.org
[2]: http://bit.ly/9CdGLt
[3]: http://bit.ly/9BIKmb
[4]: http://gist.github.com/398334
[5]: http://hivelogic.com/enkoder/form
