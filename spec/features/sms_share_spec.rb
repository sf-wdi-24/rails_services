require "rails_helper"

RSpec.describe "sms share", type: :feature do
  before do
    @user = FactoryGirl.create(:user)
    @post = FactoryGirl.create(:post)
    @user.posts << @post
    visit login_path
    fill_in "user_email", with: @user.email
    fill_in "user_password", with: @user.password
    click_button "Log In"
  end

  describe "share post via sms" do
    it "should send sms to all valid phone numbers" do
      visit share_post_path(@post)
      fill_in "share_numbers", with: "555-555-5555, 666-666-6666, 415-316-9718"
      click_button "Share Post"

      within ".alert.alert-info" do
        expect(page).to have_content("+14153169718")
      end
      within ".alert.alert-danger" do
        expect(page).to have_content("+15555555555, +16666666666")
      end
    end
  end

end