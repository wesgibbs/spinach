module Spinach
  # Runner gets the parsed data from the feature and performs the actual calls
  # to the feature classes.
  #
  class Runner

    # The feature files to run
    attr_reader :filenames

    # The default path where the steps are located
    attr_reader :step_definitions_path

    # The default path where the support files are located
    attr_reader :support_path

    # Initializes the runner with a parsed feature
    #
    # @param [Array<String>] filenames
    #   A list of feature filenames to run
    #
    # @param [Hash] options
    #
    # @option options [String] :step_definitions_path
    #   The path in which step definitions are found.
    #
    # @option options [String] :support_path
    #   The path with the support ruby files.
    #
    # @api public
    def initialize(filenames, options = {})
      @filenames = filenames

      @step_definitions_path = options.delete(:step_definitions_path ) ||
        Spinach.config.step_definitions_path

      @support_path = options.delete(:support_path ) ||
        Spinach.config.support_path
    end

    # The feature files to run
    attr_reader :filenames

    # The default path where the steps are located
    attr_reader :step_definitions_path

    # The default path where the support files are located
    attr_reader :support_path

    # Runs this runner and outputs the results in a colorful manner.
    #
    # @return [true, false]
    #   Whether the run was succesful.
    #
    # @api public
    def run
      require_dependencies
      require_suites

      Spinach.hooks.run_before_run

      successful = true

      filenames.each do |filename|
        success = FeatureRunner.new(filename).run
        successful = false unless success
      end

      Spinach.hooks.run_after_run(successful)

      successful
    end

    # Loads support files and step definitions, ensuring that env.rb is loaded
    # first.
    #
    # @api public
    def require_dependencies
      required_files.each do |file|
        require file
      end
    end

    # Requires the test suite support
    #
    def require_suites
      require_relative 'suites'
    end

    # @return [Array<String>] files
    #   The step definition files.
    #
    # @api public
    def step_definition_files
      Dir.glob(
        File.expand_path File.join(step_definitions_path, '**', '*.rb')
      )
    end

    # @return [Array<String>] files
    #   The support files.
    #
    # @api public
    def support_files
      Dir.glob(
        File.expand_path File.join(support_path, '**', '*.rb')
      )
    end

    # @return [Array<String>] files
    #   The environment support file env.rb.
    #
    # @api public
    def environment_file
      support_files.select {|f| f =~ %r{#{File::SEPARATOR}#{support_path}#{File::SEPARATOR}env.rb} }
    end

    # @return [Array<String>] files
    #   The support files excluding env.rb
    #
    # @api public
    def support_files_minus_env
      support_files - environment_file
    end

    # @return [Array<String>] files
    #   All support files with env.rb ordered first, followed by the step
    #   definitions.
    #
    # @api public
    def required_files
      environment_file + support_files_minus_env + step_definition_files
    end

  end
end

require_relative 'runner/feature_runner'
require_relative 'runner/scenario_runner'
