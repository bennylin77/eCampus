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
    @quiz=result['DataCollection']      
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
    unless result['DataCollection'].blank?
      new_pools = { '1'=> [], '2'=> [], '3'=> [],'5'=> []}
      pools_score={ '1'=> 0, '2'=> 0, '3'=> 0, '5'=> 0}
      result['DataCollection'].each do |q|  
        if params[:Draft].to_b
          result_pool = postRequest('http://140.113.8.134/Quiz/QuestionPool/ViewPoolDraft', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})   
        else
          result_pool = postRequest('http://140.113.8.134/Quiz/QuestionPool/ViewPool', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})           
        end  
        result_ops = postRequest('http://140.113.8.134/Quiz/QuestionPool/ListOption', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})        
        unless result_ops['DataCollection'].blank?  
          options=result_ops['DataCollection'].map{|o|{                
            option_id: o['OptionId'],
            content: o['Content']               
          }}
        end
        key=result_pool['DataCollection']['Category'].to_s     
        new_pools[key].push({
          course_id: q['CourseId'],
          pool_id: q['PoolId'],
          question_id: q['QuestionId'],
          score: q['ScorePlus'],            
          category: result_pool['DataCollection']['Category'],       
          subject: result_pool['DataCollection']['Subject'],
          options: options
        })
        pools_score[key]=pools_score[key]+q['ScorePlus']
      end
    end                                                 
    render json: {success: true, pools_score: pools_score, all_pools: new_pools, left_count: session[:total_Amount].to_i-session[:skip_Amount].to_i-session[:get_Amount].to_i}  
  end  
  
  private
    def set_quiz
      @quiz_id = params[:quiz_id]
    end     
  
end
