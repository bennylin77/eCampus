class QuizController < ApplicationController
    
  before_action :set_course, only: [:index]
  before_action :set_quiz, only: [:show, :take]    
  
# quiz for stu
  def index
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuiz', {CourseId: @course_id, UserId: session[:user], IP: request.remote_ip })    
    if result['Success']
      @quiz=result['DataCollection']
    else
      flash[:error]=result['ErrorMessage']   
      redirect_to controller: 'users', action: 'courses'
    end      
      
  end

  def show
    
  end

  def take 
    
  end  
  
  def submitAnswers
    params[:Answers].each_with_index do |value, index|   
      logger.info value
      logger.info value.second      
      
    end    
    render json: {success: true, msg: '成功更新基本設定' }  
  end
  
  private
    def set_course
      @course_id = params[:course_id]
    end 
    def set_quiz
      @quiz_id = params[:quiz_id]
    end     
  
end
