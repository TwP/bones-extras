
module Bones::Plugins::Rcov
  include ::Bones::Helpers
  extend self

  def initialize_rcov
    ::Bones.config {
      desc 'Configuration settings for the Rcov code coverage tool.'
      rcov {
        dir 'coverage', :desc => <<-__
          Code coverage metrics will be written to this directory.
        __

        opts %w[--sort coverage -T], :desc => <<-__
          An array of command line options that will be passed to the rcov
          command when running your tests. See the Rcov help documentation
          either online or from the command line by running 'rcov --help'.
        __

        threshold 90.0, :desc => <<-__
          The threshold value (in percent) for coverage. If the actual
          coverage is not greater than or equal to this value, the verify task
          will raise an exception.
        __

        threshold_exact false, :desc => <<-__
          Require the threshold to be met exactly. By default this option is
          set to false.
        __
      }
    }
  end

  def post_load
    require 'rcov'
    config = ::Bones.config
    config.exclude << "^#{Regexp.escape(config.rcov.dir)}/"
    have?(:rcov) { true }
  rescue LoadError
    have?(:rcov) { false }
  end

  def define_tasks
    return unless have? :rcov
    config = ::Bones.config

    if have? :test
      namespace :test do
        desc 'Run rcov on the unit tests'
        Rcov::RcovTask.new do |t|
          t.output_dir = config.rcov.dir
          t.rcov_opts = config.rcov.opts
          t.ruby_opts = config.ruby_opts.dup.concat(config.test.opts)

          t.test_files =
              if test(?f, config.test.file) then [config.test.file]
              else config.test.files.to_a end

          t.libs = config.libs unless config.libs.empty?
        end

        task :clobber_rcov do
          rm_r config.rcov.dir rescue nil
        end
      end
      task :clobber => 'test:clobber_rcov'
    end

    if have? :spec
      require 'spec/rake/verify_rcov'
      namespace :spec do
        desc 'Run all specs with Rcov'
        Spec::Rake::SpecTask.new(:rcov) do |t|
          t.ruby_opts = config.ruby_opts
          t.spec_opts = config.spec.opts
          t.spec_files = config.spec.files
          t.libs += config.libs
          t.rcov = true
          t.rcov_dir = config.rcov.dir
          t.rcov_opts.concat(config.rcov.opts)
        end

        RCov::VerifyTask.new(:verify) do |t|
          t.threshold = config.rcov.threshold
          t.index_html = File.join(config.rcov.dir, 'index.html')
          t.require_exact_threshold = config.rcov.threshold_exact
        end

        task :verify => :rcov
        remove_desc_for_task %w(spec:clobber_rcov)
      end
      task :clobber => 'spec:clobber_rcov'
    end
  end

end  # module Bones::Plugins::Rcov
