puts "MONKEYPATCHING!"

class PreMonkeypatchTest
  include Pact::Consumer::RackRequestHelper
end

# Make sure that the module and method are where we expect them to be,
# so that if the underlying impelementation changes, we get notified, rather
# than having an unexplained failure.
unless PreMonkeypatchTest.new.respond_to?(:standardise_header, true)
  raise "Can't find method Pact::Consumer::RackRequestHelper.standardise_header to monkeypatch"
end

module Pact::Consumer::RackRequestHelper
  def standardise_header header
    header.gsub(/^HTTP_/, '').downcase
  end
end
