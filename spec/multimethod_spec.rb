require 'rspec'
require_relative '../src/multimethod'

describe 'MultiMethod tests' do

  before(:all) do

    class B

      partial_def :concat, [String, String,String] do |s1, s2, s3|
          s1 + s2 + s3
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

      partial_def :concat, [Object, Object] do |o1, o2|
        "Objetos concatenados"
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
    A.multimethod(:concat)
  end

  it 'elige bien segun distancia' do
    expect(A.new.concat("Hello", 2)).to eq("HelloHello")
    expect(A.new.concat(Object.new, 3)).to eq("Objetos concatenados")
  end

  it 'puede utilizar el contexto de la instancia' do
    expect(Person.new("John").greet("Hi!")).to eq("Hi! I am John")
    expect(Person.new("John").greet(3)).to eq("Hi, I'm John Hi, I'm John Hi, I'm John ")
  end


  it 'funciona la herencia de multi-methods' do
    expect(A.new.concat('hello', ' world', '!')).to eq('hello world!')
  end

end