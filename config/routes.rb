Rails.application.routes.draw do


  get  'main/index'
  get  'main/courseSearch'
  
  get  'courses/info'
  get  'courses_tea/info'  

  
#Created by ADO, Forum
  resources :courses do
	get "forum/index"
	get "forum/new"
  end
  
  
  get  'users/courses'
  get  'users/listCourses'
  get  'users/logOut'
  post 'users/signIn'
  
  get  'quiz/index'
  get  'quiz/show' 
  get  'quiz/take'     
  get  'quiz/listQuestions'
  post 'quiz/submitAnswers'  
     
  get  'quiz_tea/index'
  get  'quiz_tea/new' 
  get  'quiz_tea/edit'
  get  'quiz_tea/show'
  get  'quiz_tea/publish'     
  get  'quiz_tea/rank'
  get  'quiz_tea/getAnswerAndScore'   
  get  'quiz_tea/submitScore'
  get  'quiz_tea/listQuestions'
  get  'quiz_tea/deleteQuestion'
  get  'quiz_tea/deleteDraft'
  get  'quiz_tea/deleteQuiz'
  post 'quiz_tea/updateBasic'
  post 'quiz_tea/updatePool'
   
  root 'main#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
