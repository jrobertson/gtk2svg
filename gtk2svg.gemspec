Gem::Specification.new do |s|
  s.name = 'gtk2svg'
  s.version = '0.3.6'
  s.summary = 'Renders SVG using GTK2'
  s.authors = ['James Robertson']
  s.files = Dir['lib/gtk2svg.rb']
  s.add_runtime_dependency('gtk2', '~> 3.0', '>=3.0.7')
  s.add_runtime_dependency('dom_render', '~> 0.2', '>=0.2.1')
  s.add_runtime_dependency('svgle', '~> 0.2', '>=0.2.1')
  s.signing_key = '../privatekeys/gtk2svg.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'james@r0bertson.co.uk'
  s.homepage = 'https://github.com/jrobertson/gtk2svg'
end
