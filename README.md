# DatabaseLogic

Right, database layer logic is a big no-no in the Rails community.

But if you're building something serious, sooner or later you will need to break the rules - none of these frameworks are silver bullets despite the almost-fanatism behind their doctrines. 

There are several gems out there that come up with different solutions, yet they are very opinionated and sometimes get in the way. This simple gem tries to solve these issues with a few simple tasks and generators.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'database_logic'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install database_logic


## Quick howto

`rails g database_logic:view users_full`

`rails g database_logic:trigger MyAwesomeTrigger after insert users` 

`rails g database_logic:function SuperFunc`

`rails g database_logic:procedure MegaProcedure`

`rails g database_logic:event Daily 24 hour`


## Usage / walkthrough

First, let's try creating a view. For this, we will need an User model, as follows:

`rails g model User first_name:string last_name:string balance_in_cents:integer address:string city:string`

this will generate:

```ruby
# app/db/migrate/20210619153721_create_users.rb
class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
        t.string :first_name
        t.string :last_name
        t.integer :balance_in_cents
        t.string :address
        t.string :city
        t.timestamps
    end
  end
end
```

So far so good! Let's apply our changes:

`rails db:migrate`

Now let's assume we want a view that shows users' first name and last name merged into `full_name`, so we will use the view generator to create our first view file:

`rails g database_logic:view users_full`

This will generate:

```
# app/sql/views/20210519160509_users_full.sql
# ... some default garbage from a template...
```
Let us edit this file, delete the gibberish and add our view SQL:

```
create or replace view [DB].users_full as
 select concat(first_name, ' ', last_name) as full_name, balance_in_cents/100 as balance, concat(address, ' ', city) as full_address from [DB].users;
```

After saving the SQL file let's apply our changes:

`rake database_logic:views:create`

```
MariaDB [app_dev]> describe users_full;
+--------------+---------------+------+-----+---------+-------+
| Field        | Type          | Null | Key | Default | Extra |
+--------------+---------------+------+-----+---------+-------+
| full_name    | varchar(511)  | YES  |     | NULL    |       |
| balance      | decimal(14,4) | YES  |     | NULL    |       |
| full_address | varchar(511)  | YES  |     | NULL    |       |
+--------------+---------------+------+-----+---------+-------+
```

So far so good! At this point we might not want to have to run a rake task after each addition/change, so we want to .enhance the db:migrate task as follows:

```ruby
# lib/tasks/dblogic.rake

# on drop, drop SQL logic too
Rake::Task["db:drop"].enhance ["database_logic:drop"]

# on migration, re-create all SQL logic
Rake::Task["db:migrate"].enhance do
    Rake::Task["database_logic:recreate"].execute
end
```

But in real life, users have Transactions, so let's also create a Transaction model, as follows:

`rails g model Transaction user_id:integer amount_in_cents:integer kind:string`

this will generate:

```ruby
# app/db/migrate/20210619153732_create_transactions.rb
class CreateTransactions < ActiveRecord::Migration[6.0]
  def change
    create_table :transactions do |t|
        t.integer :user_id
        t.integer :amount_in_cents
        t.string :kind
      t.timestamps
    end
  end
end
```

And now, let's say we want our "balance" column to update _on the database side_ whenever we add Transactions. Without bloating our models with AR hooks/callbacks, and without database inconsistencies caused by the delays that plague db to app communication, that is.

First, we will create a trigger:

`rails g database_logic:trigger after insert transactions`

This will generate:
```
# app/sql/triggers/20213619173650_update_balance.sql
# ... some default garbage from a template...
```

We want to edit this file and add our trigger SQL:
```
create trigger update_balance after insert on [DB].transactions
for each row
    begin
        update users set balance_in_cents = balance_in_cents+NEW.amount_in_cents;
    end;
```

Finally, let's migrate: `rake db:migrate`. Our `rake db:migrate` enhancement automagically ran our SQL so we're good to go!

Let's try it out, in a rails console (`rails c`) 
```
2.5.5 :007 > User.first.balance_in_cents;
 => 0

2.5.5 :008 > Transaction.create(user_id: 1, amount_in_cents: 123, kind: "Transfer")
 => #<Transaction id: 81, user_id: 1, amount_in_cents: 123, kind: "Transfer", created_at: "2021-06-19 18:05:32", updated_at: "2021-06-19 18:05:32">
2.5.5 :009 > User.first.balance_in_cents;
  User Load (1.6ms)  SELECT `users`.* FROM `users` ORDER BY `users`.`id` ASC LIMIT 1
 => 123
```

Noice! 

Functions, procedures and events work in the same manner, you can go on and play with them on your own!

## Gotchas

You may want to use alphanumeric names for your SQL function/... names, the generators try normalizing them but just in case, try not to use names like _$up'erk3wl ha{er#name_ or similar gibberish.


## Roadmap
* specs
* a way to select which database to use, when there are multiple


## Contributing

Bug reports are welcome and pull requests are more than welcome on GitHub at https://github.com/freecrap/database_logic. Contributors are expected to adhere to the [code of conduct](https://github.com/freecrap/database_logic/blob/master/CODE_OF_CONDUCT.md). I haven't edited this file yet so until I do please don't be naughty.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
