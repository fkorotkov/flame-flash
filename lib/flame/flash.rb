# frozen_string_literal: true

require 'gorilla_patch/slice'

require_relative 'flash/flash_object'

module Flame
	# Module for Flame::Flash extension with helper methods and base class
	module Flash
		protected

		## After hook
		def execute(method)
			super
			record_flashes
		end

		## Upgrade redirect method
		## @example Redirect to show method of Articles controller with error
		##   redirect ArticlesController, :show, id: 2, error: 'Access required'
		def redirect(*args)
			flash.merge extract_flashes_for_redirect(args)
			flash.next.concat(flash.now) ## for multiple redirects
			super
		end

		## Upgrade view method
		## @example Render view with error
		##   view :show, error: 'Access required'
		def view(*args)
			flash.now.merge extract_flashes(args) if args.last.is_a? Hash
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
				@flash ||= FlashObject.new(
					(session ? session[:flash] : [])
				)
			).scope(key)
		end

		RESERVED_FLASH_KEYS = %i[error warning notice].freeze

		using GorillaPatch::Slice

		## Split Hash-argument to parameters and flashes
		def extract_flashes(args)
			flashes = args.last.delete(:flash) { {} }
			## Yeah, `RESERVED_FLASH_KEYS` will rest in `args`
			## and will be passed into parent's `redirect`.
			## But I don't see a problem cause of it for now.
			## If you see - please, send a PR, or create an issue.
			flashes.merge args.last.slice(*RESERVED_FLASH_KEYS)
		end

		def extract_flashes_for_redirect(args)
			return {} unless args.last.is_a? Hash
			return args.pop if args.first.is_a?(String)
			add_controller_class(args)
			extract_flashes(args)
		end

		## Move flash.next to session
		def record_flashes
			session[:flash] = flash.next
		end
	end
end
