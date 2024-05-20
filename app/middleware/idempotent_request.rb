# frozen_string_literal: true

class IdempotentRequest
  IDEMPOTENCY_HEADER = 'HTTP_IDEMPOTENCY_KEY'.freeze
  REDIS_IDEMPOTENCY_KEY_NAMESPACE = 'idempotency_key'
  IDEMPOTENCY_KEY_TTL = 60

  attr_reader :redis

  def initialize(app)
    @app = app
    @redis = REDIS
  end

  def call(env)
    idempotency_key = env[IDEMPOTENCY_HEADER]

    if idempotency_key.present?
      Rails.logger.info { "Detected request with idempotency key #{idempotency_key}" }
      action = get(idempotency_key)

      if action.present?
        Rails.logger.info { 'Successfully found recent idempotent action' }
        status = action[:status]
        headers = action[:headers]
        response = ActionDispatch::Response.create(status, headers, action[:response])
      else
        Rails.logger.info { 'Processing new idempotent action' }
        status, headers, response = @app.call(env)
        response_value = response.respond_to?(:body) ? response.body : response
        payload = payload(status, headers, response_value)
        set(idempotency_key, payload)
        Rails.logger.info { 'Idempotent action was successfully processed and stored' }
      end
      [status, headers, response]
    else
      @app.call(env)
    end
  end

  private

  def get(key)
    data = redis.hgetall(namespaced_key(key))
    return nil if data.blank?

    {
      status: data['status'],
      headers: Oj.load(data['headers']),
      response: data['response']
    }
  end

  def set(key, payload)
    redis.hmset(namespaced_key(key), *payload)
    redis.expire(namespaced_key(key), IDEMPOTENCY_KEY_TTL)
  end

  def payload(status, headers, response)
    [
      :status, status,
      :headers, Oj.dump(headers),
      :response, response
    ]
  end

  def namespaced_key(idempotency_key)
    "#{REDIS_IDEMPOTENCY_KEY_NAMESPACE}:#{idempotency_key}"
  end
end