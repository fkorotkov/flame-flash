require_relative 'flash_array'

module Flame
	# Module for Flame::Flash extension with helper methods and base class
	module Flash
		## After hook
		def execute(method)
			super
			record_flashes
		end

		## Upgrade redirect method
		## @example Redirect to show method of Articles controller with error
		##   redirect ArticlesController, :show, id: 2, error: 'Access required'
		def redirect(*args)
			if args.last.is_a? Hash
				if args[0].is_a? String
					flashes = args.pop
				else
					args[-1], flashes = extract_flashes(args)
				end
				flash.merge(flashes)
			end
			super
		end

		## Capture halt method
		def halt(*args)
			record_flashes
			super
		end

		private

		## Main helper method
		def flash(key = nil)
			(
				@flash ||= FlashArray.new(
					(session ? session[:flash] : [])
				)
			).scope(key)
		end

		## Split Hash-argument to parameters and flashes
		def extract_flashes(args)
			add_controller_class(args)
			parameters = args[0].instance_method(args[1]).parameters.map(&:last)
			args.last.partition do |key, _value|
				parameters.include?(key) || key == :params
			end.map(&:to_h)
		end

		## Move flash.next to session
		def record_flashes
			session[:flash] = flash.next
		end
	end
end
