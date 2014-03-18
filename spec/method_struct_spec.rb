require "rubygems"
require "bundler/setup"
require "method_struct"

describe MethodStruct do
  describe ".new" do
    let(:argument1) { double("argument1") }
    let(:argument2) { double("argument2") }
    let(:verifier) { double("verifier") }

    def create_poker(verifier)
      Class.new(MethodStruct.new(:x, :y)) do
        define_method(:call) do
          verifier.poke(x, y)
        end
      end
    end

    before {}

    it "creates a class method which calls the declared instance method with the given context" do
      verifier.should_receive(:poke).with(argument1, argument2)
      create_poker(verifier).call(argument1, argument2)
    end

    it "creates a hash version of the call method" do
      verifier.should_receive(:poke).with(argument1, argument2)
      create_poker(verifier).call(:x => argument1, :y => argument2)
    end

    it "can change the name of the main method" do
      verifier.should_receive(:poke).with(argument1, argument2)

      the_verifier = verifier
      poker = Class.new(MethodStruct.new(:x, :y, :method_name => :something)) do
        define_method(:something) do
          the_verifier.poke(x, y)
        end
      end

      poker.something(argument1, argument2)
    end

    describe "equality" do
      let(:struct) { MethodStruct.new(:a, :b) }

      it "is equal for equal arguments" do
        expect(struct.new(argument1, argument2) == struct.new(argument1, argument2)).to be_true
      end

      it "has equal hashes for equal arguments" do
        expect(struct.new(1, 2).hash).to eq(struct.new(1, 2).hash)
      end

      it "is unequal for unequal arguments" do
        expect(struct.new(argument1, argument2) == struct.new(argument2, argument1)).to be_false
      end

      it "is unequal for different MethodsStruct classes" do
        expect(MethodStruct.new(:a, :b).new(1, 2)).not_to eq(struct.new(1, 2))
      end

      it "has unequal hashes for unequal arguments (most of the time)" do
        expect(struct.new("something", "something else").hash).not_to eq(struct.new("more", "stuff").hash)
      end
    end

    context "when arguments are hashes" do
      let(:argument1) { { :things => true } }
      let(:argument2) { { :stuff => true } }

      it "handles them correctly" do
        verifier.should_receive(:poke).with(argument1, argument2)
        create_poker(verifier).call(argument1, argument2)
      end

      it "allows the single argument to be a hash" do
        verifier.should_receive(:poke).with(argument1)

        the_verifier = verifier
        poker = Class.new(MethodStruct.new(:x)) do
          define_method(:call) do
            the_verifier.poke(x)
          end
        end

        poker.call(argument1)
      end
    end
  end
end
