class CoursesTeaController < ApplicationController
  
  before_action :set_course, only: [:info]
  
  def info
  end
  
  
  private
    def set_course
      @course_id = params[:course_id]
    end  

end
