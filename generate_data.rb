require "pry"
require "csv"
require_relative "factory/model/account_factory"
require_relative "factory/model/transaction_factory"

# BEGIN Script configuration
# How many accounts should there be?
NUMBER_OF_ACCOUNTS = 10

# What's the minimum and the maximum potential number of transactions per account?
MINIMUM_TRANSACTIONS_PER_ACCOUNT = 0
MAXIMUM_TRANSACTIONS_PER_ACCOUNT = 3
# END Script configuration

# ####
# Here be dragons!
# You're encouraged to use this generated data as a starting point.
# After running this script, edit the generated .csv file and mess with it.
# ####
TRANSACTION_RANGE_PER_ACCOUNT = MINIMUM_TRANSACTIONS_PER_ACCOUNT...MAXIMUM_TRANSACTIONS_PER_ACCOUNT

account_data = Factory::Model::AccountFactory.generate(NUMBER_OF_ACCOUNTS)
transaction_data = []

account_data.each do |account_number, balance|
  rand(TRANSACTION_RANGE_PER_ACCOUNT).times do
    transaction_data.push(Factory::Model::TransactionFactory.build(from: account_number, to: account_data.sample[0]))
  end
end

# Ensure that transactions don't happen sequentially, to introduce more chaos
transaction_data.shuffle!

# Intentially make some transactions bogus (like inexistent accounts, negative amounts, etc.)
# Bad "from"
first_random_index = rand(0..transaction_data.length - 1)
first_random_item = transaction_data[first_random_index]
transaction_data[first_random_index] = [
  "jajaja",
  first_random_item[1],
  first_random_item[2]
]

# Negative amount
second_random_index = rand(0..transaction_data.length - 1)
second_random_item = transaction_data[second_random_index]
transaction_data[second_random_index] = [
  second_random_item[0],
  second_random_item[1],
  -10
]

balances_path = "./data/generated_account_balances.csv"
File.write(balances_path, "")
File.open(balances_path, mode: "w") do |file|
  CSV.open(file, "w") do |csv|
    account_data.each do |account|
      csv << [account[0], format("%.2f", account[1].to_s)]
    end
  end
end

transactions_path = "./data/generated_transactions.csv"
File.write(transactions_path, "")
File.open(transactions_path, mode: "w") do |file|
  CSV.open(file, "w") do |csv|
    transaction_data.each do |transaction|
      csv << [transaction[0], transaction[1], format("%.2f", transaction[2].to_s)]
    end
  end
end
