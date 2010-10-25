require 'net/http'
require 'cgi'
require "uri"
require "yajl"



class Indeed

  URL = URI.parse("http://api.indeed.com/ads/apisearch")

  def self.instance
    @instance ||= Indeed.new
  end

  def self.get(options)
    self.instance.get(options)
  end

  def self.key=(key)
    self.default_params[:publisher] = key
  end

  def self.default_params
    self.instance.default_params
  end

  def get(options)
    location = Array(options.delete(:l))
    if location.empty?
      location << nil
    end
    result = []
    location.each do |item|
      params = default_params.merge(options).merge(:l => item )
      log("Indeed query", params.inspect)
      response = Yajl::Parser.parse(http_get(
        URL.host,
        URL.path,
        params
      ))
      if error = response["error"]
        raise IndeedError, error
      end
      result << response["results"]
    end
    result.flatten
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
    query = "#{path}?#{params.collect { |k,v| "#{k}=#{CGI::escape(v.to_s)}" }.join('&')}"
      #raise query
      return Net::HTTP.get(domain, query)
  end


  def log(message, dump)
    if defined?(Rails)
      Rails.logger.debug(format_log_entry(message, dump))
    end
  end

  def format_log_entry(message, dump = nil)
    if ActiveRecord::Base.colorize_logging
      message_color, dump_color = "4;32;1", "0;1"
      log_entry = "  \e[#{message_color}m#{message}\e[0m   "
      log_entry << "\e[#{dump_color}m%#{String === dump ? 's' : 'p'}\e[0m" % dump if dump
      log_entry
    else
      "%s  %s" % [message, dump]
    end
  end

end

class IndeedError < StandardError
  
end
