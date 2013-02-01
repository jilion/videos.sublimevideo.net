FactoryGirl.define do
  factory :video_tag do
    sequence(:site_token)  { |n| "siteide#{n}" }
    sequence(:uid)  { |n| "video_uid_#{n}" }
    sequence(:title) { |n| "Video Tag #{n}" }
    title_origin     'attribute'
    poster_url      'http://media.sublimevideo.net/vpa/ms_800.jpg'
    size            '640x360'
    duration        '10000'
    settings { { 'onEnd' => 'nothing' } }

    factory :video_tag_with_sources do
      after(:create) do |video_tag|
        FactoryGirl.create_list(:video_source, 2, video_tag: video_tag)
      end
    end
  end

  factory :video_source do
    video_tag
    url        'http://media.sublimevideo.net/vpa/720p.mp4'
    quality    'hd'
    family     'mp4'
    resolution '1280x720'
  end
end
