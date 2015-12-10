# Dir[File.join(__dir__, 'flash', '*.rb')].each { |file| require file }

module Flame
	# Module for Flame::Flash extension with helper methods and base class
	module Flash
		def self.mount
			proc do
				# This callback rotates any flash structure we referenced,
				# placing the 'next' hash into the session for the next request.
				after do
					session[:flash] = flash.next
				end
			end
		end

		private

		def flash(key = nil)
			(
				@flash ||= FlashArray.new(
					(session ? session[:flash] : [])
				)
			).scope(key)
		end

		# A subclass of Array that "remembers forward" by exactly one action.
		# Tastes just like the API of Rails's ActionController::Flash::FlashHash,
		# but with fewer calories.
		class FlashArray
			attr_reader :now, :next

			# Builds a new FlashHash. It takes the hash for this action's values
			# as an initialization variable.
			def initialize(session, parent = nil, scope = nil)
				@now = session || []
				@next = []
				@parent = parent || self
				@scope = scope
			end

			def scope(scope = nil)
				# p 'scope', scope
				return self unless scope
				self.class.new(
					@now.select { |hash| condition(hash, scope: scope) },
					self,
					scope
				)
			end

			# We assign to the _next_ hash, but retrieve values
			# from the _now_ hash. Freaky, huh?
			def []=(type, text)
				hash = { type: type, text: text }
				# p @parent == self, @scope
				hash.merge!(scope: @scope) if @parent != self
				# p hash
				@parent.next.push(hash)
				# p @parent.next
			end

			def [](type = nil)
				selected = @parent.now.select do |hash|
					condition(hash, type: type, scope: @scope)
				end
				# p 'flash[]', type, @scope, selected
				selected.map { |hash| hash[:text] }
			end

			def each(&block)
				@now.each(&block)
			end

			private

			def condition(hash, options = {}) # kind, section)
				options.reject { |key, val| hash[key] == val || val.nil? }.empty?
			end
		end
	end
end
