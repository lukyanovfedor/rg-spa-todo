class InternalServerError < ApplicationError
  STATUS = 500

  DETAILS = {
    unexpected: 'Unexpected error while processing request'
  }
end