#!/bin/sh
set -e
bundle exec bump ${1:-minor} --no-commit
bundle exec rake generate_changelog
git add CHANGELOG.md lib/pact/mock_service/version.rb
git commit -m "chore(release): version $(ruby -r ./lib/pact/mock_service/version.rb -e "puts Pact::MockService::VERSION")" && git push
bundle exec rake release
