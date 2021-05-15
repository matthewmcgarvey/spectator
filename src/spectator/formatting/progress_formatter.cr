require "./formatter"

module Spectator::Formatting
  # Output formatter that produces a single character for each test as it completes.
  # A '.' indicates a pass, 'F' a failure, and '*' a skipped or pending test.
  class ProgressFormatter < Formatter
  end
end
