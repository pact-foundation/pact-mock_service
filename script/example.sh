#!/usr/bin/env bash

# BEFORE SUITE start mock service
# invoked by the pact framework
bundle exec pact-mock-service service \
  --port 1234 \
  --consumer Foo \
  --provider Bar \
  --pact-dir ./tmp/pacts \
  --log ./tmp/bar_mock_service.log &
pid=$!

# BEFORE SUITE wait for mock service to start up
# invoked by the pact framework
while [ "200" -ne "$(curl -H "X-Pact-Mock-Service: true" -s -o /dev/null -w "%{http_code}" localhost:1234)" ]; do sleep 0.5; done

# uncomment this line to see the curl commands interleaved with the responses
# set -x

# BEFORE EACH TEST clear interactions from previous test
# invoked by the pact framework
curl -X DELETE -H "X-Pact-Mock-Service: true" localhost:1234/interactions

# BEFORE A TEST set up interaction(s) just for that test
# The contents of this would be written by the developer in the provided pact DSL for
# your language eg. mockService.given(...).uponReceiving(...). ...
# This can be called mulitple times. Alternatively PUT could be used
# with a body of `{interactions: [...]}` which would negate the need to call DELETE.
curl -X POST -H "X-Pact-Mock-Service: true" -d@script/consumer-interaction.json localhost:1234/interactions

# IN A TEST execute interaction(s)
# this would be done by the consumer code under test
curl localhost:1234/foo
echo ''

# AFTER EACH TEST verify interaction(s) took place
# This would be done explicitly by the developer or automatically by the framework,
# depending on the language
curl -H "X-Pact-Mock-Service: true" localhost:1234/interactions/verification

# AFTER SUITE
# write pact
# this would be invoked explictly by the developer or automatically framework,
# depending on the language
curl -X POST -H "X-Pact-Mock-Service: true" -H "Content-Length: 0" localhost:1234/pact

# AFTER SUITE stop mock service
# this would be invoked by the test framework
kill -2 $pid

while [ kill -0 $pid 2> /dev/null ]; do sleep 0.5; done

echo ''
echo 'FYI the mock service logs are:'
cat ./tmp/bar_mock_service.log