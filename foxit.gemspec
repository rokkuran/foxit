
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
# require "foxit/version"

Gem::Specification.new do |spec|
  spec.name          = "foxit"
  # spec.version       = Foxit::VERSION
  spec.version       = "0.1.0"
  spec.authors       = ["Lachlan Taylor"]
  spec.email         = ["lachlanbtaylor@gmail.com"]

  spec.summary       = %q{Write a short summary, because RubyGems requires one.}
  spec.description   = %q{Write a longer description or delete this line.}
  # spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]

  spec.add_dependency = 'net/http'
  spec.add_dependency = 'json'
  spec.add_dependency = 'addressable/uri'
  spec.add_dependency = 'mongo'

end
