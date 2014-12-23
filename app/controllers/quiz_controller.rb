class QuizController < ApplicationController
    
  before_action :set_course, only: [:show, :take, :index]
  before_action :set_quiz, only: [:show, :take, :submitAnswers]    
  
# quiz for stu
  def index
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuiz', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })    
    @quiz=result['DataCollection'] 
    unless @quiz.blank?
      @quiz.each do |q|  
        r=postRequest('http://140.113.8.134/Quiz/QuizV2/StatisticExaminee', { QuizId: q['QuizId'], UserId: currentUser.id, IP: request.remote_ip})                
        q.store('AbsenteeCount', r['DataCollection']['AbsenteeCount'] )
        q.store('RequisiteDoneCount', r['DataCollection']['RequisiteDoneCount'] )        
      end
    end              
  end

  def show
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewQuiz', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip })    
    @quiz=result['DataCollection']
    result_sheets = postRequest('http://140.113.8.134/Quiz/QuizV2/ListSheets', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip })    
    @sheets=result_sheets['DataCollection']    
  end

  def take 
    # init
    session[:submit_id]=nil  
    session[:get_Amount]=nil  
    session[:skip_Amount]=nil 
    session[:total_Amount]=nil
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewQuiz', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip })    
    session[:skip_Amount]=0
    if result['DataCollection']['DisplayType']==0
      # display all
      session[:get_Amount]=''
      session[:skip_Amount]=''
      session[:total_Amount]=''      
    else
      # display one by one
      session[:get_Amount] = 1
      session[:skip_Amount] = 0
      result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuestion', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip})       
      session[:total_Amount] = result['DataCollection'].count    
    end         
  end  
  
  def submitAnswers   
    submit_id=session[:submit_id].blank? ? "" : session[:submit_id]
    material =Array.new  
    params[:Answers].each_with_index do |value, index|        
      material <<
      {
        SubmitId: submit_id,
        PoolId: params[:PoolIds][index],
        Answer: value.second.join("|"),
        Serial: "" 
      }     
    end 
    is_done = session[:total_Amount].to_i-session[:skip_Amount].to_i-session[:get_Amount].to_i == 0 ? true:false
    result = postRequestWithNestedJson('http://140.113.8.134/Quiz/QuizV2/SubmitSheet', {IsDone: is_done, Material: material, QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip }.to_json, {:content_type => :json, :accept => :json}) 
    
    unless result['DataCollection'].blank?
      result['DataCollection'].each do |q| 
        session[:submit_id]=q['SubmitId']
      end 
      session[:skip_Amount]=session[:skip_Amount]+session[:get_Amount]                
    end     
    render json: {success: true, left_count: session[:total_Amount].to_i-session[:skip_Amount].to_i}     
  end
  
  def listQuestions
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuestion', {getAmount: session[:get_Amount], skipAmount: session[:skip_Amount], QuizId: params[:QuizId], UserId: currentUser.id, IP: request.remote_ip})         
    pools=Array.new  
    unless result['DataCollection'].blank?
      result['DataCollection'].each do |q|  
        result_pool = postRequest('http://140.113.8.134/Quiz/QuestionPool/ViewPool', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})   
        result_ops = postRequest('http://140.113.8.134/Quiz/QuestionPool/ListOption', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})   
        options=Array.new      
        unless result_ops['DataCollection'].blank?          
          result_ops['DataCollection'].each do |o|
            options <<
            {                
              option_id: o['OptionId'],
              content: o['Content']              
            }  
          end
        end      
        pools <<
        {
          course_id: q['CourseId'],
          pool_id: q['PoolId'],
          question_id: q['QuestionId'],
          category: result_pool['DataCollection']['Category'],
          subject: result_pool['DataCollection']['Subject'],
          comment: result_pool['DataCollection']['Comment'],
          options: options
        }            
      end
    end
    render json: {success: true, pools: pools, left_count: session[:total_Amount].to_i-session[:skip_Amount].to_i-session[:get_Amount].to_i}         
  end
  
  
  private
    def set_quiz
      @quiz_id = params[:quiz_id]
    end     
  
end
