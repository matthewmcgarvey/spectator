require "../test_context"
require "./example_group_builder"

module Spectator::SpecBuilder
  class NestedExampleGroupBuilder < ExampleGroupBuilder
    def initialize(@what : String | Symbol)
    end

    def build(parent_group)
      context = TestContext.new(parent_group.context, build_hooks)
      NestedExampleGroup.new(@what, parent_group, context).tap do |group|
        group.children = children.map do |child|
          child.build(group).as(ExampleComponent)
        end
      end
    end
  end
end
