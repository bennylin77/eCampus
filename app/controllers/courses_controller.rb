class CoursesController < ApplicationController

  before_action :set_course, only: [:quiz]
  
  
  def info
  end

  def quiz 
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListDraft', {CourseId: @course_id})   
    logger.info result  
  end
  
  def new
  end
  
  def edit   
  end  
  
  private
    def set_course
      @course_id = params[:id]
    end  
end
