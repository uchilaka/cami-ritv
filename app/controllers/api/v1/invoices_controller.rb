# frozen_string_literal: true

module API
  module V1
    class InvoicesController < ApplicationController
      def search
        @query = Invoice.ransack(search_query.predicates)
        @query.sorts = search_query.sorters if search_query.sorters.any?
        # TODO: Break search query into:
        #   - search against invoice records (OR)
        #   - search against account association (OR)
        #   - search within user policy scope (AND)
        @invoices = policy_scope(@query.result(distinct: true)).reverse_order
      end

      private

      def search_query
        @search_query ||= InvoiceSearchQuery.new(invoice_search_params[:q], params: invoice_search_params)
      end

      def invoice_search_params
        return invoice_search_array_params if params[:mode] == 'array'

        invoice_search_hash_params
      end

      def invoice_search_hash_params
        params.permit(:q, :mode, f: {}, s: {})
      end

      def invoice_search_array_params
        params.permit(:q, :mode, f: %i[field value], s: %i[field direction])
      end
    end
  end
end
