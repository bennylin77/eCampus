class ApplicationController < ActionController::Base
  rescue_from ECampusAPI::NotSuccess, with: :NormalHandler
  rescue_from ECampusAPI::NotSuccessRemote, with: :RemoteHandler
  rescue_from ECampusData::ValidationsFailed, with: :NormalHandler
  rescue_from ECampusData::ValidationsFailedRemote, with: :RemoteHandler 
  protect_from_forgery with: :exception
  helper_method :currentUser  
  #API user
  def currentUser
    @current_user||=User.new(session[:result]) if session[:result]
  end
  #API request
  def postRequest( url, hash_data={})
    logger.info hash_data
    result = RestClient.post( url, hash_data)    
    result = result.force_encoding('utf-8').encode
    result = JSON.parse(result)
    logger.info result
    checkAPISuccess(success: result['Success'], error_message: result['ErrorMessage'])    
    result       
  end
  
  def postRequestWithNestedJason(url, json_data, headers={})
    result = RestClient.post( url, json_data, headers)    
    result = result.force_encoding('utf-8').encode
    result = JSON.parse(result)
    checkAPISuccess(success: result['Success'], error_message: result['ErrorMessage'])  
    result    
  end
   
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
  
  def validations(data)
    validation_message=""    
    data.each do |d|
      case d[:type]
      when 'presence'
        if d[:data].blank?
          validation_message = validation_message+'請填寫 '+d[:title]+'<br>'
        end         
      when 'length'       
      when 'latter_than'  
         if d[:data][:first] > d[:data][:second]
          validation_message = validation_message+d[:title][:first]+' 比 '+d[:title][:second]+'晚<br>'
        end     
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
        raise ECampusAPI::NotSuccess, hash[:error_message] 
      end   
    end
  end
  
  def checkValidations(hash={})
    unless hash[:validation_message].blank?  
      if request.xhr? 
        raise ECampusData::ValidationsFailedRemote, hash[:validation_message]
      else        
        raise ECampusData::ValidationsFailed, hash[:validation_message] 
      end   
    end
  end  
  
  def NormalHandler(exception)  
    flash[:error]=exception.message           
    redirect_to root_url
  end

  def RemoteHandler (exception)        
    render json: {success: false, message: exception.message }  
  end  
end
