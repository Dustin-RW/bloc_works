require "bloc_works/version"
require "bloc_works/controller"

module BlocWorks
  class Application
    #call returns an array containing an HTTP status code, an HTTP header, and the text to display in the Browser
    def call(env)
      [200, {'Content-Type' => 'text/html'}, ["Hello Blocheads!"]]
      # response = fav_icon(env)
      #
      # if response.nil?
      # end
      # if requesting favicon.ico - return fav_icon response
      # otherwise, execute action on controller and return result
    end

  end
end
