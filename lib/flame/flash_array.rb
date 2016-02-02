module Flame
	module Flash
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
				hash[:scope] = @scope if @parent != self
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

			## Mass adding to next
			def merge(hash)
				hash.each { |type, text| self[type] = text }
			end

			private

			def condition(hash, options = {}) # kind, section)
				options.reject { |key, val| hash[key] == val || val.nil? }.empty?
			end
		end
	end
end
