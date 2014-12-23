class User 
  attr_accessor :id, :name, :token_id
  
  def initialize(hash={})
    self.id=hash['AccountId']
    self.name=hash['Name']   
    self.token_id=hash['TokenId'] 
         
  end
 
end