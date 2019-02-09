Gem::Specification.new do |s|
  s.name = 'gtk2svg'
  s.version = '0.3.19'
  s.summary = 'Renders SVG using GTK2'
  s.authors = ['James Robertson']
  s.files = Dir['lib/gtk2svg.rb']
  s.add_runtime_dependency('gtk2', '~> 3.3', '>=3.3.2')
  s.add_runtime_dependency('dom_render', '~> 0.3', '>=0.3.2')
  s.add_runtime_dependency('svgle', '~> 0.4', '>=0.4.4')
  s.signing_key = '../privatekeys/gtk2svg.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@jamesrobertson.eu'
  s.homepage = 'https://github.com/jrobertson/gtk2svg'
  s.required_ruby_version = '>= 2.1.0'
end
