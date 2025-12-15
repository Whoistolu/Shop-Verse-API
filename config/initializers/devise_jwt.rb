Devise.setup do |config|
  config.jwt do |jwt|
    jwt.secret = Rails.application.credentials.devise_jwt_secret_key || ENV['DEVISE_JWT_SECRET_KEY']

    jwt.dispatch_requests = [
      ['POST', %r{^/login$}]
    ]

    jwt.revocation_requests = [
      ['DELETE', %r{^/logout$}]
    ]

    jwt.expiration_time = 30.minutes.to_i
  end
end
