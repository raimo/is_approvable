class RecordApprovalMailer < ActionMailer::Base
  def self.activity_recipients=(recipients)
    @@activity_recipients = recipients
  end
  def self.root_path=(application_root)
    @@root_path = application_root 
  end

  self.prepend_view_path("#{File.dirname(__FILE__)}/../views")

  def application_for_approval(model)
    subject    "New #{model.class.name} record needs a confirmation"
    recipients @@activity_recipients
    sent_on    Time.now
    @reported_fields = model.class.reported_fields_on_approval
    @model = model
    @url = @@root_path + url_for(:only_path => true, :controller => model.class.name.to_s.underscore.pluralize, :action => :approve, :id => model.to_param)

  end

end
