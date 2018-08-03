# require "test/unit"
require 'minitest/autorun'


require_relative '../lib/foxit/api'


class TestGetAnimeResponses < Minitest::Test
# class TestGetAnimeResponses < Test::Unit::TestCase
  

  def setup
    @api = Foxit::API.new()
    @slug = 'cowboy-bebop'
  end

  def test__get_anime_by_attr_id_json
    result = @api._get_anime_by_attr(:id, 1, :json)
    assert_equal(@slug, result['data']['attributes']['slug'])
  end

  def test__get_anime_by_attr_id_object
    result = @api._get_anime_by_attr(:id, 1, :object)
    assert_equal(@slug, result.slug)
  end

  def test__get_anime_by_attr_slug_json
    result = @api._get_anime_by_attr(:slug, @slug, :json)
    assert_equal(@slug, result['data'][0]['attributes']['slug'])
  end
  
  def test__get_anime_by_attr_slug_object
    result = @api._get_anime_by_attr(:slug, @slug, :object)
    assert_equal(@slug, result.slug)
  end

  def test_get_anime_by_id_base
    result = @api.get_anime_by_id(1)
    assert_equal(@slug, result.slug)
  end

  def test_get_anime_by_slug_base
    result = @api.get_anime_by_slug(@slug)
    assert_equal(@slug, result.slug)
  end

end