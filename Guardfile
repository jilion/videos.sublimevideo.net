guard :rspec, bundler: false, all_after_pass: false, all_on_start: false, keep_failed: false do
  watch('app/controllers/application_controller.rb')                         { "spec/controllers" }
  watch('app/templates/autoembed.html.erb') { 'spec/models/autoembed_file_spec.rb' }
  watch(%r{^spec/support/(\w)_helpers\.rb}) { |m| "spec/#{m[1]}" }
  watch(%r{^spec/.+/.+_spec\.rb})

  watch(%r{^app/controllers/(.+)_(controller)\.rb})                          { |m| ["spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/requests/#{m[1]}_spec.rb"] }

  watch(%r{^app/(.+)\.rb})                                                   { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/(.+)\.rb})                                                   { |m| "spec/lib/#{m[1]}_spec.rb" }
end

guard :pow do
  watch('.powrc')
  watch('.powenv')
  watch('.rvmrc')
  watch('Gemfile')
  watch('Gemfile.lock')
  watch('config/application.rb')
  watch('config/environment.rb')
  watch(%r{^config/environments/.*\.rb$})
  watch(%r{^config/initializers/.*\.rb$})
end
