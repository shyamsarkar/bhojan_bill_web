# frozen_string_literal: true

class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  before_action :authenticate_request!
  before_action :set_current_context

  # CanCanCan
  rescue_from CanCan::AccessDenied do |exception|
    render json: { error: exception.message }, status: :forbidden
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { error: 'Resource not found' }, status: :not_found
  end

  protected

  attr_reader :current_membership

  def authenticate_request!
    token = request.headers['Authorization'].to_s[/\ABearer\s+(.+)\z/i, 1]
    raise JwtService::InvalidToken, 'Missing bearer token' if token.blank?

    payload = JwtService.decode(token)
    @current_membership = Membership.includes(:user, :tenant).find(payload.fetch(:membership_id))
    render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_membership.user.is_active?
  rescue KeyError, ActiveRecord::RecordNotFound, JwtService::InvalidToken
    render json: { error: 'Unauthorized' }, status: :unauthorized
  end

  # Optional: expose current ability explicitly (good practice)
  def current_ability
    @current_ability ||= Ability.new(current_user, Current.tenant)
  end

  def current_user
    current_membership&.user
  end

  private

  def set_current_context
    Current.user = current_user
    Current.membership = current_membership
    Current.tenant = Current.membership.tenant

    unless Current.tenant.active?
      render json: { error: 'Tenant inactive' }, status: :forbidden
      return
    end

    ActsAsTenant.current_tenant = Current.tenant
  end

  def current_tenant
    current_membership&.tenant
  end
end
