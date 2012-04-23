Rails.application.routes.draw do
  # Add your extension routes here
  
  match '/paymex/response'  => 'spree/paymex#response', :as => :paymex_response, :via=>[:post,:get]
  match '/paymex/inquiry'  => 'spree/paymex#inquiry', :as => :paymex_inquiry, :via=>[:post,:get]
  match '/paymex/notify'  => 'spree/paymex#notify', :as => :paymex_notify, :via=>[:post,:get]
  match '/paymex/void'  => 'spree/paymex#void', :as => :paymex_void, :via=>[:post,:get]

end
