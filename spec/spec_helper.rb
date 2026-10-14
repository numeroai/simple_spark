require 'simple_spark'
require 'climate_control'

def with_modified_env(options, &block)
  ClimateControl.modify(options, &block)
end

# Surface deprecation warnings emitted by the gem or its runtime dependencies
# (json, excon) during the suite and fail the example that triggered them, so
# upcoming behavior changes in those gems are caught before they become errors.
Warning[:deprecated] = true if Warning.respond_to?(:[]=)

module CapturedWarnings
  RELEVANT = /json|excon|simple_spark/i

  def self.messages
    @messages ||= []
  end

  def warn(message, *args, **kwargs)
    CapturedWarnings.messages << message.to_s if message.to_s =~ RELEVANT
    super
  end
end

Warning.singleton_class.prepend(CapturedWarnings)

RSpec.configure do |config|
  config.before(:each) { CapturedWarnings.messages.clear }

  config.after(:each) do
    messages = CapturedWarnings.messages.dup
    expect(messages).to be_empty, "Unexpected warnings during example:\n#{messages.join("\n")}"
  end
end
