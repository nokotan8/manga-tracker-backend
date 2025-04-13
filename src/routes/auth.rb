require 'roda'
require 'json'

class Auth < Roda
  route do |r|
    response.headers['Content-Type'] = 'application/json'
    r.is 'register' do
      r.post do
        username = JSON.parse(r.body.read)['username']
        if username.length < 1 || username.length > 20
          r.halt(400, { msg: 'username must be between 1 and 20 characters' }.to_json)
        end
        
        client_id = generate
        check_id = $db_client.prepare('SELECT * FROM Users WHERE client_id = ?')
        while 1 == 1 
          users = check_id.execute(client_id)
          if users.count != 0
            client_id = generate
          else
            break
          end
        end
        insert_user = $db_client.prepare('INSERT INTO Users values(?, ?)')    
        insert_user.execute(client_id, username)
            
        response.status = 201
        return { id: client_id }.to_json
      end
    end

    r.is 'login' do
      r.post do
        client_id = JSON.parse(r.body.read)['acc_num']
        get_user = $db_client.prepare('SELECT * from Users WHERE client_id = ?')
        users = get_user.execute(client_id)
        
        if (users.count != 1)
          r.halt(400, { msg: 'user with specified account number does not exist' }.to_json)
        end
      
        return { username: users.first['username'] }.to_json 
      end 
    end
  end
end

def generate
  # One random number doesn't have enough digits
  parts1 = rand.to_s[3..]
  parts2 = rand.to_s[3..]
  
  return "#{parts1[0..3]}-#{parts1[4..7]}-#{parts2[0..3]}-#{parts2[4..7]}"
end