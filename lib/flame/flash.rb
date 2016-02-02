require_relative 'flash_array'

module Flame
	# Module for Flame::Flash extension with helper methods and base class
	module Flash
		def execute(method)
			super
			session[:flash] = flash.next
		end

		## Upgrade redirect method
		## @example Redirect to show method of Articles controller with error
		##   redirect ArticlesController, :show, id: 2, error: 'Access required'
		def redirect(*args)
			if args.last.is_a? Hash
				add_controller_class(args)
				parameters = args[0].instance_method(args[1]).parameters.map(&:last)
				args[-1], flashes = args.last.partition do |key, _value|
					parameters.include? key
				end.map(&:to_h)
				flash.merge(flashes)
			end
			super
		end

		private

		def flash(key = nil)
			(
				@flash ||= FlashArray.new(
					(session ? session[:flash] : [])
				)
			).scope(key)
		end
	end
end
