Scraper
=======

Getting started
---------------

Add to your Gemfile:

    gem 'scraper', :git => 'git://github.com/TylerRick/scraper.git'

Subclass `Scraper::Page` and provide, at a minimum, a `process` and `continue` method.

Example:

    class ThingPage < Scraper::Page
      attr_reader :thing

      def process_page
        thing_id = doc.at('#thing_id').try(:inner_text) or raise UnexpectedPageStructureError.new("Couldn't find thing_id")
        @thing = Thing.find_by_thing_id(thing_id) || Thing.new(thing_id: thing_id)

        get_name
        get_url

        save_record
      end

      def continue
        doc.search('#children_things a').select do |a|
          a['href'] =~ %r(^/things/)
        end.each do |a|
          crawl_child ThingPage, a['href']
        end
      end
    end

`parent` will automatically be available to the next `Page` object when you use `crawl_child`.

To start crawling:

    ThingPage.new(url).crawl

Motivation
----------

After looking at the state of the other existing Ruby scraping libraries, I decided none of them really did what I needed. So I extracted some patterns from some of the existing scrapers I've written with Mechanize and Nokogiri and this library was born!

Other libraries I looked at:
* **scrubyt** (no longer maintained, doesn't even run on Ruby 1.9, but otherwise looked interesting)
* **scrapi** (nice DSL in some ways, but in the end, seemed like too much sugar and not enough meat; it was hard to figure out how to do anything beyond their simple examples; it didn't seem like it could help me do what I was trying to do; and it didn't use Nokogiri)


License
-------

This is free software available under the terms of the MIT license.

To do
-----

* Write tests
* etc.
