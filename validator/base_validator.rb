module Validator
  class BaseValidator
    class ValidationError < StandardError; end

    class InvalidAmountError < BaseValidator::ValidationError; end

    class InvalidAccountNumberError < ValidationError; end

    class InvalidBalanceError < ValidationError; end

    attr_reader :errors

    def initialize
      @errors = []
    end

    def valid?(record)
      begin
        validate!(record)
      rescue ValidationError
        return false
      end
      true
    end

    def validate!(record)
      raise NotImplementedError
    end

    def errors?
      errors.length > 0
    end

    # A valid account number is a 16-character string only containing digits 0-9.
    def account_number_valid?(account_number)
      account_number.match?(/^\d{16}$/)
    end

    # Any positive BigDecimal with 2 decimal points is valid.
    def balance_valid?(balance)
      BigDecimal(balance) >= 0
    end
  end
end
