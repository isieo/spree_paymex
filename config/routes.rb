Rails.application.routes.draw do
  # Add your extension routes here
  
  match '/gateway/paymex/request'  => 'spree/paymex#response', :as => :paymex_response, :via=>[:post,:get]

end
