class User 
  attr_accessor :id, :name, :token_id, :role
  
  def initialize(hash={})
    self.id=hash['AccountId']
    self.name=hash['Name']   
    self.token_id=hash['TokenId'] 
    self.role="Guest"
  end
 
  def setPermission(controller,courseList,id)
	stuCourseList=courseList[:stuCourseList]
	teaCourseList=courseList[:teaCourseList]
	if controller.include?("_tea")
		if teaCourseList.include?(id)
			self.role="TA"
		else
			self.role="Guest"
		end
	else
		if stuCourseList.include?(id)
			self.role="Student"
		else
			self.role="Guest"
		end
	end
  end
end