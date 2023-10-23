# Deployed

[![Gem Version](https://badge.fury.io/rb/deployed.svg)](https://badge.fury.io/rb/deployed)

Deployed is a web interface for the deployment library, [Kamal](https://kamal-deploy.org).

Here is a quick video demo: https://x.com/geetfun/status/1716109581619744781?s=20

## Requirements

Ruby on Rails

## Installation
Add this line to your application's Gemfile:

```ruby
group :development do
  gem 'kamal'
  gem 'deployed'
end
```

## Usage

Add the following to your app's routes file:

```ruby
Rails.application.routes.draw do
  if Rails.env.development? && defined?(Deployed)
    mount(Deployed::Engine => '/deployed')
  end

  # Your other routes...
end
```

Next, head to `http://localhost:3000/deployed`

## Development

Run `bin/setup` to bootstrap the development environment.

To run tests: `bundle exec rake app:test`. Currently there are no tests, but some will be added soon.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
