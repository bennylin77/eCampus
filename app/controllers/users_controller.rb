class UsersController < ApplicationController
  
  
  def courses
 
    result = postRequest('http://140.113.8.134/E35/autRCrsStu/OpenSetListStu', {accountid: session[:user]})   
    if result['Success']
      @st_courses=result['DataCollection']
    else
      flash[:error]=result['ErrorMessage']   
    end
  
    result = postRequest('http://140.113.8.134/E35/autRCrsTea/OpenSetListTea', {accountid: session[:user]})   
    if result['Success']
      @tea_courses=result['DataCollection']
    else
      flash[:error]=result['ErrorMessage']   
    end
   
  end
  
  def signIn
    result = postRequest('http://140.113.8.134/E35/AccountInfo/Authentication', {account: params[:account], password: params[:password]})    
  
    if result['ErrMsg'].blank?   
      session[:user]=result['AccountId']      
      session[:name]=result['Name']  
      session[:token_id]=result['TokenId']        
      result.store("success", true)
      render json: result
    else
      result.store("success", false)
      render json: result
    end
  end
  
  def logOut
    #result = postRequest('http://140.113.8.134/E35/AccountInfo/Logout', {TokenId: session[:token_id]})       
    session[:user]=nil
    session[:name]=nil
    redirect_to root_url  
  end
end
