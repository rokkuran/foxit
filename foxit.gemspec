
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require "foxit/version"

Gem::Specification.new do |spec|
  spec.name          = "foxit"
  # spec.version       = Foxit::VERSION
  spec.version       = "0.1.3"
  spec.authors       = ["Lachlan Taylor"]
  spec.email         = ["lachlanbtaylor@gmail.com"]

  spec.summary       = %q{Unofficial Kitsu API wrapper with MongoDB capability.}
  # spec.description   = %q{Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/rokkuran/foxit"
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.4.4'

  spec.add_dependency 'json', '~> 2.1.0', '>= 2.0.4'
  spec.add_dependency 'addressable', '~> 2.5.2', '>= 2.5.2'
  spec.add_dependency 'mongo', '~> 2.5.1', '>= 2.5.1'
end
