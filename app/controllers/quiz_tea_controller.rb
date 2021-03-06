class QuizTeaController < ApplicationController  
  before_action :set_course, only: [:index, :new, :edit, :updateBasic, :publish, :show, :deleteDraft, :deleteQuiz, :rank, :submitScore ]
  before_action :set_quiz, only: [:edit, :updateBasic, :publish, :show, :deleteDraft, :deleteQuiz, :rank, :submitScore ]      

  def index         
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListDraft', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })   
    @draft=result['DataCollection']
  
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuiz', {CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })        
    @quiz=result['DataCollection']
    unless @quiz.blank?
      @quiz.each do |q|  
        r=postRequest('http://140.113.8.134/Quiz/QuizV2/StatisticExaminee', { QuizId: q['QuizId'], UserId: currentUser.id, IP: request.remote_ip})                
        q.store('AbsenteeCount', r['DataCollection']['AbsenteeCount'] )
        q.store('RequisiteDoneCount', r['DataCollection']['RequisiteDoneCount'] )        
        #q['DataCollection'][]
      end
    end        
  end

  def show
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ViewQuiz', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip })    
    unless result['DataCollection'].blank?
      @quiz=result['DataCollection']
   
      statistic=postRequest('http://140.113.8.134/Quiz/QuizV2/StatisticExaminee', { QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip})                 
      unless statistic['DataCollection'].blank?
        requisiteDoneList=statistic['DataCollection']['RequisiteDoneList']  
      end
      requisiteDoneList.each do |r|
        z=postRequest('http://140.113.8.134/Quiz/QuizV2/ListSheets', { StudentId: r, QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip})                         
      end
  
      @sheet_lists =Array.new 
      sheets=postRequest('http://140.113.8.134/Quiz/QuizV2/ListSheets', { QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip})                             
      (sheets['DataCollection'] || []).each do |s|
        (s['ExtraData'] || []).each do |e|
          unless e['EndDate'].blank?
            @sheet_lists <<
            {
                QuizId: @quiz_id,
                CourseId: @course_id,
                SubmitId: e['SubmitId'],
                AccountId: e['AccountId'],
                EndDate: e['EndDate'],
                MatchRate: e['MatchRate']
            }   
            break 
          end  
        end       
      end
    
=begin            
      requisiteDoneList.each do |r|
        z=postRequest('http://140.113.8.134/Quiz/QuizV2/ListSheets', { StudentId: r, QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip})                 
        #logger.info z['DataCollection'] 
        #logger.info z['DataCollection'][0]
        z['DataCollection'][0]['ExtraData'].each do |e|
          logger.info e['MatchRate']
          g=postRequest('http://140.113.8.134/Quiz/QuizV2/GetSheetContents', { SubmitId: e['SubmitId'], UserId: currentUser.id, IP: request.remote_ip})                 
          
          material =Array.new 
          g['DataCollection'].each do |gg|
            logger.info gg['PoolId']
            logger.info gg['MatchRate']
            logger.info '--------------'
            gg['Answer'].split("|").each do |an|
              #logger.info 991
              #logger.info an
            end
            material <<
            {
              SubmitId: e['SubmitId'],
              PoolId: gg['PoolId'],
              Score: 66
            }                      
          end  
          ss = postRequestWithNestedJson('http://140.113.8.134/Quiz/QuizV2/ScoreSheet', {Material: material, CourseId: @course_id, QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip }.to_json, {:content_type => :json, :accept => :json}) 
        end     
      end    
      tt=postRequest('http://140.113.8.134/Quiz/QuizV2/Transcript', { QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip})                 
