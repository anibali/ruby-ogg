require 'rubygems'
require 'bindata'

require 'stringio'

module Ogg
  # This is a superclass for all custom defined Ogg decoding errors
  class DecodingError < StandardError
  end
  
  # This error is raised when the file format is not valid Ogg
  class MalformedFileError < DecodingError
  end
  
  # Ogg::Decoder is used to decode Ogg bitstreams. The easiest way of properly
  # parsing an Ogg file is to read consecutive packets with the read_packet
  # method. For example:
  #
  #  require 'ogg'
  #  
  #  open("file.ogg", "rb") do |file|
  #    dec = Ogg::Decoder.new(file)
  #    packet = dec.read_packet
  #    # Do something with the packet...
  #  end
  #
  # The terms "page" and "packet" have special meanings when dealing with Ogg. A
  # packet is a section of data which is encoded in the Ogg container. A page
  # is a section of the Ogg container used as a means of storing packets.
  # Since packets are what contain the "juicy bits" of the file, Ogg::Decoder
  # provides sufficient abstraction to make handling of individual pages
  # unnecessary. However, if you do need to read pages, that functionality is 
  # available via the read_page method.
  class Decoder
    # Create a new Decoder from an IO which should be open for binary reading.
    def initialize io
      @io = io
      @packets = []
    end
    
    # Moves the file cursor forward to the next potential page. You probably
    # wish to use the read_page method, which does some validation and actually
    # returns the parsed page.
    def seek_to_page(capture='OggS')
      buffer = @io.read(capture.size)
      page = nil
      while not @io.eof?
        if buffer == capture
          @io.pos -= capture.size
          return @io.pos
        end
        (buffer = buffer[1..-1] << @io.read(1)) rescue Exception
      end
      
      raise EOFError
    end

    # Seek to and read the next page from the bitstream. Returns a Page or
    # nil if there are no pages left.
    def read_page
      page = nil
      while not @io.eof?
        begin
          seek_to_page
          page = Page.read @io
          page = nil unless page.verify_checksum
          break
        rescue Exception => ex
          # False alarm, keep looking...
        end
      end
      return page
    end
    
    # Seek to and read the last page in the bitstream.
    def read_last_page
      raise 'Last page can only be read from a file stream' unless @io.is_a? File
			buffer_size = 1024
			pos = @io.stat.size - buffer_size
			while pos > 0
				@io.seek pos, IO::SEEK_SET
				sio = StringIO.new @io.read(buffer_size)
				
				dec = Decoder.new(sio)
				sub_pos = nil
				
				# Find last page in buffer
        loop do
          begin
            sub_pos = dec.seek_to_page
            sio.pos += 1
          rescue
            break
          end
        end

        if sub_pos
          @io.seek(pos + sub_pos, IO::SEEK_SET)
          page = read_page
          return page
        end
        
				pos -= buffer_size * 2 - ('OggS'.size - 1)
			end
			
			# This means that the Ogg file contains no pages
			raise MalformedFileError
    end
    
    # Seek to and read the next packet in the bitstream. Returns a string
    # containing the packet's binary data or nil if there are no packets
    # left.
    def read_packet
      return @packets.pop unless @packets.empty?
      
      while @packets.empty?
        page = read_page
        raise EOFError.new("End of file reached") if page.nil?
        input = StringIO.new(page.data)
        
        page.segment_table.each do |seg|
          @partial ||= ""
          
          @partial << input.read(seg)
          if seg != 255
            @packets.insert(0, @partial)
            @partial = nil
          end
        end
      end
      
      return @packets.pop
    end
  end
  
  # A BinData::Record which represents an Ogg page.
  class Page < BinData::Record
    endian   :little
    string   :capture, :value => 'OggS', :read_length => 4
    uint8    :version, :value => 0
    uint8    :page_type
    uint64   :granule_position
    uint32   :bitstream_serial_number
    uint32   :page_sequence_number
    uint32   :checksum
    uint8    :page_segments
    array    :segment_table, :type => :uint8, :initial_length => :page_segments
    string   :data, :read_length => lambda {segment_table.inject(0){|t,e| t+e}}
    
    def verify_checksum
      poly = 0x04c11db7
      # TODO: Implement CRC
      return true
    end
  end
end

