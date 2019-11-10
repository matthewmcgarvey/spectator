module Spectator::Mocks
  module Stubs
    private macro stub(definition, &block)
      {%
        name = nil
        params = nil
        args = nil
        body = nil
        if definition.is_a?(Call) # stub foo { :bar }
          named = false
          name = definition.name.id
          params = definition.args
          args = params.map do |p|
            n = p.is_a?(TypeDeclaration) ? p.var : p.id
            r = named ? "#{n}: #{n}".id : n
            named = true if n.starts_with?('*')
            r
          end
          body = definition.block.is_a?(Nop) ? block : definition.block
        elsif definition.is_a?(TypeDeclaration) # stub foo : Symbol
          name = definition.var
          params = [] of MacroId
          args = [] of MacroId
          body = block
        else
          raise "Unrecognized stub format"
        end

        original = if @type.methods.find { |m| m.name.id == name }
                     :previous_def
                   else
                     :super
                   end.id
      %}

      def {{name}}({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
        %call = ::Spectator::Mocks::GenericMethodCall.new({{name.symbolize}}, %args)
        ::Spectator::Harness.current.mocks.record_call(self, %call)
        if (%stub = ::Spectator::Harness.current.mocks.find_stub(self, %call))
          %stub.call!(%args, typeof({{original}}({{args.splat}})))
        else
          {{original}}({{args.splat}})
        end
      end

      def {{name}}({{params.splat}}){% if definition.is_a?(TypeDeclaration) %} : {{definition.type}}{% end %}
        %args = ::Spectator::Mocks::GenericArguments.create({{args.splat}})
        %call = ::Spectator::Mocks::GenericMethodCall.new({{name.symbolize}}, %args)
        ::Spectator::Harness.current.mocks.record_call(self, %call)
        if (%stub = ::Spectator::Harness.current.mocks.find_stub(self, %call))
          %stub.call!(%args, typeof({{original}}({{args.splat}}) { |*%ya| yield *%ya }))
        else
          {{original}}({{args.splat}}) do |*%yield_args|
            yield *%yield_args
          end
        end
      end
    end
  end
end