=end


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
    # validate begin
    validations_result=validations([{type: 'presence', title: '測驗名稱', data: params[:Caption]},
                                    {type: 'presence', title: '內容說明', data: params[:Content]},
                                    {type: 'presence', title: '開始時間', data: params[:BeginDate]},
                                    {type: 'presence', title: '最後入場時間', data: params[:EndDate]},
                                    {type: 'latter_than', title: { first: '開始時間', second: '最後入場時間' }, data: { first: params[:BeginDate], second: params[:EndDate] }},
                                    {type: 'presence', title: '測驗時間', data: params[:TimeLimit]},                                    
                                    ])
    checkValidations(validations: validations_result ) 
    # validate end         
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/ListQuestion', {QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip})         
    unless result['DataCollection'].blank?
      result['DataCollection'].each do |q|  
        postRequest('http://140.113.8.134/Quiz/QuestionPool/CreatePool', { PoolId: q['PoolId'], UserId: currentUser.id, IP: request.remote_ip})              
      end
    end       
    result_quiz = postRequest('http://140.113.8.134/Quiz/QuizV2/CreateQuiz', {QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip })   
    render json: {success: true, message: '成功發佈' }                
  end
  
  def rank
    @submit_id = params[:submit_id]
  end
  
  def submitScore
    material =Array.new 
    material <<
    {
      SubmitId: params[:SubmitId],
      PoolId: params[:PoolId],
      Score: params[:Score]
    }                       
    postRequestWithNestedJson('http://140.113.8.134/Quiz/QuizV2/ScoreSheet', {Material: material, CourseId: @course_id, QuizId: @quiz_id, UserId: currentUser.id, IP: request.remote_ip }.to_json, {:content_type => :json, :accept => :json}) 
    render json: {success: true, message: '成功更改分數' }                
  end
  
  def updateBasic      
    result = postRequest('http://140.113.8.134/Quiz/QuizV2/UpdateDraft', {Caption: params[:Caption], Content: params[:Content], BeginDate: params[:BeginDate], EndDate: params[:EndDate], TimeLimit: params[:TimeLimit],
                                                                          QuizType: params[:QuizType], Invited: params[:Invited], Notify: params[:Notify], IsDisorder: params[:IsDisorder], DisplayType: params[:DisplayType],
                                                                          QuizId: @quiz_id, CourseId: @course_id, UserId: currentUser.id, IP: request.remote_ip})   
    render json: {success: true, message: '成功更新基本設定' }    
  end  
  
  def updatePool
    if params[:PoolId].blank?
      result_pool = postRequest('http://140.113.8.134/Quiz/QuestionPool/CreatePoolDraft', {CourseId: params[:CourseId], UserId: currentUser.id, IP: request.remote_ip})         
      pool_id=result_pool['DataCollection']['PoolId']
      result_question= postRequest('http://140.113.8.134/Quiz/QuizV2/CreateQuestion', {PoolId: pool_id, QuizId: params[:QuizId], UserId: currentUser.id, IP: request.remote_ip})        
      question_id=result_question['DataCollection']['QuestionId']
    else
      pool_id=params[:PoolId]
      question_id=params[:QuestionId]
    end  
    postRequest('http://140.113.8.134/Quiz/QuizV2/SetQuestionScore', {ScorePlus: params[:Score], QuestionId: question_id, CourseId: params[:CourseId], QuizId: params[:QuizId], UserId: currentUser.id, IP: request.remote_ip})        
    # update pool
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
            content: o['Content'],
            isAnswer: o['IsAnswer'],               
          }}
        else
          options=[]  
        end
        key=result_pool['DataCollection']['Category'].to_s     
        new_pools[key].push({
          course_id: q['CourseId'],
          pool_id: q['PoolId'],
          question_id: q['QuestionId'],
          score: q['ScorePlus'],            
          category: result_pool['DataCollection']['Category'],       
          subject: result_pool['DataCollection']['Subject'],
          comment: result_pool['DataCollection']['Comment'],
          options: options
        })
        pools_score[key]=pools_score[key]+q['ScorePlus']
      end
    end
    render json: {success: true, pools_score: pools_score, all_pools: new_pools}                                                   
  end
  
  def getAnswerAndScore
    g=postRequest('http://140.113.8.134/Quiz/QuizV2/GetSheetContents', { SubmitId: params['SubmitId'], UserId: currentUser.id, IP: request.remote_ip})                 
    sheet_contents=Array.new          
    g['DataCollection'].each do |gg|
      logger.info gg['SubmitId']
      sheet_contents<<
      {
        PoolId: gg['PoolId'],
        MatchRate: gg['MatchRate'],
        Answer: gg['Answer'].split("|")
      }                   
    end
    render json: {success: true, sheet_contents: sheet_contents }            
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
