require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  # test "should pull out motionx url from email body" do
  #   string = File.open("#{RAILS_ROOT}/test/fixtures/motionx_email.txt").read
  #   urls = Mailman.extract_motionx_url(string)
  #   assert_equal urls.size, 1
  #   assert_equal urls[0], "http://maps.google.com/?t=p&z=15&ll=37.78953170776367,-122.44117736816406&q=http://api.motionxlive.com/motionx-remote/api/gps/host/a75f5ef1-8c3a-4fff-8c5f-4752d9658c2e"
  # end
  def setup
    User.all.each{|u| u.destroy}
  end

  test "mailman should be able to parse user from email address" do
    user = User.create(:name => "Bilbo Baggins", :email => "my@bobo.com", :password => "sekret", :password_confirmation => "sekret", :login => "bobo")
    assert_equal Mailman.parse_user_from_address("tracks+bobo@something.com"), user
  end

  test "mailman should return nil if no user matches" do
    assert_equal Mailman.parse_user_from_address("tracks+boboasdfas@something.com"), nil
  end
end