require 'rspec'
require_relative '../src/respond_to'

describe 'MultiMethod tests' do

  before(:all) do

    class B

      partial_def :concat, [String, String, String] do |s1, s2, s3|
          s1 + s2 + s3
      end

      partial_def :concat, [Integer, Integer, Integer ] do |n1, n2, n3|
        n1 + n2 + n3
      end

      partial_def :concat, [TrueClass] do |n1|
        true
      end

    end
    class A < B

      partial_def :concat, [String, String] do |s1, s2|
        s1 + s2
      end

      partial_def :concat, [String, Integer] do |s1,n|
        s1 * n
      end

      partial_def :concat, [Array] do |a|
        a.join
      end

      partial_def :concat, [Integer, Integer, Integer ] do |n1, n2, n3|
        n1 + n2 + n3 + 1
      end

      partial_def :concat, [Object, Object] do |o1, o2|
        "Objetos concatenados"
      end

      partial_def :concat, [Object,Object,Object] do |o1, o2, o3|
        "Objetos concatenados"
      end

    end

    class C<A

      partial_def :concat, [Object,Object,Object] do |o1, o2, o3|
        "Objetos concatenados por la clase C"
      end

    end

    class Person

      attr_accessor :name

      def initialize(name)
       self.name=name
      end

      partial_def :greet, [String] do |greeting|
         greeting+" I am "+self.name
      end

      partial_def :greet, [Integer] do |repetitions|
        ("Hi, I'm #{self.name} ")*repetitions
      end

    end

  end

  it 'funcionan los multimetodos' do
    expect(A.new.concat('hello', 'world')).to eq('helloworld')
    expect(A.new.concat('hello', 3)).to eq('hellohellohello')
    expect(A.new.concat(['hello', ' world', '!'])).to eq('hello world!')
    expect(B.new.concat('hello', 'world','!')).to eq('helloworld!')
  end

  it 'mensaje multimethods' do
    expect(A.multimethods()).to eq([:concat])
  end

  it 'mensaje multimethod' do
    A.multi_method_definition(:concat)
  end

  it 'elige bien segun distancia' do
    expect(A.new.concat("Hello", 2)).to eq("HelloHello")
    expect(A.new.concat(Object.new, 3)).to eq("Objetos concatenados")
  end

  it 'puede utilizar el contexto de la instancia' do
    expect(Person.new("John").greet("Hi!")).to eq("Hi! I am John")
    expect(Person.new("John").greet(3)).to eq("Hi, I'm John Hi, I'm John Hi, I'm John ")
  end

  it 'funciona la prioridad en la herencia de multi-methods' do
    expect(A.new.concat('hello', ' world', 5)).to eq("Objetos concatenados")
    expect(A.new.concat('hello', ' world', '!')).to eq('hello world!')
  end

  it 'pisa definicion con la misma firma en la herencia de multi-methods' do
    expect(B.new.concat(1, 2 , 5)).to eq(8)
    expect(A.new.concat(1, 2 , 5)).to eq(9)
    expect(C.new.concat('hello', ' world', 5)).to eq("Objetos concatenados por la clase C")
  end

  it 'Siendo C<A<B, C ve los metodos de B' do
    expect(C.new.concat("a", "b" , "c")).to eq("abc")
  end

  it 'Si no define multimethod explota bien' do
    expect{B.multimethod(:metodoloco).execute_for(1,2)}.to raise_error(NonexistentMultimethodDefinitonError)
  end

  it 'respond_to para multimethods funciona bien' do
    expect(A.new.respond_to?(:concat,false, [Integer,Integer,Integer])).to be_truthy
    expect(A.new.respond_to?(:concat,false, [Integer,Array,Integer,Integer])).to be_falsey
  end

  it 'respond_to ve la herencia' do
    expect(A.new.respond_to?(:concat,false, [TrueClass])).to be_truthy
  end

  it 'respond_to original anda como siempre' do
    expect(B.new.respond_to?(:concat,false)).to be_truthy
  end



end