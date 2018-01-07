require 'oauth'
require 'json'
require 'mongo'

require_relative 'db'


# TODO: refactor

# kitsu.io api authentication details
$api = "https://kitsu.io/api/edge/"
consumer_key = "xxxxxxxxxxxxxxxxxxxxxxx"
consumer_secret = "xxxxxxxxxxxxxxxxxxxx"
$consumer = OAuth::Consumer.new(consumer_key, consumer_secret)


def get_data(url)
  response = $consumer.request(:get, url)
  return JSON.parse(response.body)['data']
end


def get_doc(type, id)
  return get_data("#{$api}#{type}/#{id}")
end


def get_genres(type, id)
  doc = get_data("#{$api}#{type}/#{id}/relationships/genres")
  genres = []
  doc.each do |x|
    if x['type'] == 'genres'
      genres << x['id'].to_i
    end
  end
  return genres
end


def field_key_replace(doc, fields, s, r)
  fields.each do |field|
    encoded = {}
    doc[field].each_pair do |k, v|
      encoded[k.tr(s, r)] = v.to_i
    end
    doc[field] = encoded
  end
  return doc
end


def encode(doc, fields)
  return field_key_replace(doc, fields, '.', '-')
end


def decode(doc, fields)
  return field_key_replace(doc, fields, '-', '.')
end


def transform_media(doc)
  x = {:id => doc['id'].to_i}
  x = x.merge(doc['attributes'])

  q = {}
  x['ratingFrequencies'].each_pair do |k, v|
    q[k.tr('.', '-')] = v.to_i
  end
  x['ratingFrequencies'] = q

  return x
end


def get_media(type='anime', from=1, to=6)
  docs = []
  for id in from..to
    doc = get_doc(type, id)
    unless doc.nil?
      doc = transform_media(doc)
      doc['genres'] = get_genres(type, id)
      docs << doc
      puts "#{id}: #{doc['slug']}"
    end
  end
  return docs
end
