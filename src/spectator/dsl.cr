require "./example_group"

module Spectator
  module DSL
    macro describe(what, source_file = __FILE__, source_line = __LINE__, type = "Describe", &block)
      context({{what}}, {{source_file}}, {{source_line}}, {{type}}) {{block}}
    end

    macro context(what, source_file = __FILE__, source_line = __LINE__, type = "Context", &block)
      {% safe_name = what.id.stringify.gsub(/\W+/, "_") %}
      {% module_name = (type.id + safe_name.camelcase).id %}
      {% context_module = CONTEXT_MODULE %}
      {% parent_given_vars = GIVEN_VARIABLES %}
      module {{module_name.id}}
        include ::Spectator::DSL

        CONTEXT_MODULE = {{context_module.id}}::{{module_name.id}}
        GIVEN_VARIABLES = [
          {{ parent_given_vars.join(", ").id }}
        ]{% if parent_given_vars.empty? %} of Object{% end %}

        module Locals
          include {{context_module.id}}::Locals

          {% if what.is_a?(Path) %}
            def described_class
              {{what}}
            end
          {% end %}
        end

        {{block.body}}
      end
    end

    macro it(description, source_file = __FILE__, source_line = __LINE__, &block)
      {% safe_name = description.id.stringify.gsub(/\W+/, "_") %}
      {% class_name = (safe_name.camelcase + "Example").id %}
      {% given_vars = GIVEN_VARIABLES %}
      {% var_names = given_vars.map { |v| v[0] } %}
      class {{class_name.id}} < ::Spectator::Example
        include Locals

        {% unless given_vars.empty? %}
          def initialize({{ var_names.map { |v| "@#{v}" }.join(", ").id }})
          end
        {% end %}

        def source
          Source.new({{source_file}}, {{source_line}})
        end

        def num
          0
        end

        def run
          {{block.body}}
        end
      end

      {% if given_vars.empty? %}
        ::Spectator::ALL_EXAMPLES << {{class_name.id}}.new
      {% else %}
        {% for given_var in given_vars %}
          {% var_name = given_var[0] %}
          {% collection = given_var[1] %}
          {{collection}}.each do |{{var_name}}|
        {% end %}
        ::Spectator::ALL_EXAMPLES << {{class_name.id}}.new({{var_names.join(", ").id}})
        {% for given_var in given_vars %}
          end
        {% end %}
      {% end %}
    end

    def it_behaves_like
      raise NotImplementedError.new("Spectator::DSL#it_behaves_like")
    end

    macro subject(&block)
      let(:subject) {{block}}
    end

    macro let(name, &block)
      let!({{name}}!) {{block}}

      module Locals
        @_%wrapper : ValueWrapper?

        def {{name.id}}
          if (wrapper = @_%wrapper)
            wrapper.as(TypedValueWrapper(typeof({{name.id}}!))).value
          else
            {{name.id}}!.tap do |value|
              @_%wrapper = TypedValueWrapper(typeof({{name.id}}!)).new(value)
            end
          end
        end
      end
    end

    macro let!(name, &block)
      module Locals
        def {{name.id}}
          {{block.body}}
        end
      end
    end

    macro given(collection, source_file = __FILE__, source_line = __LINE__, &block)
      context({{collection}}, {{source_file}}, {{source_line}}, "Given") do
        {% var_name = block.args.empty? ? "value" : block.args.first %}

        module Locals
          getter {{var_name.id}}
        end

        {% GIVEN_VARIABLES << {var_name, collection} %}

        {{block.body}}
      end
    end

    def before_all
      raise NotImplementedError.new("Spectator::DSL#before_all")
    end

    def before_each
      raise NotImplementedError.new("Spectator::DSL#before_each")
    end

    def after_all
      raise NotImplementedError.new("Spectator::DSL#after_all")
    end

    def after_each
      raise NotImplementedError.new("Spectator::DSL#after_each")
    end

    def around_each
      raise NotImplementedError.new("Spectator::DSL#around_each")
    end

    def include_examples
      raise NotImplementedError.new("Spectator::DSL#include_examples")
    end
  end
end
