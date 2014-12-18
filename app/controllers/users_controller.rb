class UsersController < ApplicationController
  
  def courses
    result = postRequest('http://140.113.8.134/E35/autRCrsStu/OpenSetListStu', {accountid: currentUser.id})   
    @st_courses=result['DataCollection']
    result = postRequest('http://140.113.8.134/E35/autRCrsTea/OpenSetListTea', {accountid: currentUser.id})   
    @tea_courses=result['DataCollection']
  end
  
  def listCourses
    result_stu = postRequest('http://140.113.8.134/E35/autRCrsStu/OpenSetListStu', {accountid: currentUser.id})   
    course_stu=Array.new 
    unless result_stu['DataCollection'].blank?
      result_stu['DataCollection'].each do |s|
        course_stu <<
        {                
          name: s['zhTWName'],           
          course_id: s['CourseId']   
        }        
      end      
    end   
    result_tea = postRequest('http://140.113.8.134/E35/autRCrsTea/OpenSetListTea', {accountid: currentUser.id})   
    course_tea=Array.new 
    unless result_tea['DataCollection'].blank?
      result_tea['DataCollection'].each do |t|
        course_tea <<
        {                
          name: t['zhTWName'],           
          course_id: t['CourseId']              
        }        
      end      
    end 
    render json: {success: true, course_stu: course_stu, course_tea: course_tea  }  
  end
  
  def signIn
    result = postRequest('http://140.113.8.134/E35/AccountInfo/Authentication', {account: params[:account], password: params[:password]})    
    if result['ErrMsg'].blank? 
      session[:result]=result            
      result.store("success", true)
      render json: result
    else
      result.store("success", false)
      render json: result
    end
  end
  
  def logOut
    #result = postRequest('http://140.113.8.134/E35/AccountInfo/Logout', {TokenId: session[:token_id]})       
    session[:result]=nil
    redirect_to root_url  
  end
end
