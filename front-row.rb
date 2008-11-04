$:.unshift "sinatra/lib"

require 'sinatra'
require 'rubygems'
require 'active_support'
require 'json'

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
  
end

get "/fetch-tweets-from-twitter" do
  return if CACHE["last_fetch"] && (Time.now - CACHE["last_Fetch"]) < TWITTER_WAIT_TIMEOUT
  
  CACHE["tweets"] = get_tweets
end

def tweeters
  %w|wbruce damon|
end

def tweet_terms
  %w|frth|
end

def get_tweets
  TWEETERS.collect do |tweeter|
    get_tweets_for(tweeter)
  end
end

def get_tweets_for(user)
  json_for_url(CGI.escape("from:#{user} #{tweet_terms.join(" ")}"))
end

def json_for_url(terms)
  open(url % terms).read
end

def url; "http://search.twitter.com/search.json?q=%s"; end