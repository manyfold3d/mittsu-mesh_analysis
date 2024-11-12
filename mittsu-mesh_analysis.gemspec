require_relative "lib/mittsu/mesh_analysis/version"

Gem::Specification.new do |spec|
  spec.name = "mittsu-mesh_analysis"
  spec.version = Mittsu::MeshAnalysis::VERSION
  spec.authors = ["James Smith"]
  spec.email = ["james@floppy.org.uk"]
  spec.homepage = "https://github.com/manyfold3d/mittsu-mesh_analysis"
  spec.summary = "Mesh analysis tools for Mittsu"
  spec.description = "Mesh analysis tools (e.g. manifold checks) for Mittsu."
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/manyfold3d/mittsu-mesh_analysis"
  spec.metadata["changelog_uri"] = "https://github.com/manyfold3d/mittsu-mesh_analysis/releases"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["lib/**/*", "LICENSE
    ", "Rakefile", "README.md"]
  end

  spec.required_ruby_version = '~> 3.1'

  spec.add_dependency "mittsu", "~> 0.4"

  spec.add_development_dependency "rake", "~> 13.2"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "standard", "~> 1.41"
end
