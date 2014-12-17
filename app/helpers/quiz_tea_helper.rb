module QuizTeaHelper
  def quizTypeOptions
    [["隨堂考","1"], 
     ["期中考","2"], 
     ["期末考","3"], 
     ["其它","0"]]
  end  
  def invitedOptions
    [["所有修課生","0"],
     ["指定組別","1"],
     ["分組(一組交一份)","2"]]
  end 
  def isDisorderOptions
    [["依序","0"],["隨機排序","1"]]
  end 
  def displayTypeOptions
    [["全部顯示","0"],["逐題作答","1"]]
  end       
  def displayScoreTypeOptions
    [["公開","0"],["個別","1"]]    
  end
  
end
