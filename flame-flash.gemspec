require 'date'

Gem::Specification.new do |s|
	s.name        = 'flame-flash'
	s.version     = '2.3.3'
	s.date        = Date.today.to_s

	s.summary     = 'Flash plugin for Flame-framework'
	s.description = 'Show messages (notifies, errors, warnings)' \
	                ' in current or next routes after redirect.'

	s.authors     = ['Alexander Popov']
	s.email       = ['alex.wayfer@gmail.com']
	s.homepage    = 'https://github.com/AlexWayfer/flame-flash'
	s.license     = 'MIT'

	s.add_runtime_dependency 'flame', '~> 4.6', '>= 4.6.0'

	s.files = Dir[File.join('lib', '**', '*')]
end
