require 'minitest/autorun'

require_relative '../lib/foxit/api'



class TestGetLibraryResults < Minitest::Test

  def setup
    @api = Foxit::API.new()
    @user_id = 1
  end

  def test_get_library_by_id
    result = @api.get_library_by_id(@user_id)
    assert_kind_of(Hash, result[0], 'result should be an array of Hash objects')
    assert(result.length > 10, 'user library should not be empty')  # user 1 library is 35 'complete' items
  end

  def test_get_user_library_by_id
    result = @api.get_user_library_by_id(@user_id)
    assert_kind_of(LibraryItem, result[0], 'result should be an array of LibraryItem objects')
    assert(result.length > 10, 'user library should not be empty')
  end
  
  def test_batch_get_libraries
    result = @api.batch_get_libraries(1..2)
    assert_kind_of(LibraryItem, result[0], 'result should be an array of LibraryItem objects')
    assert(result.length > 40, 'user library should not be empty')
  end

end