# Redis prefers speed to security, and relies on being run in trusted environments. Heroku adds some security by
# running Redis behind Stunnel in production-tier dynos, which creates an SSL tunnel between applications and hosted
# Redis instance. When hosting a container we can't use the Stunnel buildpack, and must connect directly
#
# see https://devcenter.heroku.com/articles/securing-heroku-redis
$redis = if ENV["REDIS_USE_STUNNEL"].present?
  url = URI.parse(ENV["REDIS_URL"])
  url.scheme = "rediss"
  url.port = Integer(url.port) + 1
  Redis.new(url: url, driver: :ruby, ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE })
else
  Redis.new(url: ENV["REDIS_URL"])
end
