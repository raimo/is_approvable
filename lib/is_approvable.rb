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
      base.send(:named_scope, :approved, { :approved => true })
    end

    def deliver_approval_application
      RecordApprovalMailer.deliver_application_for_approval(self)
    end
  end

end
ActiveRecord::Base.send(:extend, IsApprovable)

module ApprovesModels
  def approves_model(model_class=nil)
    define_method(:approvable_model_class) do
      (model_class || Kernel.const_get(params[:controller].classify))
    end
    include InstanceMethods
  end

  module InstanceMethods
    def self.included(base)
      base.send(:before_filter, :set_the_current_request_host)
    end

    def approve
      approvable_model_class.find(params[:id]).update_attribute(:approved, true)
      redirect_to '/'
    end
    def unapprove
      approvable_model_class.find(params[:id]).update_attribute(:approved, false)
      redirect_to '/'
    end

    private
    def set_the_current_request_host
      RecordApprovalMailer.root_path = root_url.gsub(/\/$/,'')
    end
  end

end
ActionController::Base.send(:extend, ApprovesModels)

