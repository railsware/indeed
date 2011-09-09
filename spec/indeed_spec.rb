require 'spec_helper'
require "net/http"
require "yajl"

describe Indeed do
  before(:each) do
    Net::HTTP.stubs(:get).returns(Yajl::Encoder.encode({

      "version" => 2,
      "query" => "java",
      "location" => "Boston",
      "dupefilter" => true,
      "highlight" => true,

      "radius" => 25,

      "start" => 1,
      "end" => 10,
      "totalResults" => 822,
      "pageNumber" => 0,
      "results" => [{
      "jobtitle" => "Java/JEE Software Developers",
      "company" => "360 Training",
      "city" => "Austin",
      "state" => "TX",
      "country" => "US",
      "formattedLocation" => "Austin, TX",
      "source" => "360 Training",
      "date" => "Sun, 24 Oct 2010 15=>49=>31 GMT",
      "snippet" => "multiple positions for <b>Java</b>/JEE developers. We are looking for well-rounded developers with several years of experience in the <b>Java</b>/JEE platform, and who are...",
      "url" => "http=>//www.indeed.com/viewjob?jk=456064eba76fd546&indpubnum=7570038743238473&atk=15fh6j9pl0k106a9",
      "onmousedown" => "indeed_clk(this, '6386');",
      "latitude" => 30.266483,
      "longitude" => -97.74176,
      "jobkey" => "456064eba76fd546",
      "sponsored" => false,
      "expired" => false,
      "formattedLocationFull" => "Austin, TX",
      "formattedRelativeTime" => "16 hours ago"
    }]
    }))
  end


  describe ".search" do
    subject { Indeed.search(:q => "Java", :l => "Boston") }
    
    it { should be_a(Array) }

    it {should_not be_empty }
    it "should get total number of results from indeed" do 
      subject.total.should == 822
    end
  end

  describe ".get" do
    subject { Indeed.get(123) }
    it { should be_a(Array) }
    it {should_not be_empty }
  end

  context "when Indeed returns html instead of json" do
    before(:each) do
      
      Net::HTTP.stubs(:get).returns(<<-HTML)
    <h1>Internal Error</h1>
HTML
    end

    it "should raise exception" do
      lambda {
        Indeed.search({})
      }.should raise_error(IndeedError)
    end
    
  end
end
