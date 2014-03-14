# Chawk


[![Gem Version](https://badge.fury.io/rb/chawk.png)](http://badge.fury.io/rb/chawk)
[![Build Status][BS img]][Build Status]
[![Dependency Status][DS img]][Dependency Status]
[![Code Climate][CC img]][Code Climate]

[Build Status]: https://travis-ci.org/queuetue/chawk-gem
[travis pull requests]: https://travis-ci.org/queuetue/chawk-gem/pull_requests
[Dependency Status]: https://gemnasium.com/queuetue/chawk-gem
[Code Climate]: https://codeclimate.com/github/queuetue/chawk-gem

[BS img]: https://travis-ci.org/queuetue/chawk-gem.png
[DS img]: https://gemnasium.com/queuetue/chawk-gem.png
[CC img]: https://codeclimate.com/github/queuetue/chawk-gem.png
[CS img]: https://coveralls.io/repos/queuetue/chawk/badge.png?branch=master

## Description
Chawk is a database agnostic time-series database written in Ruby.

It tracks both both points (Integers) and values (String) in seperate datastores, and will eventually provide statistical and aggregate tools for numeric data.

This is the gem that powers the soon-to-be server, chawk-server

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
    Chawk.setup 'sqlite::memory:'

DO NOT DO THIS ON AN EXISTING DATABASE, but the first time using a new database (Like this sqlite memory one that is destroyed at program exit) you should call: 

    DataMapper.auto_upgrade!

All Chawk data operations require an Agent.  This can be used as the main actor in your code, or can be a proxy for your own User, etc through the foreign_id property.

    agent = Chawk::Models::Agent.first(name:"Steve Austin") || Chawk::Models::Agent.new(name:"Steve Austin")

All data operations are performed through an Addr object.

    addr = Chawk.addr(agent,"inventory/popcorn")

The Addr object has two store objects - values and points.  **Points** are integers and allow mathematical and statistical operations. **Values** are strings and are intended for storing informational or serialized time series data.:

    addr.values << "This is a test."
    addr.values.last
    =>  #<Chawk::Models::Value @id=...
    		@observed_at=... 
			@recorded_at=#<DateTime: ...> 
			@meta=nil 
			@value="This is a test." 
			@node_id=... 
			@agent_id=...>

	addr.values << ["AND","SO","IS","THIS"]
    addr.values.last
	 => #<Chawk::Models::Value ... @value="THIS">
	addr.values.last(10)
	=> [#<Chawk::Models::Value ... @value="This is a test.">, 
		#<Chawk::Models::Value ... @value="AND">, 
		#<Chawk::Models::Value ... @value="SO">, 
		#<Chawk::Models::Value ... @value="IS">, 
		#<Chawk::Models::Value ... @value="THIS">]

Addr can also return ranges from the past using the range method or the last method:

	addr.values.range(Time.now-2000,Time.now-1000)
	=> [#<Chawk::Models::Value ... @value="ROCK">, 
		#<Chawk::Models::Value ... @value="AROUND">]

	addr.values.since(Time.now-1000)
	=> [#<Chawk::Models::Value ... @value="THE.">, 
		#<Chawk::Models::Value ... @value="CLOCK">]

These same methods also work for points:

	addr.points << [10,9,8,7,6,5]
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

As well as max and min

	addr.points.max
	=> 15
	addr + 10
	addr.points.last
	=> 1


## Contributing

1. Fork it at [github](http://github.com/queuetue/chawk-gem/fork "Github")
2. Create your feature branch => `git checkout -b my-new-feature`
3. Commit your changes => `git commit -am 'Add some feature'`
4. Push to the branch => `git push origin my-new-feature`
5. Create new Pull Request

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
