# The session cookie has no expiry by default, so it's a browser-session cookie: iOS/Android
# killing the backgrounded PWA process drops it, forcing a re-login even though nothing actually
# expired. Give it an explicit expiry so it persists across app restarts. Rails rewrites the
# cookie on every response, so this rolls forward with activity rather than being a hard cutoff.
Rails.application.config.session_store :cookie_store,
                                       key: '_wod_tracker_session',
                                       expire_after: 30.days,
                                       same_site: :lax
