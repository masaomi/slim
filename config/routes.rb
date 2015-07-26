Rails.application.routes.draw do
  resources :categories

  resources :quants do
    collection do
      post :delete_all
    end
  end

  resources :import_quants, :only => [:index] do
    collection do
      post :import
    end
  end

  resources :compounds do
    collection do
      get :filter
      post :filter
      get :filter_view
      post :save_as_csv
      post :delete_all
      post :search_compounds
    end
  end
  get 'feature/:feature' => 'compounds#feature',  as: :feature , feature: /\d+\.\d+_\d+\.\d+[\w\/%]+/
  resources :import_compounds, :only => [:index] do
    collection do
      post :import
    end
  end

  resources :lipids do
    collection do
      post :delete_all
    end
  end

  resources :import_lipids, :only => [:index] do
    collection do
      post :import
      post :delete_all
    end
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root :to => 'home#index'
  match "clear_sessions" => 'home#clear_sessions', :via => :get
  match "download_slim" => 'home#download_slim', :via => :get

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
