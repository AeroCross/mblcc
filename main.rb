require "csv"
require_relative "model/account"
require_relative "model/transaction"

accounts_file = File.open("./data/mable_acc_balance.csv")
transactions_file = File.open("./data/mable_trans.csv")

parsed_accounts = CSV.parse(accounts_file)
parsed_transactions = CSV.parse(transactions_file)

accounts = Model::Account.new(parsed_accounts)
transactions = Model::Transaction.new(parsed_transactions)

if accounts.errors?
  puts "=======\n"
  puts "WARNING: There were issues loading some accounts:"
  accounts.errors.each_with_index do |error, index|
    puts "[#{index}]: #{error}"
  end
  puts "=======\n\n"
end

if transactions.errors?
  puts "=======\n"
  puts "WARNING: There were issues loading some transactions."
  transactions.errors.each_with_index do |error, index|
    puts "[#{index}]: #{error}"
  end
  puts "=======\n\n"
end

transactions.all.each do |transaction|
  id, record = transaction
  puts "Processing Transaction ##{id} from \"#{record.from}\" to \"#{record.to}\" $#{format("%.2f", record.amount)}"
  puts "========\n"
  puts "Current balance of source (#{record.from}): #{accounts.balance_for(record.from)}"
  puts "Current balance of destination (#{record.to}): #{accounts.balance_for(record.to)}"

  accounts.transact(record)

  puts "New balance of source (#{record.from}): #{accounts.balance_for(record.from)}"
  puts "New balance of destination (#{record.to}): #{accounts.balance_for(record.to)}"
  puts "----------\n\n"
end
