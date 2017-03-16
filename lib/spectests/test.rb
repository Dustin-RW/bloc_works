require_relative '../bloc_works.rb'
require "rack/test"
require "test/unit"

class HomepageTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BlocWorks::Application.new
  end

  def test_homepage_returns_a_200_status
    get "/"
    assert last_response.ok?
  end

  def test_homepage_innerHTML_says_Hello
    get "/"
    assert_equal("Hello Blocheads!", last_response.body, message = "fail")
  end
end
