# encoding: UTF-8
Gem::Specification.new do |s|
  s.name = 'spree_mercado_pago_payment_method'
  s.version     = '0.1.1'
  s.summary     = 'Spree plugin yo integrate Mercado Pago'
  s.description = 'Integrates Mercado Pago with Spree'
  s.author      = "Manuel Barros Reyes"
  s.files       = `git ls-files -- {app,config,lib,test,spec,features}/*`.split("\n")
  s.homepage    = 'https://github.com/manuca/Spree-Mercado-Pago-payment-method'
  s.email       = 'manuca@gmail.com'

  s.add_dependency 'rails', '~> 4.1.8'

  s.add_dependency 'spree_core', '~> 2.4.0'
  s.add_dependency 'spree_api', '~> 2.4.0'
  s.add_dependency 'rest-client'
  s.add_dependency 'mercadopago-sdk'

  s.test_files = Dir["spec/**/*"]
end
