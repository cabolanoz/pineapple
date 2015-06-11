Rails.application.routes.draw do

  get 'login' => 'session#new'
  post 'login' => 'session#create'
  get 'logout' => 'session#destroy'
  delete 'logout' => 'session#destroy'

  # Custom error pages
  #match "/404" => "errors#error404", via: [ :get, :post, :patch, :delete ]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'welcome#index'

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

  #Traffic routes
  namespace :traffic do
    # Trade Manager Resources
    resources :trademanager, except: :destroy do
      collection do
      end
    end
    # Shipping Manager Resources
    resources :shippingmanager, except: :destroy do
      collection do
        get :get_itinerary_by_id
      end
    end
    # Transfer Manager Resources
    resources :transfermanager, except: :destroy do
        collection do
          get ':id/builddraw', :action => 'builddraw'
          get ':id/allocation', :action => 'allocation'
          get 'get_level_by_equipment_from', as: 'get_level_by_equipment_from'
          get 'get_level_by_equipment_to', as: 'get_level_by_equipment_to'
          get 'get_cargo_by_equipment_from', as: 'get_cargo_by_equipment_from'
          get 'get_cargo_by_equipment_to', as: 'get_cargo_by_equipment_to'
          post :import_tag_from_excel
          post :create_transfer_from_trade_to_storage
          post :edit_transfer_from_trade_to_storage
          post :create_transfer_from_trade_to_vessel
          post :create_transfer_from_storage_to_trade
          post :edit_transfer_from_storage_to_trade
          post :create_transfer_from_storage_to_storage
          post :edit_transfer_from_storage_to_storage
          post :create_transfer_from_storage_to_vessel
          post :create_transfer_from_vessel_to_trade
          post :create_transfer_from_vessel_to_storage
          get :validate_transfer_build_draw_tags
          post :cancel_transfer
          post :put_build_draw_match
          get :validate_transfer_build_draw_match
          post :cancel_build_draw_match
          post :split_build_draw_tag
          post :put_build_draw_tags
        end
    end
    # Storage Inspector Resources
    resources :storageinspector, except: :destroy do
      collection do
        get :get_inventory_by_storage_group_by_commodity
        get :get_draw_by_equipment_and_cargo
        get ':id/adjustment', :action => 'adjustment'
        get 'get_level_by_equipment', as: 'get_level_by_equipment'
        get 'get_empty_cargo_adjustment', as: 'get_empty_cargo_adjustment'
        post :put_cargo_adjustment
        post :cancel_cargo_adjustment
        post :put_gain_loss_bd_tags_for_adj
      end
    end
  end

  # Origin routes
  namespace :origin do
    # Inventory Manager Resources
    resources :inventorymanager, except: :destroy do
      collection do
        get 'get_storage_by_type', as: 'get_storage_by_type'
        get 'get_level_by_equipment', as: 'get_level_by_equipment'
        get 'inventory_dtl', as: 'inventory_dtl'
      end
    end
    # Yields Manager Resources
    resources :yieldsmanager, except: :destroy do
      collection do
        get 'standardyields', as: 'standardyields'
        get 'standarYieldnew', as: 'standarYieldnew'
        get 'purchasingyields', action: 'purchasingyields'
        get 'groups', :action => 'groups'
        get 'groupsnew', :action => 'groupsnew'
        get ':id/editGroup', :action => 'editGroup'
        post 'groupcreate', :action => 'groupcreate'
        get 'elements', :action => 'elements'
        get 'elementsnew', :action => 'elementsnew'
        get 'lineclass', :action => 'lineclass'
        get 'lineclassnew', :action => 'lineclassnew'
        get ':id/editLineClass', :action => 'editLineClass'
        post :elementcreate
        post :edit_group_by_id
        post :cancel_group

        post :new_lineclass
        post :edit_lineclass_by_id
        post :cancel_lineclass

        post :upload_yields
        get :getTrade
        get :get_standard_yields

        post :load_elements
      end
    end
  end

  #IT routes
  namespace :it do
    # User Access Resources
    resources :useraccess, except: :destroy do
      collection do
        get ':username', to: 'useraccess#show'
      end
    end
  end

  #Position routes
  namespace :position, except: :destroy do
    resources :physicalfuturelink, except: :destroy do
      collection do
      end
    end
  end

  #Util routes
  namespace :common do
    resources :util, except: :destoy do
      collection do
        get :get_trade_buy_like_trade
        get :get_trade_sell_like_trade
        get :get_movement_by_itinerary
        get :get_storage_by_id
        get :get_level_by_cargo
        get :get_obligation_detail_by_obligation_and_transfer
        get :get_transaction_log_by_id
        get :get_udf_for_transfer
        get :get_convertion_factor_by_uom
        get :get_transfer_by_id
        get :get_udf_values_by_code
        get :get_tag_by_id
        get :get_transfer_ud
        get :get_obligation_dtl_by_num
        get :get_obligation_hdr_by_num
        get :get_obligation_daily_by_num
        get :get_tags_from_build_draw
      end
    end
  end

end
