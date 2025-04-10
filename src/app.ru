$LOAD_PATH.unshift File.dirname(__FILE__) + '/lib'

require 'roda'
require 'mysql2'
require 'json'
require 'id_gen'

class App < Roda
  @@client = Mysql2::Client.new(:host => 'localhost', :database => 'mangatracker')

  route do |r|
    response.headers['Content-Type'] = 'application/json'

    r.is 'register' do
      r.post do
        username = JSON.parse(r.body.read)['username']

        # get_user = @@client.prepare('SELECT * from Users WHERE client_id = ?')
        insert_user = @@client.prepare('INSERT INTO Users values(?, ?)')
        client_id = IdGen.generate
        
        insert_user.execute(client_id, username)
        
        { id: client_id }.to_json
      end
    end
    r.is 'login' do
      r.post do
        
      end 
    end
  end

  # Error handling
  plugin :error_handler do |e|
    response.headers['Content-Type'] = 'application/json'
    { error: 'something broke' }.to_json
  end
end

run App.freeze.app
