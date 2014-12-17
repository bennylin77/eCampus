class QuizTeaController < ApplicationController  
  before_action :set_course, only: [:index, :new, :edit, :updateBasic, :publish, :show, :deleteDraft ]
  before_action :set_quiz, only: [:edit, :updateBasic, :publish, :show, :deleteDraft ]      

  def index
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListDraft', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })   
    if result['Success']
      @draft=result['DataCollection']
    else
      flash[:error]=result['ErrorMessage']   
      redirect_to controller: 'users', action: 'courses'
    end    
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuiz', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })    
    if result['Success']
      @quiz=result['DataCollection']
      @quiz.each do |q|  
        logger.info q['QuizId']
        r=postRequest('http://140.113.8.134/Quiz/QuizV2/StatisticExaminee', { QuizId: q['QuizId'], UserId: currentUser.id, IP: request.remote_ip})              
        logger.info r
      end 
    else
      flash[:error]=result['ErrorMessage']   
      redirect_to controller: 'users', action: 'courses'
    end        
  end

  def show
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewQuiz', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip })    
    successHandler(success: result['Success'], error_message: result['ErrorMessage'], redirect_to: '/quiz_tea/index?course_id='+@course_id)    
    unless result['DataCollection'].blank?
      @quiz=result['DataCollection']
      @quiz.store("draft", false)        
    else
      result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewDraft', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })    
      successHandler(success: result['Success'], error_message: result['ErrorMessage'], redirect_to: '/quiz_tea/index?course_id='+@course_id)    
      @quiz=result['DataCollection'] 
      @quiz.store("draft", true)             
    end      
  end
  
  def new
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/CreateDraft', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })   
    if result['Success']
      @result=result['DataCollection']
      redirect_to controller: 'quiz_tea', action: 'edit', quiz_id: @result['QuizId'], course_id: @result['CourseId']          
    else
      flash[:error]=result['ErrorMessage']   
      redirect_to controller: 'quiz_tea', action: 'index', course_id: @course_id
    end    
  end
  
  def edit           
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewDraft', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip})   
    if result['Success']
      @result=result['DataCollection']       
    else
      flash[:error]=result['ErrorMessage']   
    end     
  end  
  
  def publish    
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuestion', {QuizId: params[:QuizId], UserId: currentUser.id, IP: request.remote_ip})       
    unless result['DataCollection'].blank?
      result['DataCollection'].each do |q|  
        r=postRequest('http://140.113.8.134/Quiz/QuestionPool/CreatePool', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})              
      end
    end       
    result_quiz = postRequest('http://140.113.8.134/Quiz/QuizV2/CreateQuiz', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })   
    logger.info result_quiz
    if result_quiz['Success']          
    else
      flash[:error]=result_quiz['ErrorMessage']   
    end  
    redirect_to controller: 'quiz_tea', action: 'index', course_id: @course_id  
  end
  
  def updateBasic 
    # validate begin
    validation_message=''
    validation_message=validation_message+validations(type: 'presence', title: '測驗名稱', data: params[:Caption])
    validation_message=validation_message+validations(type: 'presence', title: '內容說明', data: params[:Content])
    validation_message=validation_message+validations(type: 'presence', title: '開始時間', data: params[:BeginDate])
    validation_message=validation_message+validations(type: 'presence', title: '最後入場時間', data: params[:EndDate])  
    unless validation_message.blank?
      render( json: {success: false, message: validation_message }) and return         
    end 
    # validate end  
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/UpdateDraft', {Caption: params[:Caption], Content: params[:Content], BeginDate: params[:BeginDate], EndDate: params[:EndDate], QuizType: params[:QuizType],  
                                                                          Invited: params[:Invited], Notify: params[:Notify], IsDisorder: params[:IsDisorder], DisplayType: params[:DisplayType],
                                                                          QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip})   
    successHandler(success: result['Success'], error_message: result['ErrorMessage'], redirect_to: '/quiz_tea/index?course_id='+@course_id)    
    render json: {success: true, message: '成功更新基本設定' }    
  end  
  
  def updatePool
    if params[:PoolId].blank?
      result_pool = postRequest('http://140.113.8.134/Quiz/QuestionPool/CreatePoolDraft', {CourseId: params[:CourseId], UserId: currentUser.id, IP: request.remote_ip})         
      pool_id=result_pool['DataCollection']['PoolId']
      postRequest('http://140.113.8.134/Quiz/QuizV2/CreateQuestion', {PoolId: pool_id, QuizId: params[:QuizId], UserId: currentUser.id, IP: request.remote_ip})        
    else
      pool_id=params[:PoolId]
    end  
    # del update pool
    result_pool = postRequest('http://140.113.8.134/Quiz/QuestionPool/UpdateDelPoolDraft', {Subject: params[:Subject], Comment: params[:Comment], Category: params[:Category], isDelete: false, PoolId: pool_id, CourseId: params[:CourseId], UserId: currentUser.id, IP: request.remote_ip})         
    # del options first
    result_ops = postRequest('http://140.113.8.134/Quiz/QuestionPool/ListOption', { PoolId: pool_id, UserId: currentUser.id, IP: request.remote_ip})   
    unless result_ops['DataCollection'].blank?          
      result_ops['DataCollection'].each do |o|
        postRequest('http://140.113.8.134/Quiz/QuestionPool/UpdateDelOption', {isDelete: true, PoolId: pool_id, OptionId: o['OptionId'], UserId: currentUser.id, IP: request.remote_ip})                              
      end
    end     
    # create options   
    params[:Options].each_with_index do |value, index|   
      result_op = postRequest('http://140.113.8.134/Quiz/QuestionPool/CreateOption', {PoolId: result_pool['DataCollection']['PoolId'], UserId: currentUser.id, IP: request.remote_ip})         
      result_op = postRequest('http://140.113.8.134/Quiz/QuestionPool/UpdateDelOption', {Content: value, isAnswer: params[:Answers][index], isDelete: false, PoolId: result_pool['DataCollection']['PoolId'], OptionId: result_op['DataCollection']['OptionId'], UserId: currentUser.id, IP: request.remote_ip})                     
    end        
    render json: {success: true}   
  end
  
  def listQuestions
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuestion', {QuizId: params[:QuizId], UserId: currentUser.id, IP: request.remote_ip})       
    if result['Success']     
      pools=Array.new  
      unless result['DataCollection'].blank?
        result['DataCollection'].each do |q|  
          result_pool = postRequest('http://140.113.8.134/Quiz/QuestionPool/ViewPoolDraft', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})   
          result_ops = postRequest('http://140.113.8.134/Quiz/QuestionPool/ListOption', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})   
          options=Array.new      
          unless result_ops['DataCollection'].blank?          
            result_ops['DataCollection'].each do |o|
              options <<
              {                
                option_id: o['OptionId'],
                content: o['Content'],
                isAnswer: o['IsAnswer'],               
              }  
            end
          end  
          logger.info options
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
  
  def deleteDraft    
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/DeleteDraft', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip})           
    successHandler(success: result['Success'], error_message: result['ErrorMessage'], redirect_to: '/quiz_tea/index?course_id='+@course_id)    
    flash[:success]='成功刪除草稿'     
    redirect_to '/quiz_tea/index?course_id='+@course_id
     
  end
    
  def deleteQuestion    
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/DelQuestion', {QuestionId: params[:QuestionId], CourseId: params[:CourseId], UserId: currentUser.id, IP: request.remote_ip})           
    if result['Success']
      render json: {success: true, msg: '成功刪除' }  
    else
      render json: {success: false, msg: result['ErrorMessage'] }     
    end      
  end
  
  
  private
    def set_quiz
      @quiz_id = params[:quiz_id]
    end   
            
end
