VideosSublimeVideo::Application.routes.draw do
  root to: redirect('http://sublimevideo.net')

  namespace :private_api do
    scope "/sites/:site_token" do
      resources :video_tags, only: [:index, :show] do
        get 'count', on: :collection
      end
    end
  end
end
