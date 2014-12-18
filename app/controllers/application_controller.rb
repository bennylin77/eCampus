require "eCampusAPI/not_success"
class ApplicationController < ActionController::Base
  rescue_from ECampusAPI::NotSuccess, with: :APINotSuccess
  protect_from_forgery with: :exception
  helper_method :currentUser  
  
  def currentUser
    @current_user||=User.new(session[:result]) if session[:result]
  end
  
  def postRequest(url, hash={})
    logger.info hash
    result = RestClient.post( url, hash)    
=begin    
    logger.info result.code
    logger.info result.cookies
    logger.info result.headers   
    logger.info result.to_str
=end
    result = result.force_encoding('utf-8').encode
    JSON.parse(result)        
  end
  
  def postRequestWithNestedJason(url, jason_data, params={})
    result = RestClient.post( url, jason_data, params)    
=begin    
    logger.info result.code
    logger.info result.cookies
    logger.info result.headers   
    logger.info result.to_str
=end
    result = result.force_encoding('utf-8').encode
    JSON.parse(result)        
  end
  
  def
  
  def getRequest    
  end
  
  def checkAPISuccess(hash={})
    unless hash[:success]  
      flash[:error]=hash[:error_message]         
      raise ECampusAPI::NotSuccess
    end
  end
  
  def set_course
    unless params[:course_id].blank?
      @course_id = params[:course_id]
    else
      flash[:error]='沒有指定課程'        
      redirect_to root_url   
    end
  end   
  
  def validations(hash={})
    validation_message=""
    case hash[:type]
    when 'presence'
      if hash[:data].blank?
        validation_message='請填寫 '+hash[:title]+'<br>'
      end         
    when 'length'
      
    when 'latter_than'  
       if hash[:data][:first] > hash[:data][:second]
        validation_message=hash[:title][:first]+' 比 '+hash[:title][:second]+'晚<br>'
      end     
    end    
    validation_message   
  end
 
private
    def APINotSuccess        
      redirect_to root_url
    end
end
