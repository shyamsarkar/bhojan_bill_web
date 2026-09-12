module Api
  module V1
    class TokensController < ApplicationController
      skip_before_action :authenticate_request!, only: %i[refresh]
      skip_before_action :set_current_context, only: %i[refresh]

      def refresh
        render json: TokenService.rotate(params.require(:refresh_token))
      rescue ActionController::ParameterMissing
        render json: { error: 'refresh_token is required' }, status: :bad_request
      rescue JwtService::InvalidToken
        render json: { error: 'Invalid or expired refresh token' }, status: :unauthorized
      end

      def destroy
        TokenService.revoke(params[:refresh_token]) if params[:refresh_token].present?
        head :no_content
      end

      def switch_tenant
        membership = current_user.memberships.find_by(tenant_id: params.require(:tenant_id))
        return render json: { error: 'Access denied for selected tenant' }, status: :forbidden unless membership

        render json: TokenService.issue_for(membership)
      rescue ActionController::ParameterMissing
        render json: { error: 'tenant_id is required' }, status: :bad_request
      end
    end
  end
end
