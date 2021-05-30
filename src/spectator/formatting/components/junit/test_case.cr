require "xml"
require "../../../example"

module Spectator::Formatting::Components::JUnit
  # Test case node of the JUnit XML document.
  # This is the "testsuite" element and all of its children.
  struct TestCase
    # Creates the test case element.
    def initialize(@class_name : String, @example : Example)
    end

    # Produces the XML fragment.
    def to_xml(xml)
      result = @example.result
      xml.element("testcase",
        name: @example,
        assertions: result.expectations.size,
        classname: @class_name,
        status: result.accept(StatusVisitor),
        time: result.elapsed.total_seconds) do
        visitor = ElementVisitor.new(xml)
        result.accept(visitor)
      end
    end

    # Picks the status string for a result.
    private module StatusVisitor
      extend self

      # Returns "PASS".
      def pass(_result)
        "PASS"
      end

      # Returns "FAIL".
      def fail(_result)
        "FAIL"
      end

      # :ditto:
      def error(result)
        fail(result)
      end

      # Returns "TODO".
      def pending(_result)
        "TODO"
      end
    end

    # Result visitor that adds elements to the test case node depending on the result.
    private struct ElementVisitor
      # Creates the visitor.
      def initialize(@xml : XML::Builder)
      end

      # Does nothing.
      def pass(_result)
        # ...
      end

      # Adds a failure element to the test case node.
      def fail(result)
        error = result.error
        @xml.element("failure", message: error.message, type: error.class) do
          # TODO: Add match-data as text to node.
        end
      end

      # Adds an error element to the test case node.
      def error(result)
        error = result.error
        @xml.element("error", message: error.message, type: error.class) do
          if backtrace = error.backtrace
            @xml.text(backtrace.join("\n"))
          end
        end
      end

      # Adds a skipped element to the test case node.
      def pending(_result)
        @xml.element("skipped") # TODO: Populate message attribute with reason from result.
      end
    end
  end
end
