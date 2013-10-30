require 'fast_spec_helper'

require 'autoembed_file'

describe AutoEmbedFile do
  let(:video_source) { double('VideoSource1',
    url: "http://media.sublimevideo.net/360p.mp4",
    quality: 'base'
  ) }
  let(:video_source_hd) { double('VideoSource1',
    url: "http://media.sublimevideo.net/720p.mp4",
    quality: 'hd'
  ) }
  let(:video_tag) { double('VideoTag',
    site_token: 'site_token',
    title: 'My Video',
    poster_url: '//poster_url.com',
    settings: { "player_kit" => 1, "sharing_buttons"=> "twitter facebook" },
    options: { },
    sources: [video_source, video_source_hd],
    player_stage: 'beta'
  ) }

  describe "autoembed html file" do
    let(:autoembed_file) { AutoEmbedFile.new(video_tag) }
    let(:body) { autoembed_file.read }

    it { expect(autoembed_file).to be_kind_of Tempfile }

    it "includes title tag" do
      expect(body).to include '<title>My Video</title>'
    end

    it "includes loader with good token" do
      expect(body).to include 'src="//cdn.sublimevideo.net/js/site_token-beta.js"'
    end

    it "includes poster attribute" do
      expect(body).to include 'poster="//poster_url.com"'
    end

    it "includes data-settings attribute" do
      expect(body).to include 'data-player-kit="1" data-sharing-buttons="twitter facebook"'
    end

    it "includes source tags" do
      expect(body).to include '<source src="http://media.sublimevideo.net/360p.mp4" />'
      expect(body).to include '<source src="http://media.sublimevideo.net/720p.mp4" data-quality="hd" />'
    end

    context "with no sources" do
      before { video_tag.stub(:sources) { [] } }

      it "doesn't includes source tags" do
        expect(body).not_to include 'source'
      end
    end

    context "with Google Analytics account" do
      before { video_tag.stub(:options) { { 'ga_account' => 'UA-12345-6' } } }

      it "includes google analytics script tag" do
        expect(body).to include "_gaq.push(['_setAccount', 'UA-12345-6']);"
      end
    end
  end
end
