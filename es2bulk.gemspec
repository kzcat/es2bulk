require_relative 'lib/es2bulk/version'

Gem::Specification.new do |spec|
  spec.name          = 'es2bulk'
  spec.version       = Es2Bulk::VERSION
  spec.authors       = ['kzcat']
  spec.email         = ['kzcat@users.noreply.github.com']

  spec.summary       = 'Convert Elasticsearch documents to bulk format.'
  spec.description   = 'Elasticsearch helper command. Retrive all documents from index and convert documents to bulk format'
  spec.homepage      = 'https://github.com/kzcat/es2bulk'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = ['es2bulk']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
