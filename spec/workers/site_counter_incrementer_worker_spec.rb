require 'fast_spec_helper'
require 'config/sidekiq'

require 'site_counter_incrementer_worker'

describe SiteCounterIncrementerWorker do

  it "performs async job" do
    expect {
      SiteCounterIncrementerWorker.perform_async('site_token', :counter_name)
    }.to change(SiteCounterIncrementerWorker.jobs, :size).by(1)
  end

  it "delays job in default (mysv) queue" do
    expect(SiteCounterIncrementerWorker.sidekiq_options_hash['queue']).to eq 'default'
  end
end
