Gem::Specification.new do |s|
	s.name        = 'flame-flash'
	s.version     = '2.2.0'
	s.date        = Date.today.to_s

	s.summary     = 'Flash plugin for Flame-framework'
	s.description = 'Show messages (notifies, errors, warnings)' \
	                ' in current or next routes after redirect.'

	s.authors     = ['Alexander Popov']
	s.email       = ['alex.wayfer@gmail.com']
	s.homepage    = 'https://gitlab.com/AlexWayfer/flame-flash'
	s.license     = 'MIT'

	s.add_runtime_dependency 'flame', '~> 4.0', '>= 4.0.3'

	s.files = Dir[File.join('lib', '**', '*')]
end
