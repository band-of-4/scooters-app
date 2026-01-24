Rails.application.config.session_store :redis_session_store,
  servers: {
    host: 'localhost',
    port: 6379,
    db: 0,
    namespace: 'sessions'
  },
  expire_after: 24.hours,
  key: '_scooters_app_session',
  threadsafe: true,
  secure: Rails.env.production?  # HTTPS только в production