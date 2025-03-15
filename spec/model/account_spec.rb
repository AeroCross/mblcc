require_relative "../../model/account"
require_relative "../../factory/model/account"

AccountFactory = Factory::Model::Account

RSpec.describe Model::Account do
  subject(:account) { Model::Account }

  describe "#load" do
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
      account_data = [AccountFactory.build(account_number: account_number)]
      it "raises a validation error because #{explanation}" do
        expect { subject.new(account_data) }.to raise_error(Model::Account::InvalidAccountNumberError)
      end
    end

    it "prevents loading negative balances" do
      account_data = [AccountFactory.build(balance: "-15.20")]
      expect { subject.new(account_data) }.to raise_error(Model::Account::InvalidBalanceError)
    end

    it "prevents loading duplicate account numbers" do
      duplicate_account_number = AccountFactory.generate_random_account_number
      account_data = [
        AccountFactory.build(account_number: duplicate_account_number),
        AccountFactory.build(account_number: duplicate_account_number)
      ]

      expect { subject.new(account_data) }.to raise_error(Model::Account::DuplicateAccountError)
    end
  end

  describe "#transact" do
    it "processes transactions"
    it "prevents a balance from going below zero"
    it "ensures that both account exist when transacting"
  end

  describe "#balance_for" do
    before(:each) do
      @accounts = Model::Account.new(AccountFactory.generate(10))
      @account = @accounts.sample
    end

    it "outputs the balance of an account as a formatted string with 2 decimal places" do
      expect(@accounts.balance_for(@account[:account_number].to_s))
        .to eq(@account[:balance].to_s("F"))
    end

    it "returns nil if the account is not found" do
      expect(@accounts.balance_for(1)).to eq(nil)
    end
  end
end
