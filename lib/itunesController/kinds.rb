#
# Copyright (C) 2011-2012  John-Paul.Stanford <dev@stanwood.org.uk>
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

require 'itunesController/logging'

module ItunesController
        
    # A enum of special kinds
    # @attr [Number] kind The Source kind ID
    # @attr [String] String the source display name
    class SpecialKind
        attr_accessor :kind, :displayName
        def initialize(kind,displayName)
            @kind = kind
            @displayName = displayName
        end
    
        # The Audio Book kind 
        Audiobooks=SpecialKind.new(1800630337,"Audiobooks")
        # The folder kind
        Folder=SpecialKind.new(1800630342,"Folder")
        # The movie kind
        Movies=SpecialKind.new(1800630345,"Movies")
        # The music kind
        Music=SpecialKind.new(1800630362,"Music")
        # The none kind
        None=SpecialKind.new(1800302446,"None")
        # The party shuffle kind
        PartyShuffle=SpecialKind.new(1800630355,"Party Shuffle")
        # The pod cast kind
        Podcasts=SpecialKind.new(1800630352,"Podcasts")
        # The purchased music kind
        PurchasedMusic=SpecialKind.new(1800630349,"Purchased Music")        
        # The TV show kind
        TVShows=SpecialKind.new(1800630356,"TV Shows")
        # The video kind
        Videos=SpecialKind.new(1800630358,"Videos")
        # The genius kind
        Genius=SpecialKind.new(1800630343,"Genius")
        # The iTunesU kind
        ITunesU=SpecialKind.new(1800630357,"iTunes U")
        # The library kind
        Library=SpecialKind.new(1800630348,"Library")
        # The unknown kind
        Unknown=SpecialKind.new(-1,"Unknown")
    
        @@values=[Audiobooks,Folder,Movies,Music,
            None,PartyShuffle,Podcasts,PurchasedMusic,
            TVShows, Videos,Genius,ITunesU,Library,Unknown]
    
        # A class scoped method used to get the kind associated with the kind ID
        # @param kind The kind ID
        # @return [ItunesController::SourceKind] The source kind object
        def self.fromKind(kind)
            @@values.each { | v1 |
                if (v1.kind==kind)
                return v1
                end
            }
            ItunesController::ItunesControllerLogging::warn("Unknown SpecialKind #{kind}")
            return SpecialKind.new(v1,"Unknown")
        end
    
        # Used pretty print the kind to a string
        # @return A string containing the kind display name and ID
        def to_s
            return "#{displayName} (#{kind})"
        end
    end
    
    # Enum of video kinds
    # @attr [Number] kind The Source kind ID
    # @attr [String] String the source display name
    class VideoKind
        
        attr_accessor :kind, :displayName
        
        # The constructor
        # @param [Number] kind The kind ID
        # @param [String] displayName The kind display name        
        def initialize(kind,displayName)
            @kind = kind
            @displayName = displayName
        end
            
        # The TVShow Source Kind
        TVShow=VideoKind.new(1800823892,"TV Show")       
        Movie=VideoKind.new(1800823885,"Movie")
        MusicVideo=VideoKind.new(1800823894,"Music Video")
        None=VideoKind.new(1800302446,"None")        
        # The unknown kind
        Unknown=SpecialKind.new(-1,"Unknown") 
    
        @@values=[TVShow,Movie,MusicVideo,None,Unknown]
    
        # A class scoped method used to get the kind associated with the kind ID
        # @param kind The kind ID
        # @return [ItunesController::SourceKind] The source kind object
        def self.fromKind(kind)
            @@values.each { | v1 |
                if (v1.kind==kind)
                    return v1
                end
            }
            ItunesController::ItunesControllerLogging::warn("Unknown VideoKind #{kind}")
            return SourceKind.new(kind,"Unknown")
        end
    
        # Used pretty print the kind to a string
        # @return A string containing the kind display name and ID
        def to_s            
            return "#{displayName} (#{kind})"
        end
    end
        
    
    # Enum of source kinds
    # @attr [Number] kind The Source kind ID
    # @attr [String] String the source display name 
    class SourceKind
        
        attr_accessor :kind, :displayName

        # The constructor
        # @param [Number] kind The kind ID
        # @param [String] displayName The kind display name        
        def initialize(kind,displayName)
            @kind = kind
            @displayName = displayName
        end
            
        # The Audio CD Source Kind
        AudioCD=SourceKind.new(1799439172,"Audio CD")
        # The Device Source Kind
        Device=SourceKind.new(1799644534,"Device")
        # The iPod Source Kind
        IPod=SourceKind.new(1800433508,"iPod")
        # The Library Source Kind
        Library=SourceKind.new(1800169826,"Library")
        # The MP3 CD Source Kind
        MP3CD=SourceKind.new(1800225604,"MP3 CD")
        # The Radio Tuner Source Kind
        RadioTuner=SourceKind.new(1800697198,"Radio Tuner")
        # The Shared Libarary Source Kind
        SharedLibrary=SourceKind.new(1800628324,"Shared Library")
        # The Unknown Source Kind
        Unknown=SourceKind.new(1800760938,"Unknown")
    
        @@values=[AudioCD,Device,IPod,Library,MP3CD,RadioTuner,SharedLibrary,Unknown]
    
        # A class scoped method used to get the kind associated with the kind ID
        # @param kind The kind ID
        # @return [ItunesController::SourceKind] The source kind object
        def self.fromKind(kind)
            @@values.each { | v1 |
                if (v1.kind==kind)
                return v1
                end
            }
            ItunesController::ItunesControllerLogging::warn("Unknown SourceKind #{kind}")
            return SourceKind.new(kind,"Unknown")
        end
    
        # Used pretty print the kind to a string
        # @return A string containing the kind display name and ID
        def to_s            
            return "#{displayName} (#{kind})"
        end
    end
end