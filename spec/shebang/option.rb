require File.expand_path('../../helper', __FILE__)

describe('Shebang::Option') do
  it('Create a new option') do
    option = Shebang::Option.new(:h, :help, 'help message', :method => :test)

    option.short.should       === :h
    option.long.should        === :help
    option.description.should === 'help message'

    option.options[:method].should === :test
    option.options[:type].should   == TrueClass

    option.required?.should  === false
    option.has_value?.should === false
  end

  it('Convert to OptionParser arguments') do
    option = Shebang::Option.new(:h, :help, 'help message', :method => :test)

    option.option_parser.should === ['-h', '--help', 'help message', TrueClass]
  end
end
