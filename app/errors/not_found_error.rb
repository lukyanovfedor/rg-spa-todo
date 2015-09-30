class NotFoundError < ApplicationError
  STATUS = 404

  DETAILS = {
    not_found: 'Requested resource not found'
  }
end