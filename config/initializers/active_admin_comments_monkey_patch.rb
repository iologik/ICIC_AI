# frozen_string_literal: true

module ActiveAdmin
  module Comments
    module Views
      class Comments
        # Had to change .include(:author) to .preload(:author) because it's polymorphic
        def build(resource)
          return unless authorized?(ActiveAdmin::Auth::READ, ActiveAdmin::Comment)

          @resource = resource
          @comments = active_admin_authorization.scope_collection(ActiveAdmin::Comment.find_for_resource_in_namespace(
            resource, active_admin_namespace.name
          ).preload(:author).page(params[:page]))
          super(title, for: resource)
          build_comments
        end
      end
    end
  end
end
