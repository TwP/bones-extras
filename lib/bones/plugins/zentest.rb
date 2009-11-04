
module Bones::Plugins::Zentest
  include ::Bones::Helpers
  extend self

  def post_load
    require 'zentest'
    have?(:zentest) { true }
  rescue LoadError
    have?(:zentest) { false }
  end

  def define_tasks
    return unless have? :zentest

    if have? :test
      require 'autotest'
      namespace :test do
        task :autotest do
          load '.autotest' if test(?f, '.autotest')
          Autotest.run
        end
      end

      desc 'Run the autotest loop'
      task :autotest => 'test:autotest'
    end

    if have? :spec
      require 'autotest/rspec'
      namespace :spec do
        task :autotest do
          load '.autotest' if test(?f, '.autotest')
          Autotest::Rspec.run
        end
      end

      desc 'Run the autotest loop'
      task :autotest => 'spec:autotest'
    end
  end

end  # module Bones::Plugins::Zentest
