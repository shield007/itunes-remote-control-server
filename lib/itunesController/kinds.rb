class SpecialKind
    attr_accessor :kind, :displayName
    def initialize(kind,displayName)
        @kind = kind
        @displayName = displayName
    end

    Audiobooks=SpecialKind.new(1800630337,"Audiobooks")
    Folder=SpecialKind.new(1800630342,"Folder")
    Movies=SpecialKind.new(1800630345,"Movies")
    Music=SpecialKind.new(1800630362,"Music")
    None=SpecialKind.new(1800302446,"None")
    PartyShuffle=SpecialKind.new(1800630355,"Party Shuffle")
    Podcasts=SpecialKind.new(1800630352,"Podcasts")
    PurchasedMusic=SpecialKind.new(1800630349,"Purchased Music")
    TVShows=SpecialKind.new(1800630356,"TV Shows")
    Videos=SpecialKind.new(1800630358,"Videos")
    Genius=SpecialKind.new(1800630343,"Genius")
    ITunesU=SpecialKind.new(1800630357,"iTunes U")
    Library=SpecialKind.new(1800630348,"Library")
    Unknown=SpecialKind.new(-1,"Unknown")

    @@values=[Audiobooks,Folder,Movies,Music,
        None,PartyShuffle,Podcasts,PurchasedMusic,
        TVShows, Videos,Genius,ITunesU,Library,Unknown]

    def self.fromKind(kind)
        @@values.each { | v1 |
            if (v1.kind==kind)
            return v1
            end
        }
        return SpecialKind.new(v1,"Unknown")
    end

    def to_s
        return "#{displayName} (#{kind})"
    end
end

class SourceKind
    attr_accessor :kind, :displayName
    def initialize(kind,displayName)
        @kind = kind
        @displayName = displayName
    end

    AudioCD=SourceKind.new(1799439172,"Audio CD")
    Device=SourceKind.new(1799644534,"Device")
    IPod=SourceKind.new(1800433508,"iPod")
    Library=SourceKind.new(1800169826,"Library")
    MP3CD=SourceKind.new(1800225604,"MP3 CD")
    RadioTuner=SourceKind.new(1800697198,"Radio Tuner")
    SharedLibrary=SourceKind.new(1800628324,"Shared Library")
    Unknown=SourceKind.new(1800760938,"Unknown")

    @@values=[AudioCD,Device,IPod,Library,MP3CD,RadioTuner,SharedLibrary,Unknown]

    def self.fromKind(kind)
        @@values.each { | v1 |
            if (v1.kind==kind)
            return v1
            end
        }
        return SourceKind.new(v1,"Unknown")
    end

    def to_s
        return "#{displayName} (#{kind})"
    end
end
