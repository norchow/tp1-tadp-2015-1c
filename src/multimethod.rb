require_relative 'partialblock'

class Module
  attr_accessor :methods_hash

  def methods_hash
    @methods_hash = @methods_hash || Hash.new
  end

  def partial_def (symbol, argument_classes, &block)
    self.methods_hash[symbol] = self.methods_hash[symbol] || Array.new
    self.methods_hash[symbol] << PartialBlock.new(argument_classes, &block)

    define_method symbol do |*args|
      self.class.execute(symbol, *args)
    end
  end

  def execute(symbol, *params)
    matches = self.methods_hash[symbol].select {|partial_block| partial_block.matches(*params)}
    matches = matches.sort_by! {|partial_block| partial_block.distance(*params)}
    unless matches.length > 0
      raise ArgumentError
    end
    matches.first.call(*params)
  end

  def multimethods
    self.methods_hash.keys
  end

  def multimethod(symbol)
    self.methods_hash[symbol]
  end
end