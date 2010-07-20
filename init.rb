require 'paperclip_attachment_remover'
ActiveRecord::Base.send(:include, PaperclipAttachmentRemover)
