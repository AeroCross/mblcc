module Validator
  class BaseValidator
    class InvalidAccountNumberError < StandardError; end

    class InvalidBalanceError < StandardError; end

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
