require 'fast_spec_helper'

require 'services/video_tag_title_fetcher'
require 'wrappers/video_info_wrapper'

describe VideoTagTitleFetcher do

  context "with video title comming from attribute (but origin nil)" do
    subject { described_class.new(title: 'Video Title', title_origin: 'attribute') }

    its(:title) { should eq 'Video Title' }
    its(:origin) { should eq 'attribute' }
  end

  context "with video title comming from attribute (but origin nil)" do
    subject { described_class.new(title: 'Video Title', title_origin: nil) }

    its(:title) { should eq 'Video Title' }
    its(:origin) { should eq 'attribute' }
  end

  context "with video title comming from source (DEPRECATED)" do
    subject { described_class.new(title: 'Video Title', title_origin: 'source') }

    its(:title) { should be_nil }
    its(:origin) { should be_nil }
  end

  context "with video title not present and known sources" do
    subject { described_class.new(title: nil, title_origin: nil, sources_id: 'source_id', sources_origin: 'hosting_service') }

    before { VideoInfoWrapper.should_receive(:new).with(video_id: 'source_id', provider: 'hosting_service') { stub(title: 'Title', provider: 'hosting_service') } }

    its(:title) { should eq 'Title' }
    its(:origin) { should eq 'hosting_service' }
  end

  context "with video title present and known sources" do
    subject { described_class.new(title: 'Title', title_origin: 'hosting_service', sources_id: 'source_id', sources_origin: 'hosting_service') }

    before { VideoInfoWrapper.should_not_receive(:new) }

    its(:title) { should eq 'Title' }
    its(:origin) { should eq 'hosting_service' }
  end

  context "with video title (but no origin) and known sources" do
    subject { described_class.new(title: 'Title', title_origin: nil, sources_id: 'source_id', sources_origin: 'hosting_service') }

    its(:title) { should eq 'Title' }
    its(:origin) { should eq 'attribute' }
  end

  context "with no title and video sources without title" do
    subject { described_class.new(title: nil, title_origin: nil, sources_id: 'source_id', sources_origin: 'hosting_service') }

    before { VideoInfoWrapper.should_receive(:new).with(video_id: 'source_id', provider: 'hosting_service') { stub(title: nil, provider: 'hosting_service') } }

    its(:origin) { should eq 'hosting_service' }
    its(:title) { should be_nil }
  end

  context "with no title (but title origin) and known sources" do
    subject { described_class.new(title: nil, title_origin: 'hosting_service', sources_id: 'source_id', sources_origin: 'hosting_service') }

    its(:origin) { should eq 'hosting_service' }
    its(:title) { should be_nil }
  end

  context "with no title (but title origin) and unknown sources" do
    subject { described_class.new(title: nil, title_origin: nil, sources_id: 'source_id', sources_origin: 'other') }

    its(:origin) { should be_nil }
    its(:title) { should be_nil }
  end
end
