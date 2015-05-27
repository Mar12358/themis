Rails.application.routes.draw do
  post 'ona/issued_class' => 'ona#issued_class'

  namespace :admin do
    get '/' => 'welcome#index', as: :index
    get 'lines' => 'welcome#lines', as: :lines

    resources :ona_submissions, only: :index do
      member do
        post :reprocess
        post :dismiss
      end
    end

    resources :teachers, only: [:index, :show] do
      member do
        get :owed_student_payments
        post :transfer_student_payments_money
      end
    end

    resources :course_logs, only: :show
  end

  namespace :teacher do
    get '/' => 'welcome#index', as: :index
    get '/how_to' => 'welcome#how_to', as: :how_to
  end



  get 'courses/index'

  root 'welcome#index'

  post 'ona' => 'ona#json_post'
  # post 'ona/teach' => 'ona#teach'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  resources :courses, only: :index
  mount Listings::Engine => "/listings"


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
