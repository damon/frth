$:.unshift "sinatra/lib"

require 'sinatra'
require 'rubygems'
require 'active_support'
require 'json'
require 'open-uri'

TWITTER_WAIT_TIMEOUT = 6 unless Object.const_defined?("TWITTER_WAIT_TIMEOUT")

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
  tweets = CACHE["tweets"]
  if params["since_id"]
    tweets.reject! {|tweet| tweet["id"] <= params["since_id"].to_i }
  end
  tweets.to_json
end

get "/fetch" do
  return CACHE["tweets"] if CACHE["last_fetch"] && (Time.now - CACHE["last_fetch"]) < TWITTER_WAIT_TIMEOUT

  CACHE["last_fetch"] = Time.now
  CACHE["tweets"] = get_tweets
  puts "Cached #{CACHE["tweets"].size} tweet(s)"
  redirect "/tweets"
end

def tweeters
  %w|wbruce damon|
end

def tweet_terms
  %w|front|
end

def get_tweets
  begin
    tweets = tweeters.collect do |tweeter|
      get_tweets_for(tweeter)
    end.flatten
    sort_tweets(tweets)
  rescue
    CACHE["tweets"] || {}
  end
end

def format_content(text)
  text
end

def sort_tweets(tweets)
  tweets.sort {|a,b| b["id"] <=> a["id"]}
end

def get_tweets_for(user)
  json = json_for_url(CGI.escape("from:#{user} #{tweet_terms.join(" ")}"))
  JSON.parse(json)["results"].collect {|t| t["formatted"] = format_content(t["text"])}
end

def json_for_url(terms)
  open(url % [terms, 0]).read
end

def url; "http://search.twitter.com/search.json?q=%s&since_id=%s"; end