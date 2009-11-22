require 'test/unit'

require 'vorbis'

class VorbisTest < Test::Unit::TestCase
  def test_info_sudo_modprobe
    Vorbis::Info.open('test/sudo_modprobe.ogg') do |info|
      assert_equal ['http://linuxoutlaws.com'], info.comments['LICENSE']
      assert_equal ['Sudo Modprobe (The Linux Outlaws Theme)'], info.comments['tItLe']
      assert_equal ['The Linux Outlaws'], info.comments[:artist]
      assert_equal(192000, info.nominal_bitrate)
      assert_equal(44100, info.sample_rate)
    end
  end
end

