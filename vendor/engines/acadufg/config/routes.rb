Acadufg::Engine.routes.draw do

  constraints(Weby::Subdomain) do

    namespace :admin do

    end

  end

  root :to => 'teachers#index'

end