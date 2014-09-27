require 'bindata'

module Vorbis
  # This class reads metadata (such as comments/tags and bitrate) from Vorbis 
  # audio files. Here's an example of usage:
  #
  #  require 'vorbis'
  #  
  #  Vorbis::Info.open('echoplex.ogg') do |info|
  #    info.comments[:artist].first #=> "Nine Inch Nails"
  #    info.comments[:title].first  #=> "Echoplex"
  #    info.sample_rate             #=> 44100
  #  end
  #
  # You may notice that for each comment field an array of values is
  # available. This is because it is perfectly valid for a Vorbis file
  # to have multiple artists, titles, or anything else.
  class Info
    attr_reader :identification_header, :comment_header
    attr_reader :comments
    attr_reader :duration, :sample_rate, :nominal_bitrate, :channels, :bitrate
    
    # Create a new Vorbis::Info object for reading metadata.
    def initialize(path, container=:ogg)
      if path.is_a? IO
        @io = path
      else
        @io = open(path, 'rb')
      end
      
      case container
      when :ogg
        init_ogg
      else
        raise "#{container.to_s} is not a supported container format"
      end
      
      @io.close
      
      yield self if block_given?
    end
    
    def self.open(*args, &block)
      return self.new(*args, &block)
    end
    
    # Read Vorbis metadata from within an Ogg container.
    private
    def init_ogg
      require 'ogg'
      
      parser = Ogg::Decoder.new @io
      
      @identification_header = IdentificationHeader.read(parser.read_packet)
      @sample_rate = @identification_header.audio_sample_rate
      @nominal_bitrate = @identification_header.bitrate_nominal
      @channels = @identification_header.audio_channels
      
      @comment_header = CommentHeader.read(parser.read_packet)
      @comments = @comment_header.comments
      
      pos_after_headers = @io.pos
      
      begin
        # Duration is last granule position divided by sample rate
        pos = parser.read_last_page.granule_position.to_f
        @duration = pos / @sample_rate
      rescue Exception
        @duration = 0
      end
      
      begin
        @bitrate = (file.stat.size - pos_after_headers).to_f * 8 / @duration
      rescue Exception
        @bitrate = 0
      end
    end
  end
  
  # A BinData::Record which represents a Vorbis identification header.
  class IdentificationHeader < BinData::Record
    endian   :little
    uint8    :packet_type, :value => 1
    string   :codec, :value => 'vorbis', :read_length => 6
    uint32   :vorbis_version
    uint8    :audio_channels
    uint32   :audio_sample_rate
    int32    :bitrate_maximum
    int32    :bitrate_nominal
    int32    :bitrate_minimum
    bit4     :blocksize_0
    bit4     :blocksize_1
  end
  
  # A simple subclass of Hash which converts keys to uppercase strings.
  class InsensitiveHash < Hash
    def [](key)
      super(key.to_s.upcase)
    end
    
    def []=(key, value)
      super(key.to_s.upcase, value)
    end
  end
  
  # A BinData::BasePrimitive which represents a list of comments as per 
  # the Vorbis I comment header specification.
  class Comments < BinData::BasePrimitive
    def read_and_return_value(io)
      n_comments = read_uint32le(io)
      comments = InsensitiveHash.new
      n_comments.times do
        length = read_uint32le(io)
        comment = io.readbytes(length)
        key, value = comment.split('=', 2)
        (comments[key] ||= []) << value
      end
      return comments
    end
    
    def sensible_default
      return {}
    end

    def read_uint32le(io)
      return BinData::Uint32le.read(io)
    end
  end
  
  # A BinData::Record which represents a Vorbis comment header.
  class CommentHeader < BinData::Record
    endian   :little
    uint8    :packet_type, :value => 3
    string   :codec, :value => 'vorbis', :read_length => 6
    uint32   :vendor_length
    string   :vendor_string, :read_length => :vendor_length
    comments :comments
  end
end

