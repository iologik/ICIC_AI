# frozen_string_literal: true

# == Schema Information
#
# Table name: post_images
#
#  id         :integer          not null, primary key
#  file       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PostImage < ApplicationRecord
  # attr_accessible :file

  mount_uploader :file, PostImageUploader
end
