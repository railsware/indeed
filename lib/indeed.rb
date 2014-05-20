require 'net/http'
require 'cgi'
require "uri"
require "yajl"



class Indeed

  SEARCH_URL = URI.parse("http://api.indeed.com/ads/apisearch")
  GET_URL = URI.parse("http://api.indeed.com/ads/apigetjobs")

  def self.instance
    @instance ||= Indeed.new
  end

  def self.search(options)
    self.instance.search(options)
  end

  def self.key=(key)
    self.default_params[:publisher] = key
  end

  def self.default_params
    self.instance.default_params
  end

  def self.get(*job_keys)
    self.instance.get(job_keys)
  end

  def search(options)
    options = default_params.merge(options)
    http_get(SEARCH_URL.host, SEARCH_URL.path, options)
  end

  def get(jobkeys)
    jobkeys = Array(jobkeys)
    http_get(
      GET_URL.host,
      GET_URL.path,
      :jobkeys => jobkeys.join(','),
      :v => 2,
      :publisher => default_params[:publisher],
      :format => "json"
    )
  end

  def default_params
    @default_params ||= {
      :v => 2,
      :format => "json",
      :sort => "relevance",
      :radius => 25,
      :st => nil,
      :jt => nil,
      :limit => 30,
      :highlight => 0,
      :filter => 1,
      :fromage => 1,
      :latlong => 1,
      :co => "us",
      :userip => "77.88.216.22",
      :useragent => "Mozilla/4.0 Firefox",
    }
  end

  protected
  def http_get(domain, path, params = {})
    log("Indeed query", params.inspect)
    query = "#{path}?#{params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')}"
    begin
      data = Yajl::Parser.parse(Net::HTTP.get(domain, query))
    rescue Yajl::ParseError
      raise IndeedError, 'Did not get a valid JSON response from Indeed'
    end

    if error = data["error"]
      raise IndeedError, error
    end
    result = IndeedResult.new(data["results"], data["totalResults"])

    return result
  end


  def log(message, dump)
    if defined?(Rails)
      Rails.logger.debug(format_log_entry(message, dump))
    end
  end

  def format_log_entry(message, dump = nil)
    if defined?(Rails) && Rails.configuration.respond_to?(:colorize_logging) && Rails.configuration.colorize_logging
      message_color, dump_color = "4;32;1", "0;1"
      log_entry = "  \e[#{message_color}m#{message}\e[0m   "
      log_entry << "\e[#{dump_color}m%#{String === dump ? 's' : 'p'}\e[0m" % dump if dump
      log_entry
    else
      "%s  %s" % [message, dump]
    end
  end

end

class IndeedResult < Array

  attr_accessor :totalResults

  def initialize(array, total)
    super(array)
    self.totalResults = total
  end
end

class IndeedError < StandardError

end
