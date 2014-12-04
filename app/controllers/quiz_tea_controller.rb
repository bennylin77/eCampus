class QuizTeaController < ApplicationController
  
  before_action :set_course, only: [:index, :new, :edit, :updateBasic]
  before_action :set_quiz, only: [:edit, :updateBasic]      
  # quiz for tea
  def index
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListDraft', {CourseId: @course_id, UserId: session[:user], IP: request.remote_ip })   
    if result['Success']
      @draft=result['DataCollection']
    else
      flash[:error]=result['ErrorMessage']   
    end    
  end
  
  def new
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/CreateDraft', {CourseId: @course_id, UserId: session[:user], IP: request.remote_ip })   
    if result['Success']
      @result=result['DataCollection']
      redirect_to controller: 'quiz_tea', action: 'edit', quiz_id: @result['QuizId'], course_id: @result['CourseId']          
    else
      flash[:error]=result['ErrorMessage']   
      redirect_to controller: 'quiz_tea', action: 'index', course_id: @course_id
    end    
  end
  
  def edit           
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewDraft', {QuizId: @quiz_id, CourseId: @course_id, UserId: session[:user], IP: request.remote_ip})   
    logger.info result
    if result['Success']
      @result=result['DataCollection']     
    else
      flash[:error]=result['ErrorMessage']   
    end     
  end  
  
  def updateBasic 
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/UpdateDraft', {Caption: params[:Caption], Content: params[:Content], BeginDate: params[:BeginDate], EndDate: params[:EndDate], QuizType: params[:QuizType],  
                                                                          Invited: params[:Invited], Notify: params[:Notify], IsDisorder: params[:IsDisorder], QuizId: params[:QuizId], CourseId: params[:CourseId], UserId: session[:user], IP: request.remote_ip})   

    if result['Success']
      render json: {success: true, msg: '成功更新基本設定' }  
    else
      render json: {success: false, msg: result['ErrorMessage'] }     
    end       
  end  
  
  def updatePool

    params[:Options].each_with_index do |value, index|   
      logger.info value
      logger.info params[:Answers][index]
    end
    
    
    render json: {success: true}     
  end
  
  
  private
    def set_course
      @course_id = params[:course_id]
    end 
    def set_quiz
      @quiz_id = params[:quiz_id]
    end     
    
end
