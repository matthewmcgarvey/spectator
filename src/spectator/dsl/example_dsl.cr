require "./matcher_dsl"

module Spectator::DSL
  # Methods that are available inside test code (an `it` block).
  module ExampleDSL
    include MatcherDSL

    # Starts an expectation.
    # This should be followed up with `to` or `to_not`.
    # The value passed in will be checked
    # to see if it satisfies the conditions specified.
    #
    # This method should be used like so:
    # ```
    # expect(actual).to eq(expected)
    # ```
    # Where the actual value is returned by the system-under-test,
    # and the expected value is what the actual value should be to satisfy the condition.
    #
    # Multiple values can be checked, for instance:
    # ```
    # expect(actual1, actual2).to eq(expected)
    # ```
    # This will verify that both `actual1` and `actual2` equal `expected`.
    #
    # The short, one argument syntax used for passing methods to blocks can be used.
    # So instead of doing this:
    # ```
    # expect(subject.size).to eq(5)
    # ```
    # The following syntax can be used instead:
    # ```
    # expect(&.size).to eq(5)
    # ```
    # The method passed will always be evaluated on `#subject`.
    macro expect(*actual)
      # Loop over every "actual" to check - this is typically just one item.
      {% for item in actual %}
        ::Spectator::Expectations::ValueExpectationPartial.new({{item.stringify}}, {{item}})
      {% end %}
    end

    # Starts an expectation on a block of code.
    # This should be followed up with `to` or `to_not`.
    # The block passed in, or its return value, will be checked
    # to see if it satisfies the conditions specified.
    #
    # This method should be used like so:
    # ```
    # expect { raise "foo" }.to raise_error
    # ```
    # The block of code is passed along for validation to the matchers.
    #
    # The short, one argument syntax used for passing methods to blocks can be used.
    # So instead of doing this:
    # ```
    # expect(subject.size).to eq(5)
    # ```
    # The following syntax can be used instead:
    # ```
    # expect(&.size).to eq(5)
    # ```
    # The method passed will always be evaluated on `#subject`.
    macro expect(&block)
      {% if block.is_a?(Nop) %}
        {% raise "Argument or block must be provided to expect" %}
      {% end %}

      # Check if the short-hand method syntax is used.
      # This is a hack, since macros don't get this as a "literal" or something similar.
      # The Crystal compiler will translate `&.foo` to `{ |__arg0| __arg0.foo }`.
      # The hack used here is to check if it looks like a compiler-generated block.
      {% if block.args == ["__arg0".id] && block.body.is_a?(Call) && block.body.id =~ /^__arg0\./ %}
        # Extract the method name to make it clear to the user what is tested.
        # The raw block can't be used because it's not clear to the user.
        {% method_name = block.body.id.split('.').last %}
        # TODO: Maybe pass the subject in as __arg0 instead of prefixing with `subject.`.
        ::Spectator::Expectations::ValueExpectationPartial.new({{"#" + method_name}}, subject.{{method_name.id}})
      {% else %}
        # In this case, it looks like the short-hand method syntax wasn't used.
        # Just drop in the block as-is.
        ::Spectator::Expectations::ValueExpectationPartial.new({{block.body.stringify}}, {{block.body}})
      {% end %}
    end

    # Starts an expectation.
    # This should be followed up with `to` or `to_not`.
    # The value passed in will be checked
    # to see if it satisfies the conditions specified.
    #
    # This method is identical to `#expect`,
    # but is grammatically correct for the one-liner syntax.
    # It can be used like so:
    # ```
    # it expects(actual).to eq(expected)
    # ```
    # Where the actual value is returned by the system-under-test,
    # and the expected value is what the actual value should be to satisfy the condition.
    macro expects(*actual, &block)
      expect({{actual.splat}}) {{block}}
    end

    # Short-hand for expecting something of the subject.
    # These two are functionally equivalent:
    # ```
    # expect(subject).to eq("foo")
    # is_expected.to eq("foo")
    # ```
    macro is_expected
      expect(subject)
    end

    # Short-hand form of `#is_expected` that can be used for one-liner syntax.
    # For instance:
    # ```
    # it "is 42" do
    #   expect(subject).to eq(42)
    # end
    # ```
    # Can be shortened to:
    # ```
    # it is(42)
    # ```
    #
    # These three are functionally equivalent:
    # ```
    # expect(subject).to eq("foo")
    # is_expected.to eq("foo")
    # is("foo")
    # ```
    #
    # See also: `#is_not`
    macro is(expected)
      is_expected.to eq({{expected}})
    end

    # Short-hand, negated form of `#is_expected` that can be used for one-liner syntax.
    # For instance:
    # ```
    # it "is not 42" do
    #   expect(subject).to_not eq(42)
    # end
    # ```
    # Can be shortened to:
    # ```
    # it is_not(42)
    # ```
    #
    # These three are functionally equivalent:
    # ```
    # expect(subject).to_not eq("foo")
    # is_expected.to_not eq("foo")
    # is_not("foo")
    # ```
    #
    # See also: `#is`
    macro is_not(expected)
      is_expected.to_not eq({{expected}})
    end

    # Immediately fail the current test.
    # A reason can be passed,
    # which is reported in the output.
    def fail(reason : String)
      raise ExampleFailed.new(reason)
    end

    # ditto
    @[AlwaysInline]
    def fail
      fail("Example failed")
    end
  end
end
