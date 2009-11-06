
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
task :default => 'test:run'

Bones.plugin :ann, :gem, :git, :notes, :rdoc

Bones {
  name        'bones-extras'
  authors     'Tim Pease'
  email       'tim.pease@gmail.com'
  url         'http://github.com/TwP/bones-extras'
  version     '1.0.1'
  ignore_file '.gitignore'

  depend_on   'bones'

  use_gmail
  enable_sudo
}

# EOF
