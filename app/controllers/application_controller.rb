class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  
  def postRequest(url, hash={})
    result = RestClient.post( url, hash)    
    logger.info result 
    #logger.info result.cookies 
    result = result.force_encoding('utf-8').encode
    JSON.parse(result)        
  end
  
  def getRequest
    
  end
  
end
