require_relative "../../model/account"
require_relative "../random_generators"

AccountRecord = Model::Account::Record

module Factory
  module Model
    class Account
      extend RandomGenerators

      attr_reader :accounts

      class << self
        # Randomly generates accounts with balances.
        def generate(number_of_accounts = 1)
          new(number_of_accounts).accounts
        end

        # Returns a single account with the arguments passed, and fills everything else randomly.
        def build(account_number: nil, balance: nil)
          account = AccountRecord.new

          account.account_number = if account_number.nil?
            generate_random_account_number
          else
            account_number
          end

          account.balance = if balance.nil?
            generate_random_balance
          else
            balance
          end

          account.to_a
        end
      end

      def initialize(number_of_accounts = 1)
        @accounts = []
        used_account_numbers = Set.new

        # Generate `number_of_accounts` ensuring that account numbers are always unique.
        number_of_accounts.times do
          account = self.class.build
          account_number = account[0]

          loop do
            unless used_account_numbers.include?(account_number)
              used_account_numbers.add(account_number)
              break
            end
          end

          accounts.push(account)
        end
      end
    end
  end
end
