class MainController < ApplicationController
  def index
  end
  
  def courseSearch
    unless params[:term].blank?
      
      
      @result =RestClient.post 'http://140.113.8.134/E35/Search/Index', QueryString: params[:term]    
      @result = @result.force_encoding('utf-8').encode
      @result=JSON.parse(@result)  
      
      
    end
  end
end
