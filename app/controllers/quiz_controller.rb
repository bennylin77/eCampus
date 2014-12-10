class QuizController < ApplicationController
    
  before_action :set_course, only: [:index]
  before_action :set_quiz, only: [:show, :take, :submitAnswers]    
  
# quiz for stu
  def index
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuiz', {CourseId: @course_id, UserId: session[:user], IP: request.remote_ip })    
    if result['Success']
      @quiz=result['DataCollection']
    else
      flash[:error]=result['ErrorMessage']   
      redirect_to controller: 'users', action: 'courses'
    end      
      
  end

  def show
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewQuiz', {QuizId: @quiz_id, UserId: session[:user], IP: request.remote_ip })    
    if result['Success']
      @quiz=result['DataCollection']
    else
      flash[:error]=result['ErrorMessage']   
      redirect_to controller: 'users', action: 'courses'
    end      
  end

  def take 
  end  
  
  def submitAnswers
    #params[:Answers].each_with_index do |value, index|  
      #logger.info params[:PoolIds][index]
      #logger.info value
      #logger.info value.second       
    #end    
=begin    
    material =Array.new  
    params[:Answers].each_with_index do |value, index|        
      material <<
      {
        SubmitId: "",
        PoolId: params[:PoolIds][index],
        Answer: value.second.join("|"),
        Serial: "" 
      }     
    end 
=end          

    material = Hash.new()
    params[:Answers].each_with_index do |value, index|        
      material[index] =
      {
        SubmitId: "",
        PoolId: params[:PoolIds][index],
        Answer: value.second.join("|"),
        Serial: "" 
      }     
    end 
 
    #logger.info material  
    #result = postRequest('http://140.113.8.134/Quiz/QuizV2/SubmitSheet', {Material: material, QuizId: @quiz_id, UserId: session[:user], IP: request.remote_ip })    
    #aa={'0' => {SubmitId: nil, PoolId:"a5b62fc4-bb39-4c02-936d-8d11fbc2502f", Answer:"7654321", Serial:4}, '1'=> {SubmitId: nil, PoolId:"9bad40ef-a979-4047-aec0-b795e6300504", Answer:"bbbbb", Serial:5}}
    #logger.info aa
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/SubmitSheet', {UserId: "e308c735-4108-4121-8077-c9735009b076", IP:"0.0.0.0", QuizId: "35cfab66-a70f-4b99-bca0-191dd12d9f28", Material: material})    
    #result = postRequest('http://140.113.159.109:3000/test/index', UserId: "e308c735-4108-4121-8077-c9735009b076", IP:"0.0.0.0", QuizId: "35cfab66-a70f-4b99-bca0-191dd12d9f28", 'Material[]'=> material)    
    #result = postRequest('http://140.113.8.134/Quiz/QuizV2/testEEE',  {info: {UserId: "e308c735-4108-4121-8077-c9735009b076", IP:"0.0.0.0", QuizId: "35cfab66-a70f-4b99-bca0-191dd12d9f28", 'Material[]'=> material}})    
    #result = postRequest('http://140.113.159.109:3000/test/index',  UserId: "e308c735-4108-4121-8077-c9735009b076", IP:"0.0.0.0", QuizId: "35cfab66-a70f-4b99-bca0-191dd12d9f28", 'Material[]'=> material)    
    
      
    logger.info result
    if result['Success']
      render json: {success: true, msg: '成功更新基本設定' }  
    else
      render json: {success: false, msg: result['ErrorMessage'] }     
    end      
  end
  
  def listQuestions
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuestion', {QuizId: params[:QuizId], UserId: session[:user], IP: request.remote_ip})       
    if result['Success']     
      pools=Array.new  
      unless result['DataCollection'].blank?
        result['DataCollection'].each do |q|  
          result_pool = postRequest('http://140.113.8.134/Quiz/QuestionPool/ViewPoolDraft', { PoolId: q['PoolId'], UserId: session[:user], IP: request.remote_ip})   
          result_ops = postRequest('http://140.113.8.134/Quiz/QuestionPool/ListOption', { PoolId: q['PoolId'], UserId: session[:user], IP: request.remote_ip})   
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
      render json: {success: true, msg: '成功更新基本設定', pools: pools }  
    else
      render json: {success: false, msg: result['ErrorMessage'] }     
    end          
  end
  
  
  private
    def set_course
      @course_id = params[:course_id]
    end 
    def set_quiz
      @quiz_id = params[:quiz_id]
    end     
  
end
