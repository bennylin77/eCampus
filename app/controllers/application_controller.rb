class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
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
  
  def successHandler(hash={})
    unless hash[:success]  
      flash[:error]=hash[:error_message]         
      redirect_to hash[:redirect_to]
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
    end    
    validation_message   
  end

end
