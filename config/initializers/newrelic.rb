if Rails.env.in?(%w[production staging])
  require 'newrelic_rpm'
end
