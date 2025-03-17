# Design Principles

I have documented some thoughts, decisions and assumptions in
[DESIGN.md](DESIGN.md). I encourage you to take a look if you're curious or
if you see something that you would have done differently.

# Challenge Instructions

Instructions are located in [INSTRUCTIONS.md](INSTRUCTIONS.md) for reference.
This is a Markdown version of the challenge doc provided in PDF.

# Requirements

This challenge has been developed and tested in the following environment:

- Mac OS 15.3 (Apple Sillicon)
- Ruby 3.4.2

## Installation

Be aware that the installation process may be different depending on your
environment (due to missing libraries, incompatible arch, etc.).

Reach out if you have issues running the app.

```
# Install ruby 3.4.2 with your version manager of choice
# I use mise: https://mise.jdx.dev/lang/ruby.html
mise use -g ruby@3.4

# Clone the repository
git clone git@github.com:AeroCross/mblcc.git

# Setup
cd mblcc
bundle install
ruby main.rb
```

# Tests

```
# Ensure you've `bundle install` and that rspec is in your $PATH
# Otherwise prefix with `bundle exec`
rspec
```

<details>

<summary>Results of running `rspec`</summary>

Your results will be _slightly_ different since the tests are ordered randomly.

```
Randomized with seed 31925

Model::Account
  #new
    loads accounts
    when balance is negative
      prevents loading an account
    when there are duplicate accounts
      prevents loading an account
    invalid scenarios
      when there are no characters, just numbers
        prevents loading an account
      when there are not enough characters (16 characters required)
        prevents loading an account
      when there are mixed characters and numbers
        prevents loading an account
      when there are too many characters (16 characters required)
        prevents loading an account
      when provided a 16-digit integer that starts with 0 (does not convert to 16 characters)
        prevents loading an account
  #transact
    when one of the accounts in the transaction does not exist
      when the destination account does not exist
        prevents the transaction from happening
      when the source account does not exist
        prevents the transaction from happening
    when the transaction amount is higher than the source balance
      prevents a balance from going below zero by aborting the transaction
    when balances, amounts and accounts are all correct
      processes transaction successfully
  #balance_for
    when the balance is a string with no decimal places
      outputs the balance of an account as a formatted string with 2 decimal places
    when the balance is a string with more than 2 decimal places
      outputs the balance of an account as a formatted string with 2 decimal places
    when the account is not found
      returns nil
    when the balance is a string with 2 decimal places
      outputs the balance of an account as a formatted string with 2 decimal places
    when the balance is a string with 1 decimal place
      outputs the balance of an account as a formatted string with 2 decimal places
    when the balance is an integer
      outputs the balance of an account as a formatted string with 2 decimal places

Model::Transaction
  #new
    loads transactions
    invalid scenarios
      when the amount is negative (i.e attempts to withdraw)
        skips transaction
      when one of the amounts is zero (i.e balance won't be modified)
        skips transaction
      when the source and destination accounts are the same
        skips transaction

Finished in 0.00689 seconds (files took 0.09926 seconds to load)
22 examples, 0 failures

Randomized with seed 31925
```

</details>
