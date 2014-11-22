#
# Copyright (C) 2011-2014  John-Paul.Stanford <dev@stanwood.org.uk>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'sinatra'
require "sinatra/json"
require 'itunesController/logging'

module ItunesController
    
    class ITunesRestServer < Sinatra::Base
#        set :sessions => true
#
#        register do
#            def auth (type)
#                condition do
#                    redirect "/login" unless send("is_#{type}?")
#                end
#            end
#        end
#        
#        helpers do
#            def is_user?
#              @user != nil
#            end
#        end
#        
#        before do
#            @user = User.get(session[:user_id])
#        end
#        
#        get "/" do
#            "Hello, anonymous."
#        end
#        
#        post "/login" do
#            session[:user_id] = User.authenticate(params).id
#        end
#        
#        get "/logout" do
#            session[:user_id] = nil
#        end
#        
#        get "/protected", :auth => :user do
#            "Hello, #{@user.name}."
#        end
#
        get '/ping/' do
            return json :result => 'pong'
        end
    end
    
    def runServer(config,itunes)
        ItunesController::ItunesControllerLogging::info("Starting iTunes control server....")
        
        ItunesController::ITunesRestServer.set :config, config
        ItunesController::ITunesRestServer.set :itunes, itunes
        ItunesController::ITunesRestServer.run!({'port'=> config.port,'bind' => config.interfaceAddress} )
    end
    
end




 

