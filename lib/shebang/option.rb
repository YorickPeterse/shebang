module Shebang
  ##
  # Class that represents a single option that's passed to OptionParser.
  #
  # @author Yorick Peterse
  # @since  0.1
  #
  class Option
    attr_reader   :short, :long, :description, :options
    attr_accessor :value

    ##
    # Creates a new instance of the Option class.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @param  [#to_sym] short The short option name such as :h.
    # @param  [#to_sym] long The long option name such as :help.
    # @param  [String] desc The description of the option.
    # @param  [Hash] options Hash containing various configuration options for
    #  the OptionParser option.
    # @option options :type The type of value for the option, set to TrueClass
    #  by default.
    # @option options :key The key to use to indicate a value whenever the type
    #  of an option is something else than TrueClass or FalseClass. This option
    #  is set to "VALUE" by default.
    # @option options :method A symbol that refers to a method that should be
    #  called whenever the option is specified.
    # @option options :required Indicates that the option has to be specified.
    # @option options :default The default value of the option.
    #
    def initialize(short, long, desc = nil, options = {})
      @short, @long = short.to_sym, long.to_sym
      @description  = desc
      @options      = {
        :type     => TrueClass,
        :key      => 'VALUE',
        :method   => nil,
        :required => false,
        :default  => nil
      }.merge(options)

      @value = @options[:default]
    end

    ##
    # Builds an array containing all the required parameters for
    # OptionParser#on().
    #
    # @author Yorick Peterse
    # @since  0.1
    # @return [Array]
    #
    def option_parser
      params = ["-#{@short}", "--#{@long}", nil, @options[:type]]

      if !@description.nil? and !@description.empty?
        params[2] = @description
      end

      # Set the correct format for the long/short option based on the type.
      if ![TrueClass, FalseClass].include?(@options[:type])
        params[1] += " #{@options[:key]}"
      end

      return params
    end

    ##
    # Checks if the value of an option is not nil and not empty.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @return [TrueClass|FalseClass]
    #
    def has_value?
      if !@value.nil? and !@value.empty?
        return true
      else
        return false
      end
    end

    ##
    # Indicates whether or not the option requires a value.
    #
    # @author Yorick Peterse
    # @since  0.1
    # @return [TrueClass|FalseClass]
    #
    def required?
      return @options[:required]
    end
  end # Option
end # Shebang
