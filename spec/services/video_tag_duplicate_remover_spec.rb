require 'fast_spec_helper'

require 'video_tag_duplicate_remover'

VideoTag = Class.new unless defined?(VideoTag)

describe VideoTagDuplicateRemover do
  let(:remover) { VideoTagDuplicateRemover.new(video_tag) }
  let(:video_tag) { OpenStruct.new(
    site_token: 'site_token',
    uid: 'uid'
  ) }
  let(:video_tag_duplicate) { OpenStruct.new(uid: 'duplicated_uid') }

  before {
    VideoStatsMergerWorker.stub(:perform_async)
  }

  it "founds duplicates from video_tag with the same sources_id" do
    video_tag.stub(:sources_id?) { true }
    VideoTag.should_receive(:duplicates_sources_id).with(video_tag) { stub(first: video_tag_duplicate) }
    remover.remove_duplicate
  end

  it "founds duplicates from video_tag with the same first source url" do
    video_tag.stub(:first_source) { true }
    VideoTag.should_receive(:duplicates_first_source_url).with(video_tag) { stub(first: video_tag_duplicate) }
    remover.remove_duplicate
  end

  context "with duplicate from first source" do
    before {
      video_tag.stub(:first_source) { true }
      VideoTag.stub(:duplicates_first_source_url) { stub(first: video_tag_duplicate) }
    }

    it "delays Stats update/merge on mysv" do
      VideoStatsMergerWorker.should_receive(:perform_async).with('site_token', 'uid', 'duplicated_uid')
      remover.remove_duplicate
    end

    it "removes duplicate" do
      video_tag_duplicate.should_receive(:destroy)
      remover.remove_duplicate
    end
  end
end
