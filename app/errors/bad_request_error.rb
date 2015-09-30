class BadRequestError < ApplicationError
  STATUS = 400

  DETAILS = {
    invalid_input_data: 'Validation error',
    invalid_transition: 'Invalid state transition'
  }

  def self.from_state_machine(ex)
    self::DETAILS[:invalid_transition] = ex.message
    self.new(:invalid_transition)
  end

  def initialize(code = nil, suspect = nil)
    super(code)
    set_validation_errors(suspect) if suspect
  end

  def set_validation_errors(suspect)
    suspect.errors.each do |field, msg|
      @messages << suspect.errors.full_message(field, msg)
    end
  end
end