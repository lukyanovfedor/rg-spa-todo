class ForbiddenError < ApplicationError
  STATUS = 403

  DETAILS = {
    not_allowed: 'Not allowed to perform this action'
  }
end