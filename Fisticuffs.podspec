Pod::Spec.new do |s|
  s.name             = "Fisticuffs"
  s.version          = "0.0.8"
  s.summary          = "Fisticuffs is a data binding framework for Swift, inspired by Knockout."

  s.description      = <<-DESC
  						Fisticuffs is a data binding framework for Swift, inspired by Knockout. Some of the features include:
						
						- Declarative Bindings to most UIKit controls
						- Automatic Updates
						- Automatic Dependency tracking
                       DESC

  s.homepage         = "https://github.com/scoremedia/Fisticuffs"
  s.license          = 'MIT'
  s.author           = { "Darren Clark" => "darren.clark@thescore.com" }
  s.source           = { :git => "https://github.com/scoremedia/Fisticuffs.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.swift_version = '4.2'
  s.requires_arc = true

  s.source_files = 'Source/**/*.{m,swift}'
end
