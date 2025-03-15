module Factory
  module Model
    class Account
      attr_reader :accounts

      class << self
        # Account numbers are always a 16-character string comprised of digits 0-9.
        def generate_random_account_number
          account_number = ""
          16.times do
            account_number.concat(rand(0...9).to_s)
          end
          account_number
        end

        # For the purposes of testing, account balances are a string from 0 to 100k with 2 decimal numbers.
        # This emulates the values loaded from a CSV file or similar, and it should be converted by the Model.
        def generate_random_balance
          format("%.2f", rand * 100000)
        end

        # Randomly generates accounts with balances.
        # Returns an array of arrays containing a 16-character account number and its balance.
        def generate(number_of_accounts = 1)
          new(number_of_accounts).accounts
        end

        # Returns a single account with the arguments passed, and fills everything else randomly.
        def build(account_number: nil, balance: nil)
          account = []
          if account_number.nil?
            account.push(Account.generate_random_account_number)
          else
            account.push(account_number)
          end

          if balance.nil?
            account.push(Account.generate_random_balance)
          else
            account.push(balance)
          end

          account
        end
      end

      def initialize(number_of_accounts = 1)
        @accounts = []
        used_account_numbers = Set.new

        # Generate `number_of_accounts` ensuring that account numbers are unique.
        number_of_accounts.times do
          account_number = 0
          loop do
            account_number = Account.generate_random_account_number
            if !used_account_numbers.include?(account_number)
              used_account_numbers.add(account_number)
              break
            end
          end
          @accounts.push([account_number, Account.generate_random_balance])
        end
      end
    end
  end
end
