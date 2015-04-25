class PartialBlock

  attr_accessor :block, :parameters_types

  def initialize (some_parameters_types, &one_block)

    self.block = one_block
    self.parameters_types = some_parameters_types
  end

  def matches(*some_arguments)
    return (self.same_lists_size(some_arguments, self.parameters_types) && self.same_parameters_type(*some_arguments))
  end

  def call(*some_parameters

     unless self.matches(*some_parameters)
      raise ArgumentError.new('La cantidad de parametros informados no coinciden con la cantidad de parametros usados en el bloque')
    end

    self.block.call(*some_parameters)
  end

  def same_lists_size(list1, list2)
    return list1.size == list2.size
  end

  def same_parameters_type(*some_arguments)
    (some_arguments.zip self.parameters_types).all? do |argument, parameter_type|
      argument.is_a? parameter_type
    end
  end

  def distance(*args)
    sum = 0
    args.each_with_index do |elem, index|
      sum += elem.class.ancestors.index(self.parameters_types[index])
    end
    sum
  end
end