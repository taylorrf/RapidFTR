require 'spec/spec_helper'

When /^I fill in the basic details of a child$/ do

  fill_in("Last known location", :with => "Haiti")
  attach_file("photo", "features/resources/jorge.jpg", "image/jpg")

end

When /^the date\/time is "([^\"]*)"$/ do |datetime|
  current_time = Time.parse(datetime)
  Time.stub!(:now).and_return current_time
end

Given /^someone has entered a child with the name "([^\"]*)"$/ do |child_name|
  visit path_to('new child page')
  fill_in('Name', :with => child_name)
  fill_in('Last known location', :with => 'Haiti')
  attach_file("photo", "features/resources/jorge.jpg", "image/jpg")
  click_button('Finish')
end

Given /^the following children exist in the system:$/ do |children_table|
  children_table.hashes.each do |child_hash|
    child_hash.reverse_merge!(
      'last_known_location' => 'Cairo',
      'photo_path' => 'features/resources/jorge.jpg',
      'reporter' => 'zubair',
      'age_is' => 'Approximate'
    )
    
    photo = uploadable_photo(child_hash.delete('photo_path'))
    unique_id = child_hash.delete('unique_id')
    child = Child.new_with_user_name(child_hash['reporter'], child_hash)
    child.photo = photo
    child['unique_identifier'] = unique_id if unique_id
    child.create!
  end
end

Then /^I should see "([^\"]*)" in the column "([^\"]*)"$/ do |value, column|

  column_index = -1

  Hpricot(response.body).search("table tr th").each_with_index do |cell, index|
    if (cell.to_plain_text == column )
      column_index = index
    end
  end

  column_index.should be > -1
  rows = Hpricot(response.body).search("table tr")

  match = rows.find do |row|
    cells = row.search("td")
    (cells[column_index] != nil && cells[column_index].to_plain_text == value)
  end
  
  raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{value} in the table" unless match
end

Then /^I should see the photo of the child$/ do
  (Hpricot(response.body)/"img[@src*='']").should_not be_empty
end

Then /^I should see the photo of the child with a "([^\"]*)" extension$/ do |extension|
  (Hpricot(response.body)/"img[@src*='']").should_not be_empty
end

Then /^I should see the content type as "([^\"]*)"$/ do |content_type|
  response.content_type.should == content_type
end

Given /^a user "([^\"]*)" has entered a child found in "([^\"]*)" whose name is "([^\"]*)"$/ do |user, location, name|
  new_child_record = Child.new
  new_child_record['last_known_location'] = location
  new_child_record.create_unique_id(user)
  new_child_record['name'] = name
  new_child_record.photo = uploadable_photo("features/resources/jorge.jpg")
  raise "couldn't save a child record!" unless new_child_record.save
end

Given /^I am editing an existing child record$/ do
  child = Child.new
  child["last_known_location"] = "haiti"
  child.photo = uploadable_photo
  raise "Failed to save a valid child record" unless child.save

  visit children_path+"/#{child.id}/edit"
end

Given /there is a User/ do
  unless @user
    Given "a user \"mary\" with a password \"123\""
  end
end

Given /^there is a admin$/ do
  Given "a admin \"admin\" with a password \"123\""
end

Given /^I am logged in as an admin$/ do
  Given "there is a admin"
  Given "I am on the login page"
  Given "I fill in \"admin\" for \"user name\""
  Given "I fill in \"123\" for \"password\""
  Given "I press \"Log In\""
end


Given /^I am logged in$/ do
  Given "a user \"dave\" with a password \"p4ssword\" logs in"
end

Given /^I am logged in as "([^\"]*)"$/ do |user_name|
  Given "a user \"#{user_name}\" with a password \"p4ssword\" logs in"
end

Given /I am logged out/ do
  Given "I am sending a valid session token in my request headers"
  Given "I go to the logout page"
end

Given /"([^\"]*)" is logged in/ do |user_name|
  Given "a user \"#{user_name}\" with a password \"123\" logs in"
end

When /^I create a new child$/ do
  child = Child.new
  child["last_known_location"] = "haiti"
  child.photo = uploadable_photo
  child.create!
end

Given /^a user "([^\"]*)" with a password "([^\"]*)" logs in$/ do |user_name, password|
  Given "a user \"#{user_name}\" with a password \"#{password}\""
  Given "I am on the login page"
  Given "I fill in \"#{user_name}\" for \"user name\""
  Given "I fill in \"#{password}\" for \"password\""
  And  "I press \"Log In\""
end

Given /^there is a child with the name "([^\"]*)" and a photo from "([^\"]*)"$/ do |child_name, photo_file_path|
  child = Child.new( :name => child_name, :last_known_location => 'Chile' )

  child.photo = uploadable_photo(photo_file_path) 

  child.create!
end

Given /^the following form sections exist in the system:$/ do |form_sections_table|
  form_sections_table.hashes.each do |form_section_hash|
    FormSectionDefinition.create!(form_section_hash)
  end
end
