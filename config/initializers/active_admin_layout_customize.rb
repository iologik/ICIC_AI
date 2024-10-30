# frozen_string_literal: true

module ActiveAdmin
  module Views
    module Pages
      module IcicPageBuilder
        def build_other_accounts
          ids, names = current_admin_user.relevant_users_with_names
          div 'id' => 'relevant_user', 'class' => 'hide', 'data-ids' => ids.join(','), 'data-names' => names.join(',')
        end

        def build_admin_flag
          div 'id' => 'admin_flag', 'class' => 'hide' do
            current_admin_user.admin
          end
        end

        def build(*_args)
          set_attribute :lang, I18n.locale
          build_active_admin_head
          build_page
          build_admin_flag
          build_other_accounts
        end

        Base.prepend(IcicPageBuilder)
      end
    end
  end
end
