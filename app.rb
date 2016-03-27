require 'sinatra'
require 'sinatra/base'
require "sinatra/config_file"
require 'sinatra/json'
require 'json'

class App < Sinatra::Base
  register Sinatra::ConfigFile
  config_file './config.yml'
  
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    username == ENV['CHEF_WORKSTATION_USERNAME'] and password == ENV['CHEF_WORKSTATION_PASSWORD']
  end

  post '/bootstrap_chef_client' do
    begin
      data = JSON.parse request.body.read
      flavor = data['flavor']
      system "cd ~/chef-repo && knife bootstrap #{data['ipv4_address']} -x root -A -P password --sudo --use-sudo-password -N #{data['title']} -r 'recipe[bitcoin::#{flavor}]'"
      system "cd ~/chef-repo && ssh root@#{data['ipv4_address']} 'sudo chef-client'"
    rescue => error
      puts "[ERROR] #{Time.now}: #{error.class}: #{error.message}"
    end
  end

  get '/confirm_client_bootstrapped' do
    begin
      puts "Confirming that Chef Client #{data['title']} has been boostrapped"
      if "cd ~/chef-repo && knife node show #{params['title']}"
        # Do Success Things
      else
        # Do Error Things
      end
    rescue => error
      puts "[ERROR] #{Time.now}: #{error.class}: #{error.message}"
    end
  end
end