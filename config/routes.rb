Deployed::Engine.routes.draw do
  get 'setup', to: 'setup#new'
  post 'setup', to: 'setup#create'
  get 'config', to: 'config#show'
  get 'git/uncommitted_check', to: 'git#uncommitted_check'
  get 'execute', to: 'run#execute'
  get 'cancel', to: 'run#cancel'
  get 'log_output', to: 'log_output#index'
  root to: 'welcome#index'
end
