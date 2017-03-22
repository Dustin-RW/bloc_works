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

  def test_it_routes_through_controller
    get "/books/welcome"

    assert last_response.ok?
    assert_equal(200, last_response.status)
    assert_equal("text/html", last_response.content_type)  #text/html is default, see: http://www.rubydoc.info/github/rack/rack/Rack/ContentType
  end

  def test_creates_route
    get "/books/create"

    assert_equal(200, last_response.status)
    # assert_equal(<<-HTML, last_response.body)
    #   <p>Whatever</p>
    # HTML
  end

  def test_show_route
    get "/books/show"

    assert_equal(200, last_response.status)
  end

  def test_updates_route
    get "/books/update"

    assert_equal(200, last_response.status)
  end

  def test_destroy_route
    get "/books/destroy"

    assert_equal(200, last_response.status)
  end
end
