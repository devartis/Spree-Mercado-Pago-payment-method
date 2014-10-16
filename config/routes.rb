# -*- encoding : utf-8 -*-
Spree::Core::Engine.routes.draw do

  namespace :api, :defaults => {:format => 'json'} do
    resources :orders do
      member do
        post 'mercado_pago/payment', to: 'mercado_pago#payment', as: :mercado_pago_payment_api
      end
    end
    resources :payments do
      collection do
        post 'mercado_pago/notification', to: 'mercado_pago#notification', as: :mercado_pago_notification
        get 'mercado_pago/notification', to: 'mercado_pago#notification', as: :mercado_pago_notification_get
      end
    end

  end

end
