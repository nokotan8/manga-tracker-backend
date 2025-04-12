class Auth
  def self.register(db_client, response, username)
    client_id = generate

    insert_user = db_client.prepare('INSERT INTO Users values(?, ?)')    
    insert_user.execute(client_id, username)
        
    response.status = 201
    { id: client_id }.to_json
  end

  def self.login(db_client, response, login)
    
  end
  
  private

  def self.generate
    # One random number doesn't have enough digits
    parts1 = rand.to_s[3..]
    parts2 = rand.to_s[3..]
    return "#{parts1[0..3]}-#{parts1[4..7]}-#{parts2[0..3]}-#{parts2[4..7]}"
  end
end