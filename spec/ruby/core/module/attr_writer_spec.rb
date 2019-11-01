require_relative '../../spec_helper'
require_relative 'fixtures/classes'

describe "Module#attr_writer" do
  it "creates a setter for each given attribute name" do
    c = Class.new do
      attr_writer :test1, "test2"
    end
    o = c.new

    o.respond_to?("test1").should == false
    o.respond_to?("test2").should == false

    o.respond_to?("test1=").should == true
    o.test1 = "test_1"
    o.instance_variable_get(:@test1).should == "test_1"

    o.respond_to?("test2=").should == true
    o.test2 = "test_2"
    o.instance_variable_get(:@test2).should == "test_2"
    o.send(:test1=,"test_1 updated")
    o.instance_variable_get(:@test1).should == "test_1 updated"
    o.send(:test2=,"test_2 updated")
    o.instance_variable_get(:@test2).should == "test_2 updated"
  end

  it "not allows for adding an attr_writer to an immediate" do
    class TrueClass
      attr_writer :spec_attr_writer
    end

    -> { true.spec_attr_writer = "a" }.should raise_error(RuntimeError)
  end

  it "converts non string/symbol/fixnum names to strings using to_str" do
    (o = mock('test')).should_receive(:to_str).any_number_of_times.and_return("test")
    c = Class.new do
      attr_writer o
    end

    c.new.respond_to?("test").should == false
    c.new.respond_to?("test=").should == true
  end

  it "raises a TypeError when the given names can't be converted to strings using to_str" do
    o = mock('test1')
    -> { Class.new { attr_writer o } }.should raise_error(TypeError)
    (o = mock('123')).should_receive(:to_str).and_return(123)
    -> { Class.new { attr_writer o } }.should raise_error(TypeError)
  end

  it "applies current visibility to methods created" do
    c = Class.new do
      protected
      attr_writer :foo
    end

    -> { c.new.foo=1 }.should raise_error(NoMethodError)
  end

  ruby_version_is ''...'2.5' do
    it "is a private method" do
      Module.should have_private_instance_method(:attr_writer, false)
    end
  end
  ruby_version_is '2.5' do
    it "is a public method" do
      Module.should have_public_instance_method(:attr_writer, false)
    end
  end
end
