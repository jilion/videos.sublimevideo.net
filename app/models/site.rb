require 'sublime_video_private_api'

class Site
  include SublimeVideoPrivateApi::Model
  uses_private_api :my
  collection_path '/private_api/sites'

  def self.tokens(params = {})
    result = get_raw(:tokens, params)
    result[:parsed_data][:data]
  end
end
