module IsApprovable
  def is_approvable(*opts)
    @reported_fields_on_approval = (opts.empty? ? [ :id, :created_at ] : opts )
    include InstanceMethods
    extend ClassMethods
  end

  module ClassMethods
    def reported_fields_on_approval
      @reported_fields_on_approval
    end
  end

  module InstanceMethods
    def self.included(base)
      base.send(:after_create, :deliver_approval_application)
    end

    def deliver_approval_application
      RecordApprovalMailer.deliver_application_for_approval(self)
    end
  end

end
ActiveRecord::Base.send(:extend, IsApprovable)

module ApprovesModels
  def approves_model(model_class=nil)
    @approvable_model_class = model_class || Kernel.const_get(self.name.classify)
    include InstanceMethods
  end

  module InstanceMethods
    def approve
      @@approvable_model_class.find(params[:id]).update_attribute(:approved, true)
      redirect_to '/'
    end
    def unapprove
      @@approvable_model_class.find(params[:controller].classify).find(params[:id]).update_attribute(:approved, false)
      redirect_to '/'
    end
  end

end
ActionController::Base.send(:extend, ApprovesModels)

