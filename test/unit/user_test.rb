require File.dirname(__FILE__) + '/../test_helper'

class UserTest < ActiveSupport::TestCase
  # Be sure to include AuthenticatedTestHelper in test/test_helper.rb instead.
  # Then, you can remove it from this and the functional test.
  include AuthenticatedTestHelper

  def setup
    User.all.each{|u| u.destroy}
  end

  def test_should_create_user
    bob = create_quentin
    assert_difference 'User.count' do
      user = create_user
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
    end
  end

  def test_should_require_login
    bob = create_quentin
    assert_no_difference 'User.count' do
      u = create_user(:login => nil)
      assert u.errors.on(:login)
    end
  end

  def test_should_require_password
    bob = create_quentin
    assert_no_difference 'User.count' do
      u = create_user(:password => nil)
      assert u.errors.on(:password)
    end
  end

  def test_should_require_password_confirmation
    bob = create_quentin
    assert_no_difference 'User.count' do
      u = create_user(:password_confirmation => nil)
      assert u.errors.on(:password_confirmation)
    end
  end

  def test_should_require_email
    bob = create_quentin
    assert_no_difference 'User.count' do
      u = create_user(:email => nil)
      assert u.errors.on(:email)
    end
  end

  def test_should_reset_password
    bob = create_quentin
    bob.update_attributes(:password => 'new password', :password_confirmation => 'new password')
    assert_equal bob, User.authenticate('quentin', 'new password')
  end

  def test_should_not_rehash_password
    bob = create_quentin
    bob.update_attributes(:login => 'quentin2')
    assert_equal bob, User.authenticate('quentin2', 'monkey')
  end

  def test_should_authenticate_user
    bob = create_quentin
    assert_equal bob, User.authenticate('quentin', 'monkey')
  end

  def test_should_set_remember_token
    bob = create_quentin
    bob.remember_me
    assert_not_nil bob.remember_token
    assert_not_nil bob.remember_token_expires_at
  end

  def test_should_unset_remember_token
    bob = create_quentin
    bob.remember_me
    assert_not_nil bob.remember_token
    bob.forget_me
    assert_nil bob.remember_token
  end

  def test_should_remember_me_for_one_week
    bob = create_quentin
    before = 1.week.from_now.utc
    bob.remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil bob.remember_token
    assert_not_nil bob.remember_token_expires_at
    assert bob.remember_token_expires_at.to_i.between?(before.to_i, after.to_i)
  end

  def test_should_remember_me_until_one_week
    bob = create_quentin
    time = 1.week.from_now.utc
    bob.remember_me_until time
    assert_not_nil bob.remember_token
    assert_not_nil bob.remember_token_expires_at
    assert_equal bob.remember_token_expires_at.to_i, time.to_i
  end

  def test_should_remember_me_default_two_weeks
    bob = create_quentin
    before = 2.weeks.from_now.utc
    bob.remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil bob.remember_token
    assert_not_nil bob.remember_token_expires_at
    assert bob.remember_token_expires_at.to_i.between?(before.to_i, after.to_i)
  end

protected
  def create_quentin
    User.create(:login => "quentin", :email => "quentin@example.com", :salt => "356a192b7913b04c54574d18c28d46e6395428ab",
                :crypted_password => "98d7c6e31ac4608ad5ecb8f1057d2b6cc5520dfb", :created_at => 5.days.ago.to_s, :remember_token_expires_at => 1.days.from_now.to_s,
                :remember_token => "77de68daecd823babbb58edb1c8e14d7106e83bb" )
  end

  def create_user(options = {})
    record = User.new({ :login => 'quire', :email => 'quire@example.com', :password => 'quire69', :password_confirmation => 'quire69' }.merge(options))
    record.save
    record
  end
end
