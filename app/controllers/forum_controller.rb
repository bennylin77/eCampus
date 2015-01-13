class ForumController < ApplicationController
  before_action :set_course, only: [:index,:show, :new, :newTopic]
	
  def index
		forums=postRequest(apiURL+"Forum/ListbyCourse",{:courseId=>@course_id})
		@res=forums["DataCollection"]
		@res.each do |forum|
			contents=postRequest(apiURL+"Forum/ForumContentList",{:parentId=>forum["ForumId"]})
			forum["Content"]=contents["DataCollection"]
		end
  end
	
	def show
		
	end
	def newTopic
	
	end
  def new
	
  end
  def create
		payload={
			:accountId=>currentUser.id,
			:courseId=>params[:course_id],
			:title=>params[:title],
			:content=>params[:content]
		}
		@res=postRequest(apiURL+"Forum/CreateForum",payload)
		redirect_to :controller=>"forum", :action=>"index"
  end
  def createContent
		payload={
			:accountId=>currentUser.id,
			:forumId=>params[:forum_id],
			:parentId=>params[:forum_id],
			:isReply=>false,
			:content=>params[:content]
		}
		@res=postRequest(apiURL+"Forum/CreateForumContent",payload)
		redirect_to :controller=>"forum", :action=>"index"
  end
private
  def apiURL
	return "http://140.113.159.28/E/"
  end
  
end
