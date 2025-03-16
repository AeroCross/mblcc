require_relative "base_validator"

module Validator
  class TransactionValidator < BaseValidator
    class InvalidTargetsError < BaseValidator::ValidationError; end
    attr_accessor :errors, :valid

    def initialize
      @errors = []
    end

    def valid?(transaction_record)
      begin
        validate!(transaction_record)
      rescue ValidationError
        return false
      end
      true
    end

    def validate!(transaction_record)
      if !amount_valid?(transaction_record.amount)
        message = "Transaction amount needs to be higher than 0"
        errors.push(message)
        raise InvalidAmountError, message
      end

      if !account_number_valid?(transaction_record.to) || !account_number_valid?(transaction_record.from)
        message = "Invalid format for account number (to: #{transaction_record.to}, from: #{transaction_record.from}). Needs to be a 16-character string of digits 0-9."
        errors.push(message)
        raise InvalidAccountNumberError, message
      end

      if !targets_valid?(transaction_record)
        message = "Transaction source needs to be different to its destination"
        errors.push(message)
        raise InvalidTargetsError, message
      end
    end

    private

    def amount_valid?(amount)
      # Unlike a balance, a transaction needs to be able to change a balance.
      # Therefore, it can't be 0, and can't be negative either since accounts do not withdraw from another.
      BigDecimal(amount) > 0
    end

    def targets_valid?(transaction_record)
      # An account can't transact with itself.
      transaction_record.to != transaction_record.from
    end
  end
end
