# Deployed

Deployed is a web interface for the deployment library, [Kamal](https://kamal-deploy.org).

## Requirements

Ruby on Rails

## Installation
Add this line to your application's Gemfile:

```ruby
group :development do
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

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
