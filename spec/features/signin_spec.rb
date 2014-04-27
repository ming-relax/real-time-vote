require 'spec_helper'

describe "the sign in process", :type => :feature, :js => true do
  it "signs me in" do
    visit "/"
    fill_in("username", :with => 'ming')
    fill_in("password", :with => '123')
    click_button('Sign in')
    sleep 60
    page.should have_css('.square')
  end
end
