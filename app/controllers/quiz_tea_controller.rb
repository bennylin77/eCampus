class QuizTeaController < ApplicationController
  
  before_action :set_course, only: [:index, :new]
  before_action :set_quiz, only: [:edit]      
  # quiz for tea
  def index
    #result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListDraft', {CourseId: @course_id, UserId: session[:user], IP: request.remote_ip })   
    #logger.info request.remote_ip
    #logger.info result  
  end
  
  def new
    #result = postRequest('http://140.113.8.134/Quiz/QuizV2/CreateDraft', {CourseId: @course_id})   
    redirect_to controller: 'quiz_tea', action: 'edit', id: '987654321'          
  end
  
  def edit           
  
  end  
  
  def updateBasic 
    render json: {success: true}   
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
      @course_id = params[:id]
    end 
    def set_quiz
      @quiz_id = params[:id]
    end     
    
end
