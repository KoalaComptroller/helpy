require 'integration_test_helper'

include Warden::Test::Helpers

class BrowsingUserTicketFlowsTest < ActionDispatch::IntegrationTest

  def setup
    Warden.test_mode!
    logout(:user)
    set_default_settings
  end

  def teardown
    Capybara.reset_sessions!
    Warden.test_reset!
  end

  test "a browsing user who is not registered should be able to create a private ticket via the web interface" do

    # create new private ticket
    visit '/en/topics/new/'

    # a new user should be created
    assert_difference('User.count', 1) do
      assert_difference('Topic.count',1) do
        fill_in('topic_user_email', with: 'test@test.com')
        fill_in('topic[user][name]', with: 'John Smith')
        fill_in('topic[name]', with: 'I got problems')
        fill_in('post[body]', with: 'Please help me!!')
        click_on('Start Discussion', disabled: true)
      end
    end

    assert current_path == '/en/thanks'

  end

  test "a browsing user who is registered should be able to create a private ticket via the web interface" do

    # create new private ticket
    visit '/en/topics/new/'

    # A new user should not be created
    assert_difference('User.count', 0) do
      assert_difference('Topic.count',1) do
        fill_in('topic_user_email', with: 'scott.miller@test.com')
        fill_in('topic[user][name]', with: 'Scott Miller')
        fill_in('topic[name]', with: 'I got problems')
        fill_in('post[body]', with: 'Please help me!!')
        click_on('Start Discussion', disabled: true)
      end
    end

  end

  test "a browsing user should be prompted to login from a public forum page" do

    forums = [  "/en/community/3-public-forum/topics",
                "/en/community/4-public-idea-board/topics",
                "/en/community/5-public-q-a/topics" ]

    forums.each do |forum|
      visit forum
      click_on "New Discussion"
      assert find("div#login-modal").visible?
    end
  end

  test "a browsing user should be prompted to login when clicking reply from a public discussion view" do

    topics = [ "/en/topics/5-new-public-topic/posts",
               "/en/topics/8-new-idea/posts",
               "/en/topics/7-new-question/posts" ]

    topics.each do |topic|
      visit topic
      click_on "Reply"
      assert find("div#login-modal").visible?
    end
  end

  test "a browsing user should be able to create a private ticket via widget" do

    visit '/widget'

    assert_difference('Post.count', 1) do
      fill_in('topic_user_email', with: 'joe@test.com')
      fill_in('topic_user_name', with: 'Joe Guy')
      fill_in('topic[name]', with: 'I got problems')
      fill_in('post[body]', with: 'Please help me!!')
      click_on('Start Discussion', disabled: true)
    end

  end


end
