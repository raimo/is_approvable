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
      ActivityNotifier.deliver_application_for_approval(self)
    end
  end

end
ActiveRecord::Base.send(:extend, IsApprovable)

module ApprovesModels
  def approves_models
    include InstanceMethods
  end

  module InstanceMethods
    def approve
      eval(params[:controller].classify).find(params[:id]).update_attribute(:approved, true)
      redirect_to '/'
    end
    def unapprove
      eval(params[:controller].classify).find(params[:id]).update_attribute(:approved, false)
      redirect_to '/'
    end
  end

end
ActionController::Base.send(:extend, ApprovesModels)

