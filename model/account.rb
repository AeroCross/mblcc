require "bigdecimal"
require_relative "base"

module Model
  class Account < Base
    AccountRecord = Struct.new("AccountRecord", :account_number, :balance)

    class InvalidAccountNumberError < StandardError; end

    class DuplicateAccountError < StandardError; end

    class InvalidBalanceError < StandardError; end

    def initialize(data)
      @data = data
      @repo = {}
      load
    end

    # Takes a transaction and applies them to the account.
    def transact(transaction)
      raise NotImplementedError
    end

    def balance_for(account_number)
      find(account_number)&.balance&.to_s("F")
    end

    private

    attr_reader :data
    attr_accessor :repo

    def load
      loaded_account_numbers = Set.new

      data.each do |account|
        account_number = account[0].to_s
        balance = BigDecimal(account[1])

        if !balance_valid?(balance)
          raise InvalidBalanceError, "Starting balance for account #{account_number} must be greater than zero. Balance: #{balance}"
        end

        if !account_number_valid?(account_number)
          raise InvalidAccountNumberError, "Invalid format for account number \"#{account_number}\". Needs to be a 16-character string of digits 0-9."
        end

        if loaded_account_numbers.include?(account_number)
          raise DuplicateAccountError, "Account number \"#{account_number}\" found multiple times while loading. Aborting to avoid overwriting balances."
        end

        loaded_account_numbers.add(account_number)

        repo[account_number] = AccountRecord.new(
          account_number: account_number,
          balance: balance
        )
      end
    end

    def account_number_valid?(account_number)
      # A valid account number is a 16-character string only containing digits 0-9.
      account_number.to_s.match?(/^\d{16}$/)
    end

    def balance_valid?(balance)
      BigDecimal(balance) >= 0
    end
  end
end
