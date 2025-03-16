require_relative "../../model/account"
require_relative "../../factory/model/account"
require_relative "../../factory/model/transaction"

AccountFactory = Factory::Model::Account
TransactionFactory = Factory::Model::Transaction

RSpec.describe Model::Account do
  subject(:account) { Model::Account }

  describe "#new" do
    let(:account_data) { AccountFactory.generate(10) }
    let(:account) { subject.new(account_data) }

    it "loads accounts" do
      expect(account.all.length).to be(10)
    end

    context "invalid scenarios" do
      invalid_scenarios = [
        [12341324, "there are not enough characters (16 characters required)"],
        ["12341234123412341234", "there are too many characters (16 characters required)"],
        ["123A12341234I234", "there are mixed characters and numbers"],
        ["ASDFASDFASDFASDF", "there are no characters, just numbers"],
        # The following is an octal literal (starts with 0).
        # rubocop:disable Style/NumericLiteralPrefix
        [0123412341234134, "provided a 16-digit integer that starts with 0 (does not convert to 16 characters)"]
        # rubocop:enable Style/NumericLiteralPrefix
      ]

      invalid_scenarios.each do |scenario|
        account_number, explanation = scenario
        context "when #{explanation}" do
          it "prevents loading an account" do
            account_data.push(AccountFactory.build(account_number: account_number))

            expect(account.all.length).to eq(10)
          end
        end
      end
    end

    context "when balance is negative" do
      it "prevents loading an account" do
        account_data.push(AccountFactory.build(balance: "-15.20"))

        expect(account.all.length).to eq(10)
      end
    end

    context "when there are duplicate accounts" do
      it "prevents loading an account" do
        duplicate_account_number = AccountFactory.generate_random_account_number
        account_data.push(AccountFactory.build(account_number: duplicate_account_number))
        account_data.push(AccountFactory.build(account_number: duplicate_account_number))

        expect { subject.new(account_data) }.to raise_error(subject::DuplicateAccountError)
      end
    end
  end

  describe "#transact" do
    let(:source_account) { AccountFactory.build(balance: source_balance, record: true) }
    let(:destination_account) { AccountFactory.build(balance: destination_balance, record: true) }
    let(:account_data) { [source_account.to_a, destination_account.to_a] }
    let(:accounts) { subject.new(account_data) }

    let(:transaction) {
      TransactionFactory.build(
        from: source_account.account_number,
        to: destination_account.account_number,
        amount: transaction_amount,
        record: true
      )
    }

    context "when balances, amounts and accounts are all correct" do
      # "Correct" in this case means:
      #   1. Source balance has to be higher than destination balance
      #   2. Transaction amount can't be more than initial balance
      #   3. Accounts are different
      #   4. Accounts exist
      let(:source_balance) { "500.25" }
      let(:destination_balance) { "200.86" }
      let(:transaction_amount) { "100.12" }

      it "processes transaction successfully" do
        accounts.transact(transaction)
        expect(accounts.balance_for(source_account.account_number)).to eq("400.13")
        expect(accounts.balance_for(destination_account.account_number)).to eq("300.98")
      end
    end

    context "when the transaction amount is higher than the source balance" do
      let(:source_balance) { "10.40" }
      let(:destination_balance) { "200" }
      let(:transaction_amount) { "1499.99" }

      it "prevents a balance from going below zero by aborting the transaction" do
        accounts.transact(transaction)
        expect(accounts.balance_for(source_account.account_number)).to eq("10.40")
        expect(accounts.balance_for(destination_account.account_number)).to eq("200.00")
      end
    end

    context "when one of the accounts in the transaction does not exist" do
      let(:source_balance) { "1999" }
      let(:destination_balance) { "140.2" }
      let(:transaction_amount) { "125.33" }

      context "when the source account does not exist" do
        let(:transaction) {
          TransactionFactory.build(
            from: "nah",
            to: destination_account.account_number,
            amount: transaction_amount,
            record: true
          )
        }
        it "prevents the transaction from happening" do
          accounts.transact(transaction)

          expect(accounts.balance_for(source_account.account_number)).to eq("1999.00")
          expect(accounts.balance_for(destination_account.account_number)).to eq("140.20")
        end
      end

      context "when the destination account does not exist" do
        let(:transaction) {
          TransactionFactory.build(
            from: source_account.account_number,
            to: "yeah nah",
            amount: transaction_amount,
            record: true
          )
        }
        it "prevents the transaction from happening" do
          accounts.transact(transaction)

          expect(accounts.balance_for(source_account.account_number)).to eq("1999.00")
          expect(accounts.balance_for(destination_account.account_number)).to eq("140.20")
        end
      end
    end
  end

  describe "#balance_for" do
    let(:account_record) { AccountFactory.build(balance: balance, record: true) }
    let(:account_data) { [account_record.to_a] }
    let(:account) { subject.new(account_data) }

    context "when the balance is a string with 2 decimal places" do
      let(:balance) { "500.25" }
      it "outputs the balance of an account as a formatted string with 2 decimal places" do
        expect(account.balance_for(account_record.account_number)).to eq("500.25")
      end
    end

    context "when the balance is an integer" do
      let(:balance) { 600 }
      it "outputs the balance of an account as a formatted string with 2 decimal places" do
        expect(account.balance_for(account_record.account_number)).to eq("600.00")
      end
    end

    context "when the balance is a string with no decimal places" do
      let(:balance) { "15400" }
      it "outputs the balance of an account as a formatted string with 2 decimal places" do
        expect(account.balance_for(account_record.account_number)).to eq("15400.00")
      end
    end

    context "when the balance is a string with 1 decimal place" do
      let(:balance) { "239.2" }
      it "outputs the balance of an account as a formatted string with 2 decimal places" do
        expect(account.balance_for(account_record.account_number)).to eq("239.20")
      end
    end

    context "when the balance is a string with more than 2 decimal places" do
      let(:balance) { "344.13423" }
      it "outputs the balance of an account as a formatted string with 2 decimal places" do
        expect(account.balance_for(account_record.account_number)).to eq("344.13")
      end
    end

    context "when the account is not found" do
      let(:account_data) { AccountFactory.generate(10) }
      it "returns nil" do
        expect(account.balance_for("this ID does not and should never exist")).to eq(nil)
      end
    end
  end
end
