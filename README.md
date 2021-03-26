😈 Insidious
----------

A simple and flexible ruby gem for managing daemons.

## Installation

Insidious is available on [RubyGems](https://rubygems.org/gems/insidious).

Install it manually:

```bash
gem install insidious
```

Or add it to your `Gemfile`:

```ruby
gem 'insidious', '~> 0.3'
```

## Usage

### Configuration

````ruby
insidious = new Insidious(
  :pid_file => '/path/where/the/pid/will/be/saved',
  :daemonize => true, # can be true or false but defaults to being true
)
````

### Start a daemon

````ruby
insidious = Insidious.new(:pid_file => '/tmp/insidious.pid')

insidious.start! do
  while true
    puts Time.now.utc
    sleep 1
  end
end
````

### Stop a daemon

````ruby
insidious = Insidious.new(:pid_file => '/tmp/insidious.pid')

insidious.start! { your_app }

insidious.stop!
````

### Restart a daemon

````ruby
insidious = Insidious.new(:pid_file => '/tmp/insidious.pid')

insidious.start! { your_app }

insidious.restart! { your_app }
````

### Check the status of a daemon

````ruby
insidious = Insidious.new(:pid_file => '/tmp/insidious.pid')

insidious.start! { your_app }

insidious.running? # => true

insidious.stop!

insidious.running? # => false
````

### Get the process id of a daemon

````ruby
insidious = Insidious.new(:pid_file => '/tmp/insidious.pid')

insidious.start! { your_app }

insidious.pid # This will read from /tmp/insidious.pid
````

### Credit

insidious is a fork of [fallen](https://github.com/inkel/fallen) by [@inkel](https://github.com/inkel) and a lot of credit for this goes to him.

### License

The MIT License (MIT)

Copyright (c) 2014 James White

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
