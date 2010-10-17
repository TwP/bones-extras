
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
task :default => 'test:run'

Bones {
  name        'bones-extras'
  authors     'Tim Pease'
  email       'tim.pease@gmail.com'
  url         'http://github.com/TwP/bones-extras'
  version     '1.3.0'
  ignore_file '.gitignore'

  depend_on   'bones'
  depend_on   'bones-rcov'
  depend_on   'bones-rubyforge'
  depend_on   'bones-rspec'
  depend_on   'bones-zentest'

  use_gmail
}

