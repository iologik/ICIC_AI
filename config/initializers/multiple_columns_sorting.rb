# frozen_string_literal: true

module ActiveAdmin
  class ResourceController < BaseController
    module DataAccess
      # rubocop:disable Metrics/AbcSize
      def apply_sorting(chain)
        params[:order] ||= active_admin_config.sort_order || 'name_asc'
        params[:order] = params[:order] == '_desc' ? 'name_asc' : params[:order]

        orders = []
        params[:order].split('_and_').each do |fragment|
          order_clause = OrderClause.new(active_admin_config, fragment)
          orders << order_clause.to_sql if order_clause.valid?
        end

        if orders.empty?
          chain.reorder(params[:order]) # Use the default sort order if orders are empty
        else
          chain.reorder(orders.shift) # Use the first element in the orders array to set the sort order
        end
      end
      # rubocop:enable Metrics/AbcSize
    end
  end
end
