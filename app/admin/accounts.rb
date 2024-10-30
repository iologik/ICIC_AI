# frozen_string_literal: true

ActiveAdmin.register Account do
  permit_params :name
  menu parent: 'Reference Tables'

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
