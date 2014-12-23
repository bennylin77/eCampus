class QuizTeaController < ApplicationController  
  before_action :set_course, only: [:index, :new, :edit, :updateBasic, :publish, :show, :deleteDraft, :deleteQuiz ]
  before_action :set_quiz, only: [:edit, :updateBasic, :publish, :show, :deleteDraft, :deleteQuiz ]      

  def index         
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListDraft', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })   
    @draft=result['DataCollection']
  
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuiz', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })        
    @quiz=result['DataCollection']
    unless @quiz.blank?
      @quiz.each do |q|  
        r=postRequest('http://140.113.8.134/Quiz/QuizV2/StatisticExaminee', { QuizId: q['QuizId'], UserId: currentUser.id, IP: request.remote_ip})              
        logger.info r       
        #q['DataCollection'][]
      end
    end        
  end

  def show
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewQuiz', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip })    
    unless result['DataCollection'].blank?
      @quiz=result['DataCollection']
      @quiz.store("draft", false)        
    else
      result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewDraft', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })    
      @quiz=result['DataCollection'] 
      @quiz.store("draft", true)             
    end      
  end
  
  def new
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/CreateDraft', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })   
    @result=result['DataCollection']
    redirect_to controller: 'quiz_tea', action: 'edit', quiz_id: @result['QuizId'], course_id: @result['CourseId']            
  end
  
  def edit          
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewDraft', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip})   
    @result=result['DataCollection']         
  end  
  
  def publish    
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuestion', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip})         
    unless result['DataCollection'].blank?
      result['DataCollection'].each do |q|  
        postRequest('http://140.113.8.134/Quiz/QuestionPool/CreatePool', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})              
      end
    end       
    result_quiz = postRequest('http://140.113.8.134/Quiz/QuizV2/CreateQuiz', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })   
    redirect_to controller: 'quiz_tea', action: 'index', course_id: @course_id  
  end
  
  def updateBasic       
    # validate begin
    validation_message=validations([{type: 'presence', title: '測驗名稱', data: params[:Caption]},
                                    {type: 'presence', title: '內容說明', data: params[:Content]},
                                    {type: 'presence', title: '開始時間', data: params[:BeginDate]},
                                    {type: 'presence', title: '最後入場時間', data: params[:EndDate]},
                                    {type: 'latter_than', title: { first: '開始時間', second: '最後入場時間' }, data: { first: params[:BeginDate], second: params[:EndDate] }}])
    checkValidations(validation_message: validation_message ) 
    # validate end  
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/UpdateDraft', {Caption: params[:Caption], Content: params[:Content], BeginDate: params[:BeginDate], EndDate: params[:EndDate], QuizType: params[:QuizType],  
                                                                          Invited: params[:Invited], Notify: params[:Notify], IsDisorder: params[:IsDisorder], DisplayType: params[:DisplayType],
                                                                          QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip})   
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
    render json: {success: true, pools: pools }          
  end
  
  def deleteDraft    
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/DeleteDraft', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip})           
    flash[:success]='成功刪除草稿'     
    redirect_to '/quiz_tea/index?course_id='+@course_id 
  end

  def deleteQuiz  
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/UpdateQuiz', {IsDeleted: true, QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip})           
    flash[:success]='成功刪除測驗'     
    redirect_to '/quiz_tea/index?course_id='+@course_id 
  end 
    
  def deleteQuestion    
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/DelQuestion', {QuestionId: params[:QuestionId], CourseId: params[:CourseId], UserId: currentUser.id, IP: request.remote_ip})           
    render json: {success: true, msg: '成功刪除' }    
  end
  
  
  private
    def set_quiz
      @quiz_id = params[:quiz_id]
    end   
            
end
