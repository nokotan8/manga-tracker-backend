# $LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'roda'
require 'mysql2'
require 'json'
require_relative 'lib/auth'

class App < Roda
  plugin :halt
  plugin :status_handler

  @@db_client = Mysql2::Client.new(:host => 'localhost', :database => 'mangatracker')
  route do |r|
    response.headers['Content-Type'] = 'application/json'

    r.is 'register' do
      r.post do
        username = JSON.parse(r.body.read)['username']
        if username.length < 1 || username.length > 20
          r.halt(400, { msg: 'username must be between 1 and 20 characters'}.to_json)
        end
        
        return Auth.register(@@db_client, response, username)
      end
    end
    r.is 'login' do
      r.post do
        client_id = JSON.parse(r.body.read)['acc_num']
        get_user = @@db_client.prepare('SELECT * from Users WHERE client_id = ?')
        users = get_user.execute(client_id)
        
        if (users.count != 1)
          puts users.count
          r.halt(404, { msg: 'user with specified account number does not exist' }.to_json)
        end
      
        return { username: users.first['username'] }.to_json 
      end 
    end
  end
  
  # Invalid path
  status_handler(404, keep_headers: ['Content-Type']) do
    { msg: 'the specified path does not exist' }.to_json
  end
  
  # Error handling
  plugin :error_handler do |e|
    puts e
    response.headers['Content-Type'] = 'application/json'
    response.status = 400
    { msg: 'the client sent a request that the server could not understand' }.to_json
  end
end

run App.freeze.app
