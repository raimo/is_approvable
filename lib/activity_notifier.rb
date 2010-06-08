class ActivityNotifier < ActionMailer::Base
  def self.activity_recipients=(recipients)
    @@activity_recipients = recipients
  end

  self.template_root = "#{File.dirname(__FILE__)}/../views"

  def application_for_approval(model)
    subject    "New #{model.class.name} record needs a confirmation"
    recipients @@activity_recipients
    sent_on    Time.now

    body       :url => url_for(:controller => model.class.name.to_s.underscore.pluralize, :action => :approve, :id => model.to_param),
               :model => model, :reported_fields => model.class.reported_fields_on_approval

  end

end
