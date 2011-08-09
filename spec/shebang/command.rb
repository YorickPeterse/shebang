require File.expand_path('../../helper', __FILE__)
require File.expand_path('../../fixtures/command', __FILE__)

describe('Shebang::Command') do
  it('The name should be registered') do
    Shebang::Commands[:default].should == SpecCommand
  end

  it('The banner should be set') do
    Shebang::Commands[:default].instance_variable_get(:@__banner).should \
      === 'The default command.'

    Shebang::Commands[:default].new.banner.should === 'The default command.'
  end

  it('A help topic should be set') do
    Shebang::Commands[:default].instance_variable_get(
      :@__help_topics
    )['Usage'].should === 'shebang.rb [COMMAND] [OPTIONS]'

    Shebang::Commands[:default].new.help_topics['Usage'].should \
      === 'shebang.rb [COMMAND] [OPTIONS]'
  end

  it('An option should be set') do
    option = Shebang::Commands[:default].instance_variable_get(:@__options)[0]

    option.short.should            === :v
    option.long.should             === :version
    option.description.should      === 'Shows the current version'
    option.options[:method].should === :version
    option.value                   = '0.1'

    Shebang::Commands[:default].new.options[0].short.should === option.short

    Shebang::Commands[:default].new.option(:v).should       === option.value
    Shebang::Commands[:default].new.option(:version).should === option.value
  end
end
