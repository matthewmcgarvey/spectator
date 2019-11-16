require "../matchers/match_data"
require "../source"
require "../test_expression"

module Spectator::Expectations
  # Stores part of an expectation (obviously).
  # The part of the expectation this type covers is the actual value and source.
  # This can also cover a block's behavior.
  struct ExpectationPartial(T)
    # The actual value being tested.
    # This also contains its label.
    getter actual : TestExpression(T)

    # Location where this expectation was defined.
    getter source : Source

    # Creates the partial.
    def initialize(@actual : TestExpression(T), @source : Source)
    end

    # Asserts that some criteria defined by the matcher is satisfied.
    def to(matcher) : Nil
      match_data = matcher.match(@actual)
      report(match_data)
    end

    def to(stub : Mocks::MethodStub) : Nil
      Harness.current.mocks.expect(@actual.value, stub.name)
      value = TestValue.new(stub.name, stub.to_s)
      matcher = if (arguments = stub.arguments?)
                  Matchers::ReceiveArgumentsMatcher.new(value, arguments)
                else
                  Matchers::ReceiveMatcher.new(value)
                end
      to_eventually(matcher)
    end

    # Asserts that some criteria defined by the matcher is not satisfied.
    # This is effectively the opposite of `#to`.
    def to_not(matcher) : Nil
      match_data = matcher.negated_match(@actual)
      report(match_data)
    end

    def to_not(stub : Mocks::MethodStub) : Nil
      value = TestValue.new(stub.name, stub.to_s)
      matcher = if (arguments = stub.arguments?)
                  Matchers::ReceiveArgumentsMatcher.new(value, arguments)
                else
                  Matchers::ReceiveMatcher.new(value)
                end
      to_never(matcher)
    end

    # ditto
    @[AlwaysInline]
    def not_to(matcher) : Nil
      to_not(matcher)
    end

    # Asserts that some criteria defined by the matcher is eventually satisfied.
    # The expectation is checked after the example finishes and all hooks have run.
    def to_eventually(matcher) : Nil
      Harness.current.defer { to(matcher) }
    end

    # Asserts that some criteria defined by the matcher is never satisfied.
    # The expectation is checked after the example finishes and all hooks have run.
    def to_never(matcher) : Nil
      Harness.current.defer { to_not(matcher) }
    end

    # ditto
    @[AlwaysInline]
    def never_to(matcher) : Nil
      to_never(matcher)
    end

    # Reports an expectation to the current harness.
    private def report(match_data : Matchers::MatchData)
      expectation = Expectation.new(match_data, @source)
      Harness.current.report_expectation(expectation)
    end
  end
end
