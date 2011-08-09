module Shebang
  ##
  # Shebang::Command is where the party really starts. By extending this class
  # other classes can become fully fledged commands with their own options,
  # banners, callbacks, and so on. In it's most basic form a command looks like
  # the following:
  #
  #     class MyCommand < Shebang::Command
  #       command 'my-command'
  #
  #       def index
  #
  #       end
  #     end
  #
  # The class method command() is used to register the class to the specified
  # name, without this Shebang would be unable to call it.
  #
  # Defining options can be done by calling the class method option() or it's
  # alias o():
  #
  #     class MyCommand < Shebang::Command
  #       command 'my-command'
  #
  #       o :h, :help, 'Shows this help message', :method => :help
  #
  #       def index
  #
  #       end
  #     end
  #
  # If you're going to define a help option, and you most likely will, you don't
  # have to manually add a method that shows the message as the Command class
  # already comes with an instance method for this, simply called help().
  #
  # For more information on options see Shebang::Option#initialize().
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  class Command
    # Several methods that become available as class methods once
    # Shebang::Command is extended by another class.
    module ClassMethods
      ##
      # Binds a class to the specified command name.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [#to_sym] name The name of the command.
      # @param  [Hash] options Hash containing various options for the command.
      # @option options :parent The name of the parent command.
      #
      def command(name, options = {})
        name = name.to_sym

        if Shebang::Commands.key?(name)
          Shebang.error("The command #{name} has already been registered")
        end

        Shebang::Commands[name] = self
      end

      ##
      # Sets the banner for the command, trailing or leading newlines will
      # be removed.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] text The content of the banner.
      #
      def banner(text)
        @__banner = text.strip
      end

      ##
      # A small shortcut for defining the syntax of a command. This method is
      # just a shortcut for the following:
      #
      #  help('Usage', 'foobar [OPTIONS]'
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] text The content of the usage block.
      #
      def usage(text)
        help('Usage', text)
      end

      ##
      # Sets a general "help topic" with a custom title and content.
      #
      # @example
      #  help('License', 'MIT License')
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [String] title The title of the topic.
      # @param  [String] text The content of the topic.
      #
      def help(title, text)
        @__help_topics      ||= {}
        @__help_topics[title] = text.strip
      end

      ##
      # Creates a new option for a command.
      #
      # @example
      #  o :h, :help, 'Shows this help message', :method => :help
      #  o :l, :list, 'A list of numbers'      , :type   => Array
      #
      # @author Yorick Peterse
      # @since  0.1
      # @see    Shebang::Option#initialize
      #
      def option(short, long, desc = nil, options = {})
        @__options ||= []
        option       = Shebang::Option.new(short, long, desc, options)

        @__options.push(option)
      end
      alias :o :option
    end # ClassMethods

    ##
    # Modifies the class that inherits this class so that the module
    # Shebang::Comand::ClassMethods extends the class.
    #
    # @author Yorick Peterse
    # @since  09-08-2011
    # @param  [Class] by The class that inherits from Shebang::Command.
    #
    def self.inherited(by)
      by.extend(Shebang::Command::ClassMethods)
    end

    ##
    # Creates a new instance of the command and sets up OptionParser.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def initialize
      @option_parser = OptionParser.new do |opt|
        opt.banner         = banner
        opt.summary_indent = Shebang::Config[:indent]

        # Process each help topic
        help_topics.each do |title, text|
          opt.separator "#{Shebang::Config[:heading]}#{
            Shebang::Config[:indent]}#{text}" % title
        end

        opt.separator "#{Shebang::Config[:heading]}" % 'Options'

        # Add all the options
        options.each do |option|
          opt.on(*option.option_parser) do |value|
            option.value = value

            # Run a method?
            if !option.options[:method].nil? \
            and respond_to?(option.options[:method])
              # Pass the value to the method?
              if self.class.instance_method(option.options[:method]).arity != 0
                send(option.options[:method], value)
              else
                send(option.options[:method])
              end
            end
          end
        end
      end
    end

    ##
    # Parses the command line arguments using OptionParser.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [Array] argv Array containing the command line arguments to parse.
    # @return [Array] argv Array containing all the command line arguments after
    #  it has been processed.
    #
    def parse(argv = [])
      @option_parser.parse!(argv)

      options.each do |option|
        if option.required? and !option.has_value?
          Shebang.error("The -#{option.short} option is required")
        end
      end

      return argv
    end

    ##
    # Returns the banner of the current class.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @return [String]
    #
    def banner
      self.class.instance_variable_get(:@__banner)
    end

    ##
    # Returns all help topics for the current class.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @return [Hash]
    #
    def help_topics
      self.class.instance_variable_get(:@__help_topics) || {}
    end

    ##
    # Returns an array of all the options for the current class.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @return [Array]
    #
    def options
      self.class.instance_variable_get(:@__options) || []
    end

    ##
    # Method that is called whenever a command has to be executed.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def index
      raise(NotImplementedError, "You need to define your own index() method")
    end

    ##
    # Returns the value of a given option. The option can be specified using
    # either the short or long name.
    #
    # @example
    #  puts "Hello #{option(:name)}
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [#to_sym] opt The name of the option.
    # @return [Mixed]
    #
    def option(opt)
      opt = opt.to_sym

      options.each do |op|
        if op.short === opt or op.long === opt
          return op.value
        end
      end
    end

    ##
    # Shows the help message for the current class.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def help
      puts @option_parser
      exit
    end
  end # Command
end # Shebang
