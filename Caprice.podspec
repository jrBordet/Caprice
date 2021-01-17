Pod::Spec.new do |spec|
  spec.name         = 'Caprice'
  spec.version      = '0.0.6'
  spec.license      = 'MIT'
  spec.summary      = 'A light framework for functional programming with Lenses and Prisms'
  spec.homepage     = 'https://github.com/jrBordet/Caprice.git'
  spec.author       = 'Jean Raphaël Bordet'
  spec.source       = { :git => 'https://github.com/jrBordet/Caprice.git', :tag => spec.version.to_s }
  spec.source_files = 'Caprice/**/*.{swift}'
  spec.requires_arc = true
  spec.ios.deployment_target = '10.0'
end
