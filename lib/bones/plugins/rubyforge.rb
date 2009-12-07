
module Bones::Plugins::Rubyforge
  include ::Bones::Helpers
  extend self

  def initialize_rubyforge
    ::Bones.config {
      rubyforge(:desc => 'Configuration settings for RubyForge publishing.') {}
    }

    require 'rubyforge'
    require 'rake/contrib/sshpublisher'
    have?(:rubyforge) { true }

    ::Bones.config {
      rubyforge {
        name nil, :desc => <<-__
          The RubyForge project name where your code will be published. If not
          supplied, the RubyForge name will default to the base 'name' of your
          gem. The RubyForge name is used when your gem name differs from the
          registered project name; for example if you release multiple gems
          under the same project.
        __
      }

      rdoc {
        remote_dir nil, :desc => <<-__
          This is the remote directory to use when publishing RDoc HTML
          documentation to your RubyForge project page. If not specified, this
          defaults to the root of the project page.
        __
      }
    }
  rescue LoadError
    have?(:rubyforge) { false }
  end

  def post_load
    return unless have? :rubyforge
    config = ::Bones.config
    config.rubyforge.name ||= config.name
  end

  def define_tasks
    return unless have? :rubyforge
    config = ::Bones.config

    namespace :rubyforge do
      desc 'Package gem and upload to RubyForge'
      task :release => ['gem:clobber_package', 'gem:package'] do |t|
        v = ENV['VERSION'] or abort 'Must supply VERSION=x.y.z'
        abort "Versions don't match #{v} vs #{config.version}" if v != config.version
        pkg = "pkg/#{config.gem._spec.full_name}"

        rf = RubyForge.new
        rf.configure rescue nil
        puts 'Logging in'
        rf.login

        c = rf.userconfig
        c['release_notes'] = config.description if config.description
        c['release_changes'] = config.changes if config.changes
        c['preformatted'] = true

        files = Dir.glob("#{pkg}*.*")

        puts "Releasing #{config.name} v. #{config.version}"
        rf.add_release config.rubyforge.name, config.name, config.version, *files
      end

      desc 'Publish RDoc to RubyForge'
      task :doc_release => %w(doc:clobber_rdoc doc:rdoc) do
        config = YAML.load(
          File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )

        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/#{config.rubyforge.name}/"
        remote_dir << config.rdoc.remote_dir if config.rdoc.remote_dir
        local_dir = config.rdoc.dir

        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end

  end

end  # module Bones::Plugins::Rubyforge

# EOF
