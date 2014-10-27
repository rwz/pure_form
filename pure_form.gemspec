require_relative "lib/pure_form/version"

Gem::Specification.new do |spec|
  spec.name     = "pure_form"
  spec.version  = PureForm::VERSION
  spec.authors  = ["Pavel Pravosud"]
  spec.email    = ["pavel@pravosud.com"]
  spec.summary  = ""
  spec.homepage = "https://github.com/rwz/pure_form"
  spec.license  = "MIT"
  spec.files    = Dir["README.md", "LICENSE.txt", "lib/**/*"]

  spec.required_ruby_version = "~> 2.0"
  spec.add_dependency "activemodel", "~> 4.0"
end
