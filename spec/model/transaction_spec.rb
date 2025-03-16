require_relative "../../model/transaction"
require_relative "../../factory/model/transaction"
require_relative "../../validator/transaction_validator"
require "pry"

TransactionFactory = Factory::Model::Transaction

RSpec.describe Model::Transaction do
  subject(:account) { Model::Transaction }

  describe "#new" do
    it "loads transactions" do
      transaction_data = TransactionFactory.generate(10)

      expect(subject.new(transaction_data).all.length).to eq(10)
    end

    it "skips transactions if the amount is zero (i.e balance won't be modified)" do
      transaction_data = TransactionFactory.generate(10)
      transaction_data.push(TransactionFactory.build(amount: 0))
      transaction_data.shuffle!

      expect(subject.new(transaction_data).all.length).to eq(10)
    end

    it "prevents loading transactions if the amount is lower than zero (i.e attempts to withdraw)" do
      transaction_data = TransactionFactory.generate(10)
      transaction_data.push(TransactionFactory.build(amount: "-10.00"))
      transaction_data.shuffle!

      expect(subject.new(transaction_data).all.length).to eq(10)
    end

    it "prevents loading transactions if it will attempt to transact with itself (i.e accounts are the same)" do
      duplicate_account_number = TransactionFactory.generate_random_account_number
      transaction_data = TransactionFactory.generate(10)
      transaction_data.push(TransactionFactory.build(to: duplicate_account_number, from: duplicate_account_number))
      transaction_data.shuffle!

      expect(subject.new(transaction_data).all.length).to eq(10)
    end
  end
end
