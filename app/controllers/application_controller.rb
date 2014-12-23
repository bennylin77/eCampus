class ApplicationController < ActionController::Base
  rescue_from ECampusAPI::NotSuccess, with: :normalHandler
  rescue_from ECampusAPI::NotSuccessRemote, with: :remoteHandler
  rescue_from ECampusData::ValidationsFailed, with: :validationsHandler
  rescue_from ECampusData::ValidationsFailedRemote, with: :validationsRemoteHandler 
  protect_from_forgery with: :exception
  helper_method :currentUser  
  #API user
  def currentUser
    @current_user||=User.new(session[:result]) if session[:result]
  end
  #API request
  def postRequest( url, hash_data={})
    logger.info url
    logger.info hash_data
    result = RestClient.post( url, hash_data)    
    result = result.force_encoding('utf-8').encode
    result = JSON.parse(result)
    logger.info result
    checkAPISuccess(success: result['Success'], error_message: result['ErrorMessage'])    
    result       
  end
  
  def postRequestWithNestedJson(url, json_data, headers={})
    logger.info url
    logger.info json_data   
    result = RestClient.post( url, json_data, headers)    
    result = result.force_encoding('utf-8').encode
    result = JSON.parse(result)
    logger.info result    
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
	
	if currentUser
		currentUser.setPermission(params[:controller],getCourseList,@course_id)
	else
		
	end
	
  end   
  
  def validations(data)
    validation_result = [] 
    data.each do |d|
      case d[:type]
      when 'presence'
        if d[:data].blank?
          validation_result.push({type: 'presence', message: '請填寫 '+d[:title]})
        end         
      when 'length'       
      when 'latter_than'  
         if d[:data][:first] > d[:data][:second]
          validation_result.push({type: 'latter_than', message: d[:title][:first]+' 比 '+d[:title][:second]+'晚'})                
        end     
      end
    end      
    validation_result  
  end    
 


  def getCourseList
	result_stu = postRequest('http://140.113.8.134/E35/autRCrsStu/OpenSetListStu', {accountid: currentUser.id})   
    #course_stu=Array.new 
    unless result_stu['DataCollection'].blank?
      stuCourseList=result_stu['DataCollection'].map{|res|res['CourseId']}#{
		#:name=> res['zhTWName'],           
        #:course_id=>res['CourseId']
	 # }}
    end   
    result_tea = postRequest('http://140.113.8.134/E35/autRCrsTea/OpenSetListTea', {accountid: currentUser.id})   
    unless result_tea['DataCollection'].blank?
      teaCourseList=result_tea['DataCollection'].map{|res|res['CourseId']}#.each.map{|res|{
#		:name=> res['zhTWName'],           
#        :course_id=>res['CourseId']
#	  }}
    end
	return {:stuCourseList=>stuCourseList, :teaCourseList=>teaCourseList}
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
    unless hash[:validations].count==0  
      if request.xhr? 
        raise ECampusData::ValidationsFailedRemote.new(errors: hash[:validations])
      else        
        raise ECampusData::ValidationsFailed.new(errors: hash[:validations], redirect_path: hash[:redirect_path])
      end   
    end
  end 
    
  def normalHandler(exception)  
    flash[:error]=exception.message           
    redirect_to root_url
  end

  def remoteHandler (exception)            
    render json: {success: false, message: exception.message }  
  end  
  
  def validationsHandler(exception)
    exception.args[:errors].each do |e|  
      flash[:error]=flash[:error]+e.message+'<br>'
    end 
    redirect_to exception.args['redirect_path']         
  end
  def validationsRemoteHandler(exception)
    message=""
    exception.args[:errors].each do |e|  
      logger.info e
      message=message+e[:message]+'<br>'
    end        
    render json: {success: false, message: message }      
  end  

  
end
