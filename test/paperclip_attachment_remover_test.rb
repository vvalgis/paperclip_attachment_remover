require 'test_helper'
require File.expand_path(File.dirname(__FILE__) +  '/../init')

# stub for paperclip
class Attachment
  attr_accessor :dirty
  def dirty?; @dirty; end 
end

class ExampleModelWithAttachment < ActiveRecord::Base
  attr_accessor :attachment
  attachment_remover_observe :attachment
end

class PaperclipAttachmentRemoverTest < Test::Unit::TestCase
  
  def setup
    a = Attachment.new
    a.dirty = true
    @emwa = ExampleModelWithAttachment.new(:attachment_file_name => 'test.txt', :attachment => a)
  end
  
  def test_return_remover_field_name
    assert_equal 'remove_attachment', @emwa.attachment_remover_name_for(:attachment)
    assert_equal 'remove_attachment', @emwa.attachment_remover_name_for('attachment')
    assert_not_equal 'remove_attachment', @emwa.attachment_remover_name_for('rose')
  end
  
  def test_return_remover_field_name_with_prefix_option
    @emwa.class.send(:attachment_remover_observe, :attachment, :remove_name_prefix => :delete)
    assert_equal 'delete_attachment', @emwa.attachment_remover_name_for(:attachment)
  end
  
  def test_setting_attribute_to_list_for_observation
    assert @emwa.class.attributes_for_removal_observation.include?(:attachment)
  end
  
  def test_removing_attachment_when_remover_field_set_to_1_and_attachment_is_not_new
    check false
  end
  
  def test_removing_attachment_when_remover_field_set_to_1_and_attachment_is_new
    check true
  end
  
  def check(dirtyness)
    @emwa.attachment.dirty = dirtyness
    assert_not_nil @emwa.attachment
    @emwa.update_attributes({:remove_attachment => "1"})
    if dirtyness
      assert_not_nil @emwa.attachment
    else
      assert_nil @emwa.attachment
    end
  end
  
end
