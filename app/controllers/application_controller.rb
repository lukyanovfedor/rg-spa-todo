class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?

  unless Rails.application.config.consider_all_requests_local
    # rescue_from Exception, with: :handle_unexpected
    # rescue_from CanCan::AccessDenied, with: :handle_forbidden
    # rescue_from ActiveRecord::RecordInvalid, with: :handle_invalid_record
    # rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
    # rescue_from ActionController::RoutingError, with: :handle_not_found
    # rescue_from AASM::InvalidTransition, with: :handle_aasm
  end

  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :first_name
    devise_parameter_sanitizer.for(:sign_up) << :last_name
  end

  def handle_unexpected(ex)
    @exception = InternalServerError.new(:unexpected)
    @exception.set_backtrace ex.backtrace
    handle_exception
  end

  def handle_forbidden(ex)
    @exception = ForbiddenError.new(:not_allowed)
    @exception.set_backtrace ex.backtrace
    handle_exception
  end

  def handle_invalid_record(ex)
    @exception = BadRequestError.new(:invalid_input_data, ex.record)
    @exception.set_backtrace ex.backtrace
    handle_exception
  end

  def handle_not_found(ex)
    @exception = NotFoundError.new(:not_found)
    @exception.set_backtrace ex.backtrace
    handle_exception
  end

  def handle_aasm(ex)
    @exception = BadRequestError.from_state_machine(ex)
    @exception.set_backtrace ex.backtrace
    handle_exception
  end

  def handle_exception
    log_exception
    render_exception
  end

  def log_exception
    Rails.logger.error
    Rails.logger.error("#{@exception.status} #{@exception.code} #{@exception.title}")
    Rails.logger.error(@exception.details)
    @exception.backtrace.each { |l| Rails.logger.error(l) }
    Rails.logger.error
  end

  def render_exception
    render 'errors/show', status: @exception.status
  end
end
