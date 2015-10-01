class ApplicationController < ActionController::Base
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?

  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, with: :handle_unexpected
    rescue_from CanCan::AccessDenied, with: :handle_forbidden
    rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    rescue_from AASM::InvalidTransition, with: :handle_aasm
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
  end

  def handle_unexpected(ex)
    handle_exception(InternalServerError.new(:unexpected), ex)
  end

  def handle_forbidden(ex)
    handle_exception(ForbiddenError.new(:not_allowed), ex)
  end

  def handle_invalid_record(ex)
    handle_exception(BadRequestError.new(:invalid_input_data, ex.record), ex)
  end

  def handle_not_found(ex)
    handle_exception(NotFoundError.new(:not_found), ex)
  end

  def handle_aasm(ex)
    handle_exception(BadRequestError.from_state_machine(ex), ex)
  end

  def handle_exception(new, old)
    @exception = new
    @exception.set_backtrace old.backtrace
    @exception.original = old

    log_exception
    render_exception
  end

  def log_exception
    Rails.logger.error("#{@exception.original.message}")
    Rails.logger.error("#{@exception.status} #{@exception.code} #{@exception.title}")
    Rails.logger.error(@exception.details)
    @exception.backtrace.each { |l| Rails.logger.error(l) }
  end

  def render_exception
    render 'errors/show', status: @exception.status
  end
end
