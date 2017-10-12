#!/usr/bin/env bash

# BEFORE SUITE start mock service
# invoked by the pact framework
bundle exec pact-stub-service script/foo-bar.json \
  --port 1234 \
  --log ./tmp/bar_stub_service.log &
pid=$!

# BEFORE SUITE wait for mock service to start up
# invoked by the pact framework
while [ "200" -ne "$(curl -H "X-Pact-Mock-Service: true" -s -o /dev/null  -w "%{http_code}" localhost:1234)" ]; do sleep 0.5; done

# IN A TEST execute interaction(s)
# this would be done by the consumer code under test
curl localhost:1234/foo
echo ''


# AFTER SUITE stop mock service
# this would be invoked by the test framework
kill -2 $pid

while [ kill -0 $pid 2> /dev/null ]; do sleep 0.5; done

echo ''
echo 'FYI the stub service logs are:'
cat ./tmp/bar_stub_service.log