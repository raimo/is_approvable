class RecordApprovalMailer < ActionMailer::Base
  def self.activity_recipients=(recipients)
    @@activity_recipients = recipients
  end
  def self.root_path=(application_root)
    @@root_path = application_root 
  end

  self.template_root = "#{File.dirname(__FILE__)}/../views"

  def application_for_approval(model)
    subject    "New #{model.class.name} record needs a confirmation"
    recipients @@activity_recipients
    sent_on    Time.now

    body       :url => @@root_path + url_for(:only_path => true, :controller => model.class.name.to_s.underscore.pluralize, :action => :approve, :id => model.to_param),
               :model => model, :reported_fields => model.class.reported_fields_on_approval

  end

end
