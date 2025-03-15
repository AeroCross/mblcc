require "bigdecimal"
require_relative "base"
require_relative "../validator/account_validator"

module Model
  class Account < Base
    class DuplicateAccountError < StandardError; end

    Record = Struct.new("AccountRecord", :account_number, :balance) do
      def initialize(account_number: nil, balance: nil)
        self.account_number = account_number
        self.balance = balance
        super
      end

      def account_number=(account_number)
        self[:account_number] = account_number.to_s unless account_number.nil?
      end

      def balance=(balance)
        self[:balance] = BigDecimal(balance) unless balance.nil?
      end
    end

    def initialize(data, validator = Validator::AccountValidator.new)
      @data = data
      @validator = validator
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

    attr_reader :data, :validator
    attr_accessor :repo

    def load
      loaded_account_numbers = Set.new

      data.each do |account|
        account_number, balance = account
        account_record = Record.new(
          account_number: account_number,
          balance: balance
        )

        validator.validate!(account_record)

        if loaded_account_numbers.include?(account_record.account_number)
          raise DuplicateAccountError, "Account number \"#{account_record.account_number}\" found multiple times while loading. Aborting to avoid overwriting balances."
        end

        loaded_account_numbers.add(account_record.account_number)

        repo[account_record.account_number] = account_record
      end
    end
  end
end
