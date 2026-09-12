# backend/app/controllers/api/v1/users/sessions_controller.rb

module Api
  module V1
    module Users
      class SessionsController < ApplicationController
        skip_before_action :authenticate_request!
        skip_before_action :set_current_context

        def create
          user = User.find_by(email: params.dig(:user, :email)&.downcase || params[:email]&.downcase)
          password = params.dig(:user, :password) || params[:password]
          membership = membership_for(user)

          unless user&.valid_password?(password.to_s) && user.is_active? && membership
            render json: { error: 'Invalid email, password, or tenant' }, status: :unauthorized
            return
          end

          user.update_column(:last_login_time, Time.current)
          render json: TokenService.issue_for(membership).merge(
            user: user.slice(:id, :email, :first_name, :last_name, :is_active, :last_login_time),
            tenant: membership.tenant,
            membership: { id: membership.id, role: membership.role },
            must_change_password: user.must_change_password?
          ), status: :ok
        end

        def destroy
          TokenService.revoke(params[:refresh_token]) if params[:refresh_token].present?
          head :no_content
        end

        private

        def membership_for(user)
          return unless user

          tenant_id = params[:tenant_id] || params.dig(:user, :tenant_id) || request.headers['X-Tenant-ID']
          memberships = user.memberships.includes(:tenant)
          tenant_id.present? ? memberships.find_by(tenant_id: tenant_id) : memberships.first if memberships.one? || tenant_id.present?
        end
      end
    end
  end
end
