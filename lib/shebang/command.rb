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
  #       def run
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
  #       def run
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
    # Hash containing various details about a command such as the banner and all
    # help topics.
    Details = {
      :banner  => nil,
      :help    => {},
      :options => []
    }

    class << self
      ##
      # Binds a class to the specified command name.
      #
      # @author Yorick Peterse
      # @since  0.1
      # @param  [#to_sym] name The name of the command.
      #
      def command(name)
        name = name.to_sym

        if Shebang::Commands.key?(name)
          raise(
            ArgumentError,
            "The command #{name} has already been registered"
          )
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
        Details[:banner] = text.strip
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
        Details[:help][title] = text.strip
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
        option = Shebang::Option.new(short, long, desc, options)

        Details[:options].push(option)
      end
      alias :o :option

    end # class << self

    ##
    # Creates a new instance of the command and sets up OptionParser.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def initialize
      @options       = {}
      @option_parser = OptionParser.new do |opt|
        opt.banner         = Details[:banner]
        opt.summary_indent = Shebang::Config[:indent]

        # Process each help topic
        Details[:help].each do |title, text|
          opt.separator "#{Shebang::Config[:heading]}#{
            Shebang::Config[:indent]}#{text}" % title
        end

        opt.separator "#{Shebang::Config[:heading]}" % 'Options'

        # Add all the options
        Details[:options].each do |option|
          opt.on(*option.option_parser) do |value|
            @options[option.short] = @options[option.long] = value

            # Run a method?
            if !option.options[:method].nil? \
            and respond_to?(option.options[:method])
              # Pass the value to the method?
              if self.class.instance_method(option.options[:method]).arity === 1
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
    #
    def parse(argv = [])
      @argv = argv

      @option_parser.parse!(@argv)
    end

    ##
    # Method that is called whenever a command has to be executed.
    #
    # @author Yorick Peterse
    # @since  0.1
    #
    def run
      raise(NotImplementedError, "You need to define your own run() method")
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
