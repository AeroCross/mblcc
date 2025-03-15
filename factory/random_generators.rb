module Factory
  # Helper functions for factory creation.
  module RandomGenerators
    # Account numbers are always a 16-character string comprised of digits 0-9.
    def generate_random_account_number
      account_number = ""
      16.times do
        account_number.concat(rand(0...9).to_s)
      end
      account_number
    end

    # For the purposes of testing, account balances are a string from 0 to 100k with 2 decimal numbers.
    # In reality, account balances can be anything over 0, inclusive.
    # This emulates the values loaded from a CSV file or similar, and it should be converted by the Model.
    def generate_random_balance(probability_of_zero: 0.25)
      return "0.00" if rand < probability_of_zero
      format("%.2f", rand * 100000)
    end

    # Same as `generate_random_balance`, but the value can't be 0.
    def generate_random_amount
      format("%.2f", rand(0.01...0.99) * 100000)
    end
  end
end
