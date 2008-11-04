$:.unshift "sinatra/lib"

require 'sinatra'
require 'rubygems'
require 'active_support'

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
end