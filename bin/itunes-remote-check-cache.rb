#!/usr/bin/ruby -I../lib
#
# A command line util used to add tracks to the iTunes library
#
# Author:: John-Paul Stanford <dev@stanwood.org.uk>
# Copyright:: Copyright (C) 2011  John-Paul.Stanford <dev@stanwood.org.uk>
# License:: GNU General Public License v3 <http://www.gnu.org/licenses/>
#

require 'rubygems'
require 'pathname'
require 'itunesController/remote_application'

class CheckCacheApp < ItunesController::RemoteApplication          
    
    def execApp(args)        
        checkCache()
    end
end

if __FILE__.end_with?(Pathname.new($0).basename)
    args = ARGV
    app=CheckCacheApp.new("itunes-remote-check-cache.rb")
    app.exec(args)
end
