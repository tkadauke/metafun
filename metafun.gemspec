Gem::Specification.new do |s| 
  s.platform  =   Gem::Platform::RUBY
  s.name      =   "metafun"
  s.version   =   "0.0.1"
  s.date      =   Date.today.strftime('%Y-%m-%d')
  s.author    =   "imedo GmbH"
  s.email     =   "entwicker@imedo.de"
  s.homepage  =   "http://www.imedo.de/"
  s.summary   =   "Metaprogramming tools"
  s.files     =   Dir.glob("lib/**/*")

  s.has_rdoc = true
  s.extra_rdoc_files = ["README.rdoc"]
  
  s.require_path = "lib"
end
