class ForumController < ApplicationController
  before_action :set_course, only: [:index, :new]
	
  def index
	@res=postRequest(apiURL+"Forum/ListbyCourse",{:courseId=>"00000000-0000-0000-0000-000000000000"})
	
  end
  def new
	
  end
  def create
	payload={
		:accountId=>currentUser.id,
		:courseId=>@course_id,
		:title=>params[:title]
	}
	@res=postRequest(apiURL+"Forum/CreateForum",payload)
  end
  
private
  def apiURL
	return "http://140.113.159.28/E/"
  end
  
end
