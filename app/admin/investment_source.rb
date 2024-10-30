# frozen_string_literal: true

ActiveAdmin.register InvestmentSource do
  permit_params :name, :priority, :pin

  menu parent: 'Reference Tables'

  sidebar('title', only: %i(new edit create update), id: 'blank_space_panel') {}
end
