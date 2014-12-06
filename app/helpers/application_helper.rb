module ApplicationHelper
  def alert_class_for(flash_type)
    {
      :success => 'alert-success',
      :error => 'alert-danger',
      :alert => 'alert-warning',
      :notice => 'alert-info'
    }[flash_type.to_sym] || flash_type.to_s
  end    
  
  def showBlank(s)
    if s.blank?
      '--'
    else  
      simple_format( s, {}, wrapper_tag: "span")
    end
  end
  
  def toFrontEndTimeFormat(t)
    unless t.blank?
      if t =~ /\/Date\((\d+)\)\//
        Time.at($1.to_i/1000.0).strftime('%Y/%m/%d %H:%M')
      end
    end  
  end
end
