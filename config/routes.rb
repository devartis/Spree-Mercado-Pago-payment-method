# -*- encoding : utf-8 -*-
Spree::Core::Engine.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do
    resources :orders do
      member do
        post 'mercado_pago/payment', to: 'mercado_pago#payment', as: :mercado_pago_payment_api
      end
    end
    #HACK. Needed to be able to use the authorize method from spree
    resources :orders do
      resource :installment_plans, only: [] do
        member do
          get 'mercado_pago', to: 'mercado_pago_custom#installment_plans'
        end
      end
    end
    resources :payments do
      collection do
        post 'mercado_pago/notification', to: 'mercado_pago#notification', as: :mercado_pago_notification
        get 'mercado_pago/notification', to: 'mercado_pago#notification', as: :mercado_pago_notification_get
      end
    end

    # URGENT: This is breaking avalancha login!
    resources :users, only: [] do
     get 'mercado_pago/cards', to: 'mercado_pago_custom#cards', as: :mercado_pago_cards
    end

  end

end
