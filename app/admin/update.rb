# frozen_string_literal: true

ActiveAdmin.register Update do
  permit_params :investment_id,
                :title,
                :body,
                :email_sub_investor

  menu priority: 6

  filter :investment, as: :select, collection: proc {
                                                 if current_admin_user.admin
                                                   Investment.find(Post.pluck(:investment_id))
                                                 else
                                                   Investment.find(current_admin_user.sub_investments.pluck(:investment_id) & Post.pluck(:investment_id))
                                                 end
                                               }

  config.sort_order = 'id_desc'
  config.batch_actions = false
  config.per_page = 10

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}

  sidebar('Latest Updates', only: [:index], id: 'blank_space_panel') do
    ul id: 'latest_posts' do
      Update.latest_updates_by_user(current_admin_user).each do |post|
        li do
          link_to post.title, admin_update_path(post.id)
        end
      end
    end
  end

  scope :all_updates, default: true

  controller do
    skip_before_action :verify_authenticity_token, only: :upload
    before_action :set_admin_user_id, only: :index

    private

    def set_admin_user_id
      Thread.current['user'] = current_admin_user
    end
  end

  collection_action :upload, method: :post do
    image = PostImage.create(file: params[:file])
    render json: { path: image.file_url, error: false }
  end

  # rubocop:disable Rails/OutputSafety
  index as: :blog, download_links: false do
    title :title # Calls #my_title on each resource
    body :body do |post| # Calls #my_body on each resource
      div class: 'update-post' do
        post.body.html_safe
      end
    end
  end

  # form do |f|
  #  f.inputs  do
  #    f.input :investment
  #    f.input :title
  #    f.input :body, input_html: { class: 'tinymce_editor' }
  #  end
  #
  #  f.actions
  # end

  form partial: 'form'

  show do
    attributes_table do
      row :investment
      row :title
      row :body do |post|
        post.body.html_safe
      end
      row :created_at
    end
  end
  # rubocop:enable Rails/OutputSafety
end
