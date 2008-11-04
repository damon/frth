$:.unshift 'sinatra/lib'
require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production
)
 
require 'front-row'
run Sinatra.application