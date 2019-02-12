# frozen_string_literal: true

require 'gorilla_patch/deep_dup'
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
			args, flashes = extract_flashes_for_redirect(args)
			flash.merge flashes
			flash.next.concat(flash.now) ## for multiple redirects
			super(*args)
		end

		## Upgrade view method
		## @example Render view with error
		##   view :show, error: 'Access required'
		def view(path = nil, options = {}, &block)
			options, flashes = extract_flashes(options)
			flash.now.merge flashes
			super(
				path || caller_locations(1, 1)[0].label.to_sym,
				options,
				&block
			)
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

		using GorillaPatch::DeepDup
		using GorillaPatch::Slice

		## Split Hash-argument to parameters and flashes
		def extract_flashes(options)
			options = options.deep_dup
			flashes = options.delete(:flash) { {} }
			## Yeah, `RESERVED_FLASH_KEYS` will be deleted from `options`
			## and will not be passed into parent's `redirect` or `view`.
			## But I don't see a problem cause of it for now.
			## If you see - please, send a PR, or create an issue.
			flashes.merge! options.slice_reverse!(*RESERVED_FLASH_KEYS)
			[options, flashes]
		end

		def extract_flashes_for_redirect(args)
			return [args, {}] unless args.last.is_a? Hash
			return [args, args.pop] if args.first.is_a?(String)

			add_controller_class(args)
			options, flashes = extract_flashes(args.last)
			[args[0..-2].push(options), flashes]
		end

		## Move flash.next to session
		def record_flashes
			session[:flash] = flash.next
		end
	end
end
