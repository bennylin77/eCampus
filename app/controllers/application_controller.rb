require "eCampusAPI/not_success"
require "eCampusAPI/not_success_remote"
class ApplicationController < ActionController::Base
  rescue_from ECampusAPI::NotSuccess, with: :APINotSuccess
  rescue_from ECampusAPI::NotSuccessRemote, with: :APINotSuccessRemote
  protect_from_forgery with: :exception
  helper_method :currentUser  
  
  def currentUser
    @current_user||=User.new(session[:result]) if session[:result]
  end
  
  def postRequest( url, hash_data={})
    logger.info hash_data
    result = RestClient.post( url, hash_data)    
=begin    
    logger.info result.code
    logger.info result.cookies
    logger.info result.headers   
    logger.info result.to_str
=end
    result = result.force_encoding('utf-8').encode
    result = JSON.parse(result)
    checkAPISuccess(success: result['Success'], error_message: result['ErrorMessage'])    
    result       
  end
  
  def postRequestWithNestedJason(url, json_data, headers={})
    result = RestClient.post( url, json_data, headers)    
=begin    
    logger.info result.code
    logger.info result.cookies
    logger.info result.headers   
    logger.info result.to_str
=end
    result = result.force_encoding('utf-8').encode
    result = JSON.parse(result)
    checkAPISuccess(success: result['Success'], error_message: result['ErrorMessage'])  
    result    
  end
  
  def
  
  def getRequest    
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
  def checkAPISuccess(hash={})
    unless hash[:success]  
      if request.xhr? 
        raise ECampusAPI::NotSuccessRemote, hash[:error_message]
      else
        flash[:error]=hash[:error_message]         
        raise ECampusAPI::NotSuccess 
      end   
    end
  end
  
  def APINotSuccess        
    redirect_to root_url
  end

  def APINotSuccessRemote(exception)        
    render json: {success: false, message: exception.message }  
  end  
end
