require 'rspec'
require_relative '../src/multimethod'


describe 'base tests' do
  before(:all) do
    class A
      partial_def :m, [Object] do |o|
        "A>m"
      end

      partial_def :m, [String] do ||
        base.m([Symbol], 'mundo!')
      end

      partial_def :m,[Symbol] do |text|
        'hola '+text
      end
    end

    class B < A
      partial_def :m,[Integer] do |i|
        base.m([Numeric], i) + " => B>m_integer(#{i})"
      end
      partial_def :m,[Numeric] do |n|
        base.m([Object], n) + " => B>m_numeric"
      end

      partial_def :metodoErroneo,[Integer] do |n|
        base.metodoErroneo([Numeric], n)
      end


    end

    class C < B
      partial_def :m, [String, String] do |text1, text2|
        'hola '+text1+text2
      end
      partial_def :m, [String] do |text|
        base.m([String, String], text, text) + ' querido'
      end

    end

    class D
      partial_def :m, [Object] do |o|
        "A>m"
      end
    end

    class E < D

      partial_def :m, [Integer] do |i|
        base(i) + " => B>m_integer(#{i})"
      end

      partial_def :m, [Numeric] do |n|
        base(n) + " => B>m_numeric"
      end

    end
  end

  it 'base funciona' do
    expect(A.new.m('lala')).to eq('hola mundo!')
  end

  it 'base funciona con 2 argumentos' do
    expect(C.new.m('pe')).to eq('hola pepe querido')
  end

  it 'base funciona con herencia' do
    expect(B.new.m(1)).to eq('A>m => B>m_numeric => B>m_integer(1)')
    expect(B.new.m(1.5)).to eq('A>m => B>m_numeric')
  end

  it 'base falla si la definición no existe' do
    expect {B.new.metodoErroneo(1)}.to raise_error(NonexistentMultimethodDefinitonError)
    end

  it 'base implicito funciona' do
    expect(E.new.m(1.8)).to eq("A>m => B>m_numeric")
    expect(E.new.m(1)).to eq("A>m => B>m_numeric => B>m_integer(1)")
  end

end