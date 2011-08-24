#---------------------------------------------------------------------------------------------------
require 'net/http'
require 'net/https'
#require 'open-uri'
#require 'uri'
#require 'logger'

require 'mechanize'
require 'retryable'
require 'active_support/core_ext/module/attribute_accessors'

#---------------------------------------------------------------------------------------------------

class String
  def use_match(regexp)
    self =~ regexp
    $1 || $&
  end
end

#---------------------------------------------------------------------------------------------------

module Scraper
  mattr_accessor :logger

  def self.agent
    @@agent ||= Mechanize.new do |agent|
      # TOOD: should be configurable
      agent.user_agent_alias = 'Mac Safari'
      if false
        agent.log = Logger.new(STDERR)
      end
    end
  end

  class Page
    # parent page if we are crawling a hierarchically-structured site
    attr_reader :parent
    attr_reader :doc

    def agent
      Scraper.agent
    end

    def initialize(url, options = {})
      @url = url
      @parent = options.delete(:parent)
      @options = options
    end

    def crawl
      fetch
      process_page
      continue
    end

    def logger
      Scraper.logger
    end

  protected
    def fetch
      # Or just rescue their parent class, SystemCallError?
      retryable(:on => [Errno::ETIMEDOUT, Errno::ECONNRESET],
        :tries => 3,
        :sleep => lambda { |n| (3**n).tap {|delay| puts "Sleeping for #{delay} seconds..."}  }
      ) do |retries, exception|
        puts "Failed with exception: #{exception} (attempt # #{retries}). Retrying..." if retries > 0

        print "\nFetching ... "
        @doc = agent.get(@url)
        puts @doc.uri
      end
    end

    def crawl_child(klass, url)
      klass.new(url, :parent => self).crawl
    end

  end # Page

  class UnexpectedPageStructureError < StandardError; end
end


#---------------------------------------------------------------------------------------------------

