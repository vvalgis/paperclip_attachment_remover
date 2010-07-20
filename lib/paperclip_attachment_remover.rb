module PaperclipAttachmentRemover #:nodoc:
  
  def self.included(base) #:nodoc:
    base.send :extend, ClassMethods
  end

  module ClassMethods
    # list of attributes for observing by remover
    attr_reader :attributes_for_removal_observation
    
    # prefix for remover attribute
    attr_reader :remove_name_prefix
    
    # Set list of attributes for observing by remover
    def attachment_remover_observe *attribute_names
      send :include, InstanceMethods

      options = attribute_names.extract_options!
      @remove_name_prefix = options.fetch(:remove_name_prefix, 'remove')
      
      existing_columns = column_names.select { |cn| cn.match('_file_name')  }
      attribute_names.map{|a| "#{a}_file_name"}.each do |attribute_name|
        raise ActiveRecord::UnknownAttributeError unless existing_columns.include? attribute_name
      end
      
      attr_accessor *(attribute_names.map { |an| "#{@remove_name_prefix}_#{an}".to_sym })
      before_save :paperclip_attachment_remover_proceed
      
      @attributes_for_removal_observation = attribute_names
    end
  end

  module InstanceMethods
    # return name of form field that trigger deletion of attachment
    def attachment_remover_name_for attribute
      "#{self.class.remove_name_prefix}_#{attribute}"
    end
    
    private

      def paperclip_attachment_remover_proceed #:nodoc:
        unless self.class.attributes_for_removal_observation.empty?
          self.class.attributes_for_removal_observation.each do |attribute|
            self.send("#{attribute}=", nil) if self.send("#{self.class.remove_name_prefix}_#{attribute}") == "1" && !self.send(attribute).dirty? 
          end
        end
        true
      end
    
  end
end
