require "bigdecimal"
require_relative "base"
require_relative "../validator/transaction_validator"

module Model
  class Transaction < Base
    Record = Struct.new("TransactionRecord", :from, :to, :amount) do
      def initialize(from: nil, to: nil, amount: nil)
        self.from = from
        self.to = to
        self.amount = amount
      end

      def from=(account_number)
        self[:from] = account_number.to_s unless account_number.nil?
      end

      def to=(account_number)
        self[:to] = account_number.to_s unless account_number.nil?
      end

      def amount=(amount)
        self[:amount] = BigDecimal(amount) unless amount.nil?
      end
    end

    def initialize(data, validator = Validator::TransactionValidator.new)
      @data = data
      @validator = validator
      @repo = {}
      load
    end

    private

    attr_reader :data, :validator
    attr_accessor :repo

    def load
      data.each_with_index do |transaction, index|
        from, to, amount = transaction
        transaction_record = Record.new(from: from, to: to, amount: amount)

        repo[index] = transaction_record if validator.valid?(transaction_record)
      end
    end
  end
end
