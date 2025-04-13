# $LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'roda'
require 'mysql2'
require 'json'
require_relative 'routes/auth.rb'

$db_client = Mysql2::Client.new(:host => 'localhost', :database => 'mangatracker')

class App < Roda
  plugin :halt
  plugin :status_handler

  route do |r|
    response.headers['Content-Type'] = 'application/json'
    r.on 'auth' do
      r.run Auth
    end
  end

  # Invalid path
  status_handler(404, keep_headers: ['Content-Type']) do
    return { msg: 'the specified path does not exist' }.to_json
  end
  
  # Error handling
  plugin :error_handler do |e|
    puts e
    response.headers['Content-Type'] = 'application/json'
    response.status = 400
    return { msg: 'the client sent a request that the server could not understand' }.to_json
  end
end

run App.freeze.app
