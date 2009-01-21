$:.unshift 'sinatra/lib'
require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  :logging => true,
  :raise_errors => true
)
 
require 'front-row'
run Sinatra.application
