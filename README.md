<img src="https://rawgithub.com/queuetue/chawk-gem/master/lib/chawk/Jackdaw.svg" alt="Drawing" width="400px"/>


[![Gem Version](https://badge.fury.io/rb/chawk.png)](http://badge.fury.io/rb/chawk)
[![Build Status](https://travis-ci.org/queuetue/chawk-gem.svg)](https://travis-ci.org/queuetue/chawk-gem)
[![Dependency Status](http://img.shields.io/gemnasium/queuetue/chawk-gem.svg)](https://gemnasium.com/queuetue/chawk-gem)
[![Code Climate](http://img.shields.io/codeclimate/github/queuetue/chawk-gem.svg)](https://codeclimate.com/github/queuetue/chawk-gem)
[![License](http://img.shields.io/:license-mit-blue.svg)](http://doge.mit-license.org)

## Description
Chawk is a database agnostic time-series database written in Ruby.

It tracks points (Integers) and will eventually provide statistical and aggregate tools for numeric data.

This is the gem that powers the server, [Chawkolate](http://www.github.com/queuetue/chawkolate "Chawkolate at Github"). 

Docs at [Queuetue.com](http://queuetue.com/Chawk "queuetue.com")


## Installation

Add this line to your application's Gemfile:

    gem 'chawk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install chawk

## Using Chawk

Setup

    require 'chawk'
	ActiveRecord::Base.logger = Logger.new(STDOUT)
	ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

The first time using a new database (Like this sqlite memory one that is destroyed at program exit) you should call: 

	require "chawk/migration"
	CreateChawkBase.migrate :up
	File.open('./test/schema.rb', "w") do |file|
		ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
	end

Or, setup activerecord and manage migrations however you usually do.  (Rails will handle this for you, using the chawk-rails gem)

Chawk has a permissions model, which provides a framework for implementors to build a robust security model around, but it does not prevent implementors from overriding it.

Chawk's permissions begin with the Agent.  All Chawk data operations require an Agent.  This can be used as the main actor in your implementation code, or can be a proxy for your own User, etc through the foreign_id property.

    agent = Chawk::Models::Agent.where(name:"Steve Austin").first || Chawk::Models::Agent.new(name:"Steve Austin")

All data operations are performed through an Addr object, which requires an agent.

    addr = Chawk.addr(agent,"inventory:popcorn")

Chawk.add assumes you are requesting full permissions, but you can specifically request :read, :write, :admin, or :full, which will allow specific operations and deny others.

    addr = Chawk.addr(agent,"inventory:popcorn", :read)

Giving (or taking) permissions from an Addr can be done with the set_permissions method:

	addr.set_permissions(agent, read, write, admin)

Setting all three to false removes the Addr from the list of the agent's nodes.

Addrs can also be given public read and write permissions, which allow agents without relationships to the Addr to manipulate it. The methods set_public_read(bool) and set_public_write(bool) set and remove these public permissions.

The Addr object stores and protects points.  Points are integers and allow mathematical and statistical operations. 

	addr.add_points [10,9,8,7,6,5]
	addr.points.last
	=> #<Chawk::Models::Point ... @value=5>
	addr.points.last(2)
	=> [#<Chawk::Models::Point ... @value=6>, #<Chawk::Models::Point ... @value=5>]

Points can also use the increment and decrement operators

	addr.points.last
	=> #<Chawk::Models::Point ... @value=5>
	addr.points + 10
	addr.pointslast
	=> #<Chawk::Models::Point ... @value=15>

Addr can also return ranges from the past using the range method or the last method:

	ts = Time.now
	addr._insert_point(0,ts-1000)
	addr._insert_point(1,ts-1000)
	addr._insert_point(2,ts-1000)
	addr._insert_point(5,ts-800)
	addr._insert_point(8,ts-200)
	addr._insert_point(9,ts-10)
	addr.points_range(ts-1001,ts).length
	=> 6
	addr.points_range(ts-801,ts).length 
	=>3
	addr.points_range(ts-201,ts).length 
	=> 2
	addr.points_range(ts-11,ts).length 
	=> 1
	addr.points_range(ts-1001,ts-999).length
	=> 3

A Chawk::Models::Range object, (soon to be merged with the Chawk.range command) produces time-limited, quantized data sets prepared for viewing, with resolution to the quarter second (one beat).

    range = Chawk::Models::Range.create(start_ts:1085.0,stop_ts:1140.0,beats:1,parent_node:addr1)

This will return all data from the Addr parent_node in the range from timestamp 1085 to 1140, resampled to the quarter beat. (220 data points, no matter how many are actually present in the sample)  This will become a stable hidden node (accessable via Addr.ranges) and will automatically rebuild itself if data within it's range changes.

    range = Chawk::Models::Range.create(start_ts:1088.0,stop_ts:8100.0,beats:14400,parent_node:addr1)

This will return all data from the Addr parent_node in the range from timestamp 1085 to 8100, resampled to the quarter beat. (2 data points, no matter how many are actually present in the sample)

## Contributing

1. Fork it at [github](http://github.com/queuetue/chawk-gem/fork "Github")
2. Create your feature branch => `git checkout -b my-new-feature`
3. Commit your changes => `git commit -am 'Add some feature'`
4. Push to the branch => `git push origin my-new-feature`
5. Create new Pull Request

## Rights

Limor Fried, also known as Ladayada of adafruit industries has suggested these rights for Internet of Things creators.
They are published here to support fair and honest practices for data collection initiatives. [Original Link](http://www.nytimes.com/roomfordebate/2013/09/08/privacy-and-the-internet-of-things/a-bill-of-rights-for-the-internet-of-things)

* Open is better than closed; this ensures portability between Internet of Things devices.

* Consumers, not companies, own the data collected by Internet of Things devices.

* Internet of Things devices that collect public data must share that data.

* Users have the right to keep their data private.

* Users can delete or back up data collected by Internet of Things devices.

Chawk is designed with these ideals in mind.

## License

Copyright (c) 2014 Scott Russell (queuetue@gmail.com / queuetue.com)

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
