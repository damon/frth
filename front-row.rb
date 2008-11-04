$:.unshift "sinatra/lib"

require 'sinatra'
require 'rubygems'
require 'active_support'
require 'json'
require 'open-uri'

TWITTER_WAIT_TIMEOUT = 60 unless Object.const_defined?("TWITTER_WAIT_TIMEOUT")

before do
  # set UTF-8
  header "Content-Type" => "text/html; charset=utf-8"

  # set css body id
  @body_id = "home"
  
  # set up a cache object
  CACHE = MemCache.new 'localhost:11211', :namespace => 'front_row' unless Object.const_defined?("CACHE")
end

get "/" do
  @title = "Tweet Row to History"
  erb :index
end

get "/tweets" do
  CACHE["tweets"]
end

get "/fetch-tweets-from-twitter" do
  return CACHE["tweets"] if CACHE["last_fetch"] && (Time.now - CACHE["last_Fetch"]) < TWITTER_WAIT_TIMEOUT
  
  CACHE["last_Fetch"] = Time.now
  CACHE["tweets"] = get_tweets
  
  redirect "/"
end

def tweeters
  %w|wbruce damon|
end

def tweet_terms
  %w|front|
end

def get_tweets
  begin
    tweeters.collect do |tweeter|
      get_tweets_for(tweeter)
    end
  rescue
    CACHE["tweets"] || {}
  end
end

def get_tweets_for(user)
  json = json_for_url(CGI.escape("from:#{user} #{tweet_terms.join(" ")}"))
  JSON.parse(json)
end

def json_for_url(terms)
  open(url % terms).read
end

def url; "http://search.twitter.com/search.json?q=%s"; end