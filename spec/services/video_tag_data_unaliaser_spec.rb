require 'fast_spec_helper'

require 'video_tag_data_unaliaser'

describe VideoTagDataUnaliaser do

  describe ".unalias" do
    context "with standard video data" do
      let(:data) { {
        't' => 'My Video',
        'i' => nil,
        'io' => nil,
        'p' => 'http://posters.sublimevideo.net/video123.png',
        'z' => '640x360',
        'd' => '10000',
        's' => [
          { 'u' => 'http://videos.sublimevideo.net/source11.mp4', 'q' => 'base', 'f' => 'mp4', 'r' => '460x340' }
        ]
      } }

      it "unaliases data" do
        VideoTagDataUnaliaser.unalias(data).should eq({
          title: 'My Video',
          sources_id: nil,
          sources_origin: nil,
          poster_url: 'http://posters.sublimevideo.net/video123.png',
          size:      '640x360',
          duration:   '10000',
          sources: [{
            url: 'http://videos.sublimevideo.net/source11.mp4',
            quality: 'base',
            family: 'mp4',
            resolution: '460x340'
          }]
        })
      end
    end

    context "with youtube video data" do
      let(:data) { {
        't' => 'My Video',
        'i' => 'youtube_id',
        'io' => 'y',
        'p' => 'http://posters.sublimevideo.net/video123.png',
        'z' => '640x360',
        'd' => '10000'
      } }

      it "unaliases data" do
        VideoTagDataUnaliaser.unalias(data).should eq({
          title: 'My Video',
          sources_id: 'youtube_id',
          sources_origin: 'youtube',
          poster_url: 'http://posters.sublimevideo.net/video123.png',
          size:      '640x360',
          duration:   '10000'
        })
      end
    end

    context "with minimal video data" do
      let(:data) { {
        't' => 'My Video',
        'p' => 'http://posters.sublimevideo.net/video123.png',
        'z' => '640x360',
        'd' => '10000'
      } }

      it "unaliases data" do
        VideoTagDataUnaliaser.unalias(data).should eq({
          title: 'My Video',
          poster_url: 'http://posters.sublimevideo.net/video123.png',
          size:      '640x360',
          duration:   '10000'
        })
      end
    end
  end
end
