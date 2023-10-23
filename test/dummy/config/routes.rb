Rails.application.routes.draw do
  mount Deployed::Engine => "/deployed"
end
