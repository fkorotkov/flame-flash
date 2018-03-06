# frozen_string_literal: true

require 'gorilla-patch/slice'

require_relative 'flash/flash_array'

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
				flash.merge args.first.is_a?(String) ? args.pop : extract_flashes(args)
			end
			flash.next.concat(flash.now) ## for multiple redirects
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

		RESERVED_FLASH_KEYS = %i[error warning notice].freeze

		using GorillaPatch::Slice

		## Split Hash-argument to parameters and flashes
		def extract_flashes(args)
			add_controller_class(args)
			flashes = args.last.delete(:flash) { {} }
			## Yeah, `RESERVED_FLASH_KEYS` will rest in `args`
			## and will be passed into parent's `redirect`.
			## But I don't see a problem cause of it for now.
			## If you see - please, send a PR, or create an issue.
			flashes.merge args.last.slice(*RESERVED_FLASH_KEYS)
		end

		## Move flash.next to session
		def record_flashes
			session[:flash] = flash.next
		end
	end
end
