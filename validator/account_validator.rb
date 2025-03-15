require_relative "base_validator"

module Validator
  class AccountValidator < BaseValidator
    attr_accessor :errors

    def initialize
      @errors = []
    end

    def validate!(account_record)
      if !balance_valid?(account_record.balance)
        message = "Starting balance for account #{account_record.account_number} must be greater than zero. Balance: #{account_record.balance}"
        errors.push(message)
        raise InvalidBalanceError, message
      end

      if !account_number_valid?(account_record.account_number)
        message = "Invalid format for account number \"#{account_record.account_number}\". Needs to be a 16-character string of digits 0-9."
        errors.push(message)
        raise InvalidAccountNumberError, message
      end
    end
  end
end
