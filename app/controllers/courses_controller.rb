class CoursesController < ApplicationController

  before_action :set_course, only: [:quiz, :newQuiz]
  before_action :set_quiz, only: [:editQuiz]  
  
  def info
  end

  def teaIndexQuiz
    #result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListDraft', {CourseId: @course_id, UserId: session[:user], IP: request.remote_ip })   
    #logger.info request.remote_ip
    #logger.info result  
  end
  
  def newQuiz
    #result = postRequest('http://140.113.8.134/Quiz/QuizV2/CreateDraft', {CourseId: @course_id})   
    redirect_to controller: 'courses', action: 'editQuiz', id: '987654321'          
  end
  
  def editQuiz     
  end  
  
  def updateBasicQuiz 
    render json: {success: true}   
  end  
  
  def updatePoolQuiz

    params[:Options].each_with_index do |value, index|   
      logger.info value
      logger.info params[:Answers][index]
    end
    
    
    render json: {success: true}     
  end
  
  
  private
    def set_course
      @course_id = params[:id]
    end 
    def set_quiz
      @quiz_id = params[:id]
    end     
end
