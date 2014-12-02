class QuizController < ApplicationController
    
  before_action :set_course, only: [:index]
  before_action :set_quiz, only: [:show, :take]    
  
# quiz for stu
  def index
    #result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListDraft', {CourseId: @course_id, UserId: session[:user], IP: request.remote_ip })   
    #logger.info request.remote_ip
    #logger.info result  
  end

  def show
    
  end

  def take 
    
  end  
  
  private
    def set_course
      @course_id = params[:id]
    end 
    def set_quiz
      @quiz_id = params[:id]
    end     
  
end
