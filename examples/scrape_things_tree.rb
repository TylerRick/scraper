#!/usr/bin/env ruby

require 'crawler'

module SomeHierarchicalSiteScraper
  class ThingPage < Scraper::Page
    attr_reader :thing

  private
    def find_parent_thing
      thing_id = doc.at('#parent_thing a').try(:[], :href).use_match(/thing_id=(\w+)/)
      Thing.find_by_thing_id(thing_id)
    end

    def find_or_build_thing(thing_id)
      if (thing = Thing.find_by_thing_id(thing_id))
        thing
      else
        if looks_like_root_thing?
          return Thing.new(thing_id: thing_id)
        elsif parent
          parent_thing = parent.thing
        else
          parent_thing = find_parent_thing
        end
        parent_thing.children.build(thing_id: thing_id)
      end
    end

    def main_table
      @main_table ||= doc.at('#main_table')
    end

    def find_row(label)
      tr = main_table.search('td').detect {|td| td.inner_text =~ /#{label}/ }.try(:parent)
      tr && tr.search('td')
    end

    def get_name
      @thing.name = doc.at('#name').try(:inner_text) or raise UnexpectedPageStructureError.new("Couldn't find name")
    end

    def get_url
      website_td = find_row('Website:').try(:[], 1)
      return if website_td.nil?
      @thing.url = website_td.inner_text
    end

    def save_record
      @thing.updated_from_source_at = Time.now
      @thing.save or logger.info "Errors (#{@thing.errors.full_messages.join(', ')}) while saving #{@thing}.inspect"
    end

  public
    def process_page
      thing_id = doc.at('#thing_id').try(:inner_text) or raise UnexpectedPageStructureError.new("Couldn't find thing_id")
      @thing = find_or_build_thing(thing_id)

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
end

#---------------------------------------------------------------------------------------------------

if $0 == __FILE__
  Scraper.logger = Logger.new(STDERR)
  url = 'http://www.somehierarchicalsite/things/root'
  SomeHierarchicalSiteScraper::ThingPage.new(url).crawl
end
