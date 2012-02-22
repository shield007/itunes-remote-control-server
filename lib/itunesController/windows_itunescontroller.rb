require 'win32ole'

module ItunesController

    class WindowsITunesController < ITunesController

        # The constructor
        def initialize
            @iTunes = WIN32OLE.new('iTunes.Application')
            @libraryPlaylists=@iTunes.LibraryPlaylist
        end

        # Used to get the libaray play lists
        # @return The iTunes playlist
        def getLibraryPlaylists
            return @libraryPlaylists
        end

        # Used to get the iTunes version
        # @return [String] The itunes version
        def version
            return @iTunes.version
        end

        # Used to tell iTunes to refresh a list of tracks data from the info stored in the files
        # @param [Array] tracks A list of tracks to fresh
        def refreshTracks(tracks)
            tracks.reverse.each do | track |
                puts("Refresh track '#{track.location.path}'")
                track.UpdateInfoFromFile
            end
        end

        # Used to remove tracks from the libaray
        # @param [Array] tracks A list of tracks to remove from the itunes libaray
        def removeTracksFromLibrary(tracks)
            tracks.reverse.each do | track |
                puts("Remove track '#{track.location.path}' from iTunes library")
                track.Delete
            end
        end

        # Used to add a list of files to the itunes library
        # @param [Array[String]] A list of files to add to the itunes library
        # @return True if it sucesseds, or false if their is a error
        def addFilesToLibrary(files)
            files.each do | file |
                @iTunes.LibraryPlaylist.AddFile(file)
            end

            return true;
        end

        # Used to get a list of tracks that have the given locations
        # @param [Array[String]] locations a list of track locations to find
        # @return [Array[OSX::ITunesFileTrack]] A list of tracks that were found
        def findTracksWithLocations(locations)
            tracks=[]
            @libraryPlaylists.Tracks.each do | track |                     
                if (track.Location != nil)
                    if (locations.index(track.location.path))
                        tracks.push(track)
                        if (tracks.size == locations.size)
                            return tracks
                        end
                    end
                end                
            end
            return tracks
        end

        # Used to get a track with the given location
        # @param [String] location The location of the track to find
        # @return The track that was found, or nil if it could not be found
        def findTrackWithLocation(location)
            @libraryPlaylists.Tracks.each do | track |                
                if (track.Location.isFileURL)
                    if (track.location.path==location)
                        return track
                    end
                end         
            end
            return nil
        end

        # Used to find the dead tracks (tracks whoes file references don't exist) within the
        # iTunes libaray
        # @return [Array] A list of dead tracks
        def findDeadTracks()
            deadTracks=[]
            @libraryPlaylists.Tracks.each do | track |                
                if (track.Location==nil)
                    deadTracks.push(track)
#                elsif (track.location!=nil && track.location.isFileURL)
                elsif (track.location!=nil)
                    if (!File.exist?(track.Location))
                        deadTracks.push(track)
                    end
                end               
            end
            return deadTracks
        end

        # Used to list all the files in the library
        # @abstract Must be overridden
        # @return [Array] A list of files in the iTunes library
        def listFilesInLibrary()
            files=[]
            @libraryPlaylists.each do | playlist |
                playlist.fileTracks.each do |track|
                    if (track.location !=nil && track.location.isFileURL)
                        files.push(track)
                    end
                end
            end
            return files
        end

    end
end