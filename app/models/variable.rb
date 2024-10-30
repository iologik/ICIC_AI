# frozen_string_literal: true

# == Schema Information
#
# Table name: variables
#
#  id         :bigint           not null, primary key
#  key        :string
#  value      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Variable < ApplicationRecord
  def self.find_pair(key)
    Variable.where(key: key).first_or_create
  end
end
