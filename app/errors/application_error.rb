class ApplicationError < StandardError
  attr_reader :status, :code, :details, :title, :messages

  def initialize(code = nil)
    @title = self.class.to_s
    @code = code.to_s.upcase if code
    @details = self.class::DETAILS[code] if code
    @status = self.class::STATUS
    @messages = []
  end
end