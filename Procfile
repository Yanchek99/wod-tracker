web: bundle exec puma -p $PORT -C ./config/puma.rb
worker: bundle exec bin/jobs
# Review Apps are disposable, so reset them on each deploy; persistent apps only migrate.
release: if [ "$REVIEW_APP" = "true" ]; then bundle exec rails db:schema:load; else bundle exec rails db:migrate; fi
