require_relative "../../model/transaction"
require_relative "../random_generators"

TransactionRecord = Model::Transaction::Record

module Factory
  module Model
    class Transaction
      extend RandomGenerators

      attr_reader :transactions

      class << self
        def build(from: nil, to: nil, amount: nil, record: false)
          transaction = TransactionRecord.new

          transaction.amount = if amount.nil?
            generate_random_amount
          else
            amount
          end

          transaction.from = if from.nil?
            generate_random_account_number
          else
            from
          end

          transaction.to = if to.nil?
            # Ensure transactions always have different `to` and `from` when generated randomly
            loop do
              transaction.to = generate_random_account_number
              if transaction.to != transaction.from
                break
              end
            end
          else
            to
          end

          if record
            return transaction
          end

          transaction.to_a
        end

        def generate(number_of_transactions = 1)
          new(number_of_transactions).transactions
        end
      end

      def initialize(number_of_transactions = 1)
        @transactions = []

        number_of_transactions.times do
          transactions.push(self.class.build)
        end
      end
    end
  end
end
