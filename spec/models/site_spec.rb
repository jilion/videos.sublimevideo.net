require 'fast_spec_helper'
require 'support/private_api_helpers'

require 'site'

describe Site do
  describe ".tokens" do
    let(:tokens) { %w[token1 token2] }
    before {
      stub_api_for(Site) do |stub|
        stub.get('/private_api/sites/tokens?with_addon_plan=stats-realtime') { |env| [200, {}, tokens.to_json] }
      end
    }

    it "returns tokens array" do
      expect(Site.tokens(with_addon_plan: 'stats-realtime')).to eq tokens
    end
  end
end

