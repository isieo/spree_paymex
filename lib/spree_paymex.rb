require "spree_paymex/version"

module SpreePaymex
  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.env.production? ? require(c) : load(c)
      end
      PaymentMethod::SpreePaymex.register
      
    end

    config.to_prepare &method(:activate).to_proc
  end
end
