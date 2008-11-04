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
  CACHE["tweets"] = get_tweets.map { |tweet| format_tweet(tweet) }
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

def format_tweet(tweet)
  tweet['formatted'] = gravatar_for_tweet(tweet) << format_content(tweet['text'])
  tweet
end

def format_content(text)
  result = text.dup
  # Make sure we have them small-to-big
  urls = URI.extract(text).uniq.sort
  urls.each do |raw_url|
    inside = case URI.parse(raw_url).host
    when 'snaptweet.com'
      %(<img src='#{raw_url}.jpg' alt=''/>)
    else
      raw_url
    end
    result.gsub!(raw_url, %(<a href='#{raw_url}'>#{inside}</a>))
  end
  result.gsub(/(^|\s)@([[:alnum:]_]+)/) do 
    "#{$1}<a href='http://twitter.com/#{$2}' title='See twitter profile for #{$2}'>@#{$2}</a>"
  end
end

def sort_tweets(tweets)
  tweets.sort {|a,b| a["id"] <=> b["id"]}
end

def get_tweets_for(user)
  json = json_for_url(CGI.escape("from:#{user} #{tweet_terms.join(" ")}"))
  JSON.parse(json)["results"].collect {|t| t["formatted"] = format_content(t["text"])}
end

def json_for_url(terms)
  open(url % [terms, 0]).read
end

def url; "http://search.twitter.com/search.json?q=%s&since_id=%s"; end

def gravatar_for_tweet(tweet)
  %(<img class='gravatar' src='#{gravatar_url tweet['from']}' alt='#{tweet['from']}'/>)
end

def gravatar_url(email, gravatar_options={})

  # Default highest rating.
  # Rating can be one of G, PG, R X.
  # If set to nil, the Gravatar default of X will be used.
  gravatar_options[:rating] ||= nil

  # Default size of the image.
  # If set to nil, the Gravatar default size of 80px will be used.
  gravatar_options[:size] ||= '40px'

  # Default image url to be used when no gravatar is found
  # or when an image exceeds the rating parameter.
  gravatar_options[:default] ||= nil

  # Build the Gravatar url.
  grav_url = 'http://www.gravatar.com/avatar.php?'
  grav_url << "gravatar_id=#{Digest::MD5.new.update(email)}" 
  grav_url << "&rating=#{gravatar_options[:rating]}" if gravatar_options[:rating]
  grav_url << "&size=#{gravatar_options[:size]}" if gravatar_options[:size]
  grav_url << "&default=#{gravatar_options[:default]}" if gravatar_options[:default]
  grav_url
end