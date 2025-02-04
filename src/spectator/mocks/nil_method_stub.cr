require "./generic_arguments"
require "./generic_method_stub"
require "./value_method_stub"

module Spectator::Mocks
  class NilMethodStub < GenericMethodStub(Nil)
    def call(_args : GenericArguments(T, NT), &_original : -> RT) forall T, NT, RT
      nil
    end

    def and_return
      self
    end

    def and_return(value)
      ValueMethodStub.new(@name, @location, value, @args)
    end

    def and_return(*values)
      MultiValueMethodStub.new(@name, @location, values.to_a, @args)
    end

    def and_raise(exception_type : Exception.class)
      ExceptionMethodStub.new(@name, @location, exception_type.new, @args)
    end

    def and_raise(exception : Exception)
      ExceptionMethodStub.new(@name, @location, exception, @args)
    end

    def and_raise(message : String)
      ExceptionMethodStub.new(@name, @location, Exception.new(message), @args)
    end

    def and_raise(exception_type : Exception.class, *args) forall T
      ExceptionMethodStub.new(@name, @location, exception_type.new(*args), @args)
    end

    def with(*args : *T, **opts : **NT) forall T, NT
      args = GenericArguments.new(args, opts)
      NilMethodStub.new(@name, @location, args)
    end

    def with(args : Arguments)
      NilMethodStub.new(@name, @location, @args)
    end

    def and_call_original
      OriginalMethodStub.new(@name, @location, @args)
    end
  end
end
