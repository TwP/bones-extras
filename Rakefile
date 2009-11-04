
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'bones-extras'

task :default => 'test:run'

Bones {
  name  'bones-extras'
  authors  'Tim Pease'
  email  'tim.pease@gmail.com'
  url  'http://github.com/TwP/bones-extras'
  version  BonesExtras::VERSION
  ignore_file  '.gitignore'
}

# EOF
