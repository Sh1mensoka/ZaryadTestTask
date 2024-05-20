# frozen_string_literal: true

redis_host = ENV.fetch('REDIS_HOST')
redis_port = ENV.fetch('REDIS_PORT')

REDIS = Redis.new(host: redis_host, port: redis_port.to_i)
