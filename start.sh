#!/usr/bin/env sh
set -x

export APP_ENV=production

bundle exec ruby sweeper.rb &
bundle exec ruby app.rb -p ${APP_PORT}
