require 'simplecov'
require 'coveralls'

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_group "Command", "lib/vagrant-hypconfigmgmt/command.rb"
end


def get_random_string()
  # random a-z0-9 string
  # http://stackoverflow.com/a/3572953
  length = 10
  return rand(36 ** length).to_s(36)
end
