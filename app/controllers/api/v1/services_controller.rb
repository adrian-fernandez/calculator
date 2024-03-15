# frozen_string_literal: true

module Api
  module V1
    class ServicesController < ApplicationController
      before_action :decode_plus_signs_in_op, only: [:calc]

      def calc
        result = CalculatorService.call(data: params[:expression])
        presenter = CalculatorPresenter.new(object: result, expression: params[:expression])

        render_result(result, presenter)
      end

      def country_guess
        result = TimeMeter.call do
          CountryGuessService.call(data: params[:name])
        end

        presenter = CountryGuessPresenter.new(
          object: result[:result],
          requested_name: params[:name],
          time_processed: result[:duration]
        )

        render_result(result[:result], presenter)
      end

      private

      def decode_plus_signs_in_op
        params[:expression]&.tr!(' ', '+')
      end

      def render_result(result, presenter)
        status = result.valid ? 200 : 422

        render json: presenter.call, status:
      end
    end
  end
end
