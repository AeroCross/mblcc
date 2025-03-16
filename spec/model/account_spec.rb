require_relative "../../model/account"
require_relative "../../factory/model/account"
require_relative "../../factory/model/transaction"

AccountFactory = Factory::Model::Account
TransactionFactory = Factory::Model::Transaction

RSpec.describe Model::Account do
  subject(:account) { Model::Account }

  describe "#new" do
    it "loads accounts" do
      account_data = AccountFactory.generate(10)

      expect(subject.new(account_data).all.length).to be(10)
    end

    invalid_scenarios = [
      [12341324, "16 characters is the minimum length"],
      ["12341234123412341234", "16-characters is the maximum length"],
      ["123A12341234I234", "mixed characters and numbers are not allowed"],
      ["ASDFASDFASDFASDF", "only numbers are allowed"],
      # The following is an octal literal (starts with 0).
      # rubocop:disable Style/NumericLiteralPrefix
      [0123412341234134, "integers with 16 numbers that start with 0 do not convert to 16 character strings"]
      # rubocop:enable Style/NumericLiteralPrefix
    ]

    invalid_scenarios.each do |scenario|
      account_number, explanation = scenario
      account_data = AccountFactory.generate(10)
      account_data.push(AccountFactory.build(account_number: account_number))

      it "prevents loading an account number because #{explanation}" do
        expect(subject.new(account_data).all.length).to eq(10)
      end
    end

    it "prevents loading negative balances" do
      account_data = AccountFactory.generate(10)
      account_data.push(AccountFactory.build(balance: "-15.20"))

      expect(subject.new(account_data).all.length).to eq(10)
    end

    it "prevents loading duplicate account numbers" do
      duplicate_account_number = AccountFactory.generate_random_account_number
      account_data = AccountFactory.generate(10)

      account_data.push(AccountFactory.build(account_number: duplicate_account_number))
      account_data.push(AccountFactory.build(account_number: duplicate_account_number))

      expect { subject.new(account_data) }.to raise_error(subject::DuplicateAccountError)
    end
  end

  describe "#transact" do
    it "processes transactions" do
      source_account = AccountFactory.build(balance: "500.25", record: true)
      destination_account = AccountFactory.build(balance: "200.86", record: true)
      account_data = [source_account.to_a, destination_account.to_a]

      transaction = TransactionFactory.build(
        from: source_account.account_number,
        to: destination_account.account_number,
        amount: "100.12",
        record: true
      )

      accounts = subject.new(account_data)
      accounts.transact(transaction)

      expect(accounts.balance_for(source_account.account_number)).to eq("400.13")
      expect(accounts.balance_for(destination_account.account_number)).to eq("300.98")
    end

    it "prevents a balance from going below zero by aborting the transaction" do
      source_account = AccountFactory.build(balance: "10.40", record: true)
      destination_account = AccountFactory.build(balance: "200", record: true)
      account_data = [source_account.to_a, destination_account.to_a]

      transaction = TransactionFactory.build(
        from: source_account.account_number,
        to: destination_account.account_number,
        amount: "1499.99",
        record: true
      )

      accounts = subject.new(account_data)
      accounts.transact(transaction)

      expect(accounts.balance_for(source_account.account_number)).to eq("10.40")
      expect(accounts.balance_for(destination_account.account_number)).to eq("200.00")
    end

    it "ensures that both account exist when transacting" do
      source_account = AccountFactory.build(balance: "1999", record: true)
      destination_account = AccountFactory.build(balance: "140.2", record: true)
      account_data = [source_account.to_a, destination_account.to_a]

      transaction = TransactionFactory.build(
        from: "nah",
        to: destination_account.account_number,
        amount: "125.33",
        record: true
      )

      accounts = subject.new(account_data)
      accounts.transact(transaction)

      expect(accounts.balance_for(source_account.account_number)).to eq("1999.00")
      expect(accounts.balance_for(destination_account.account_number)).to eq("140.20")
    end
  end

  describe "#balance_for" do
    it "outputs the balance of an account as a formatted string with 2 decimal places" do
      account_record = AccountFactory.build(balance: "500.25")
      account_number = account_record[0]
      account_data = [account_record]
      account = subject.new(account_data)

      expect(account.balance_for(account_number)).to eq("500.25")
    end

    it "returns nil if the account is not found" do
      account_data = AccountFactory.generate(10)
      account = subject.new(account_data)

      expect(account.balance_for("this ID does not and should never exist")).to eq(nil)
    end
  end
end
