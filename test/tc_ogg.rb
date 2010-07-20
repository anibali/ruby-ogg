require 'test/unit'

require 'rubygems'
require 'ogg'

class OggTest < Test::Unit::TestCase
  def setup
    @test_dir = File.dirname(File.expand_path(__FILE__))
  end  
  
  def test_read_page
    dec = Ogg::Decoder.new open(File.join(@test_dir, "sudo_modprobe.ogg"))
    # First page
    page = dec.read_page
    assert_equal 0, page.page_sequence_number
    assert_equal 0, page.granule_position
    assert_equal 30, page.data.size
    assert_equal "\1vorbis", page.data[0..6]
    # Second page
    page = dec.read_page
    assert_equal 1, page.page_sequence_number
    assert_equal 18446744073709551615, page.granule_position
    assert_equal 4335, page.data.size
    assert_equal "\3vorbis", page.data[0..6]
  end
  
  def test_read_packet
    dec = Ogg::Decoder.new open(File.join(@test_dir, "sudo_modprobe.ogg"))
    # First packet
    packet = dec.read_packet
    assert_equal 30, packet.size
    assert_equal "\1vorbis", packet[0..6]
    # Second packet
    packet = dec.read_packet
    assert_equal 173685, packet.size
    assert_equal "\3vorbis", packet[0..6]
  end
end

