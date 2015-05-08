require_relative 'multimethod'

module Bool
end

class TrueClass
  include Bool
end

class FalseClass
  include Bool
end

class Object

  alias_method :original_respond_to?, :respond_to?

  partial_def :respond_to?, [Symbol] do |symbol|
    self.original_respond_to?(symbol)
  end

  partial_def :respond_to?, [Symbol,Bool] do |symbol,include_all|
    self.original_respond_to?(symbol,include_all)
  end

  partial_def :respond_to?, [Symbol,Bool,Array] do |symbol,_,types|
    self.class.executable_multi_method(symbol).is_defined_for_types?(types)
  end
end