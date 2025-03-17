require_relative "../../model/transaction"
require_relative "../../factory/model/transaction"

RSpec.describe ::Model::Transaction do
  subject(:transaction_model) { ::Model::Transaction }

  describe "#new" do
    let(:transaction_data) {
      Factory::Model::Transaction
        .generate(10)
        .shuffle!
    }

    let(:transactions) { subject.new(transaction_data) }

    it "loads transactions" do
      expect(transactions.all.length).to eq(10)
    end

    context "invalid scenarios" do
      let(:amount) { "200.50" }
      let(:to) { nil }
      let(:from) { nil }

      before(:each) do
        transaction_data.push(Factory::Model::Transaction.build(to: to, from: from, amount: amount))
      end

      context "when one of the amounts is zero (i.e balance won't be modified)" do
        let(:amount) { "0" }

        it "skips transaction" do
          expect(transactions.all.length).to eq(10)
        end
      end

      context "when the amount is negative (i.e attempts to withdraw)" do
        let(:amount) { "-15.20" }

        it "skips transaction" do
          expect(subject.new(transaction_data).all.length).to eq(10)
        end
      end

      context "when the source and destination accounts are the same" do
        let(:to) { Factory::Model::Transaction.generate_random_account_number }
        let(:from) { to }

        it "skips transaction" do
          expect(transactions.all.length).to eq(10)
        end
      end
    end
  end
end
