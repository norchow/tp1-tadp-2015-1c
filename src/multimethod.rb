require_relative 'partialblock'

module MultiMethod
  attr_accessor :methods_hash

  def methods_hash
    @methods_hash = @methods_hash || Hash.new
  end

  def partial_def (symbol, argument_classes, &block)
    self.methods_hash[symbol] = self.methods_hash[symbol] || Array.new
    self.methods_hash[symbol] << PartialBlock.new(argument_classes, &block)
    self.send(:define_method, symbol) {|params| self.class.execute(symbol, params)}
  end

  def execute(symbol, *params)
    matches = self.methods_hash[symbol].select {|partial_block| partial_block.matches(*params)}
    matches = matches.sort_by! {|partial_block| partial_block.distance(*params)}
    matches.first.call(*params)
  end
end