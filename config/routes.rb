Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  post 'gateway/paymex/proxy' => 'paymex#proxy', :as => :paymex_proxy
  match 'gateway/paymex/response'  => 'paymex#response_handler', :as => :paymex_response, :via=>[:post,:get]
  match 'gateway/paymex/inquiry'  => 'spree/paymex#inquiry_handler', :as => :paymex_inquiry, :via=>[:post,:get]
  match 'gateway/paymex/notify'  => 'spree/paymex#notify_handler', :as => :paymex_notify, :via=>[:post,:get]
  match 'gateway/paymex/void'  => 'spree/paymex#void_handler', :as => :paymex_void, :via=>[:post,:get]

end
