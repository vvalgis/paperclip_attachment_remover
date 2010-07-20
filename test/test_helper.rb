require 'rubygems'
require 'test/unit'
require 'active_record'


ActiveRecord::Base.establish_connection({
  :adapter => 'sqlite3',
  :database => ':memory:'
})

ActiveRecord::Schema.define do
  create_table "example_model_with_attachments", :force => true do |t|
    t.string :attachment_file_name
  end
end