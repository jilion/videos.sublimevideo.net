module VideoTagDataUnaliaser

  DICTIONARY = {
    uo: 'uid_origin',
    t:  'title',
    p:  'poster_url',
    z:  'size',
    d:  'duration',
    s:  'sources',
    i:  'sources_id',
    io: 'sources_origin',
    a:  'settings',
    o:  'options',
    origin: {
      a: 'attribute',
      s: 'source',
      y: 'youtube'
    },
    source: {
      u: 'url',
      q: 'quality',
      f: 'family',
      r: 'resolution'
    }
  }

  class << self
    def unalias(data)
      Hash[data.map { |key, value|
        case key = unalias_string(key)
        when /origin/
          [key, value.nil? ? nil : unalias_string(value, :origin).to_s]
        when :sources
          [key, unalias_sources(value)]
        else
          [key, value]
        end
      }]
    end

    private

    def unalias_string(key, namespace = nil)
      if namespace
        DICTIONARY[namespace][key.to_sym].to_sym
      else
        DICTIONARY[key.to_sym].to_sym
      end
    end

    def unalias_sources(data)
      data.map { |source|
        Hash[source.map { |key, value|
          [unalias_string(key, :source), value]
        }]
      }
    end
  end
end
