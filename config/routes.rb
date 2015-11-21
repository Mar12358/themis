Rails.application.routes.draw do
  devise_for :users

  post 'ona/issued_class' => 'ona#issued_class'

  namespace :admin do
    get '/' => 'welcome#index', as: :index
    get 'teacher_cash_incomes' => 'welcome#teacher_cash_incomes'
    get 'teacher_courses' => 'welcome#teacher_courses'
    get 'horarios_wp' => 'welcome#horarios_wp'
    get 'balance' => 'welcome#balance'
    get 'missing_payments' => 'welcome#missing_payments'

    resources :ona_submissions, only: :index do
      member do
        post :reprocess
        post :dismiss
        post :yank
        post :pull_from_ona
        get :ona_edit
      end
    end

    resources :users, only: [:index, :show, :update]
    resources :courses, only: [:index]
    resources :students, only: [:index, :show, :edit, :update, :new, :create] do
      collection do
        get :stats
        get :stats_details
        get :missing_payment
      end
    end

    resources :teachers, only: [:index, :show] do
      member do
        get :owed_cash
        post :transfer_cash_income_money

        get :due_course_salary
        post :pay_pending_classes
      end
    end

    resources :course_logs, only: :show do
      resources :student_course_logs, only: [:create, :edit, :update, :destroy]

      get :autocomplete_student, :on => :collection
    end
  end

  namespace :teacher do
    get '/' => 'welcome#index', as: :index
    get '/how_to' => 'welcome#how_to', as: :how_to

    get '/owed_cash' => 'welcome#owed_cash', as: :owed_cash

    resources :course_logs, only: :show

    resources :ona_submissions, only: :index

    resources :students, only: [:index, :show]

  end

  namespace :place do
    get '/' => 'welcome#index', as: :index

    resources :ona_submissions, only: :index
  end

  namespace :room do
    get '/' => 'attendance#choose_course'
    post '/open/:date/:course_id' => 'attendance#open', as: :open
    get '/course_log/:id/teachers' => 'attendance#choose_teachers', as: :choose_teachers
    post '/course_log/:id/teachers' => 'attendance#choose_teachers_post'

    get '/course_log/:id/students' => 'attendance#students', as: :students
  end

  root 'welcome#index'

  post 'ona' => 'ona#json_post'
  # post 'ona/teach' => 'ona#teach'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"

  mount Listings::Engine => "/listings"

  get 'forbidden' => 'welcome#forbidden'
end
