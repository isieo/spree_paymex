Rails.application.routes.draw do
  # Add your extension routes here
  namespace :gateway do
    match '/paymex/:gateway_id/:order_id' => 'paymex#show', :as => :paymex
    match '/paymex/request' => 'paymex#request', :as => :paymex_request
    match '/paymex/inquiry' => 'paymex#inquiry', :as => :paymex_inquiry
    match '/paymex/notify' => 'paymex#notify', :as => :paymex_notify
    match '/paymex/void' => 'paymex#void', :as => :paymex_void
  end
end
