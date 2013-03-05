require 'fast_spec_helper'

require 'autoembed_file'

describe AutoEmbedFile do
  let(:video_source) { mock('VideoSource1',
    url: "http://media.sublimevideo.net/360p.mp4",
    quality: 'base'
  ) }
  let(:video_source_hd) { mock('VideoSource1',
    url: "http://media.sublimevideo.net/720p.mp4",
    quality: 'hd'
  ) }
  let(:video_tag) { mock('VideoTag',
    site_token: 'site_token',
    title: 'My Video',
    poster_url: '//poster_url.com',
    settings: { "player_kit" => 1, "sharing_buttons"=> "twitter facebook" },
    sources: [video_source, video_source_hd]
  ) }

  describe "autoembed html file" do
    subject { AutoEmbedFile.new(video_tag) }

    it { should be_kind_of Tempfile }

    it "includes title tag" do
      subject.read.should include '<title>My Video</title>'
    end

    it "includes loader with good token" do
      subject.read.should include '//cdn.sublimevideo.net/js/site_token.js'
    end

    it "includes poster attribute" do
      subject.read.should include 'poster="//poster_url.com"'
    end

    it "includes data-settings attribute" do
      subject.read.should include 'data-settings="player-kit: 1; sharing-buttons: twitter facebook"'
    end

    it "includes source tags" do
      subject.read.should include '<source src="http://media.sublimevideo.net/360p.mp4" />\n<source src="http://media.sublimevideo.net/720p.mp4" data-quality="hd" />'
    end

    context "with no sources" do
      before {
        video_tag.stub(:sources) { [] }
      }

      it "doesn't includes source tags" do
        subject.read.should_not include 'source'
      end
    end
  end
end
