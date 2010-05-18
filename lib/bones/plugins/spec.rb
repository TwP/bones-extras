
module Bones::Plugins::Spec
  include ::Bones::Helpers
  extend self

  def initialize_spec
    require 'spec/rake/spectask'
    have?(:spec) { true }

    ::Bones.config {
      desc 'Configuration settings for the RSpec test framework.'
      spec {
        files  FileList['spec/**/*_spec.rb'], :desc => <<-__
          The list of spec files to run. This defaults to all the ruby fines
          in the 'spec' directory that end with '_spec.rb' as their filename.
        __

        opts [], :desc => <<-__
          An array of command line options that will be passed to the spec
          command when running your tests. See the RSpec help documentation
          either online or from the command line by running 'spec --help'.
        __
      }
    }
  rescue LoadError
    have?(:spec) { false }
  end

  def post_load
    return unless have? :spec
    config = ::Bones.config
    have?(:spec) { !config.spec.files.to_a.empty?  }
  end

  def define_tasks
    return unless have? :spec
    config = ::Bones.config

    namespace :spec do
      desc 'Run all specs with basic output'
      Spec::Rake::SpecTask.new(:run) do |t|
        t.ruby_opts = config.ruby_opts
        t.spec_opts = config.spec.opts
        t.spec_files = config.spec.files
        t.libs += config.libs
      end

      desc 'Run all specs with text output'
      Spec::Rake::SpecTask.new(:specdoc) do |t|
        t.ruby_opts = config.ruby_opts
        t.spec_opts = config.spec.opts + ['--format', 'specdoc']
        t.spec_files = config.spec.files
        t.libs += config.libs
      end
    end  # namespace :spec

    desc 'Alias to spec:run'
    task :spec => 'spec:run'
  end

end  # module Bones::Plugins::Spec

# EOF
