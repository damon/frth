$:.unshift 'sinatra/lib'
require 'sinatra'
 
Sinatra::Application.default_options.merge!(
  :run => false,
  :env => :production,
  :logging => true,
  :raise_errors => true,
  :views_directory => 'views'
)
 
require 'front-row'
run Sinatra.application
