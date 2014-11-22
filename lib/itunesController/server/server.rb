require 'sinatra'

module ItunesController


    class HelloWorldApp < Sinatra::Base
        get '/' do
            "Hello, world!"
        end
    end

end

ItunesController::HelloWorldApp.run!
