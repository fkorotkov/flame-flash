require_relative 'flash_array'

module Flame
	# Module for Flame::Flash extension with helper methods and base class
	module Flash
		def execute(method)
			super
			session[:flash] = flash.next
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
