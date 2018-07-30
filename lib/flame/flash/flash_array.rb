# frozen_string_literal: true

module Flame
	## https://github.com/bbatsov/rubocop/issues/5831
	module Flash
		## Just contains flashes
		class FlashArray
			def initialize(array = [])
				@array = []
				concat(array)
			end

			def ==(other)
				other == @array
			end

			def each(&block)
				@array.each(&block)
			end

			def []=(type, text)
				push(type, text)
			end

			def push(type, text, scope: nil)
				if text.is_a?(Enumerable)
					text.each { |el| push(type, el, scope: scope) }
					return
				end
				hash = { type: type, text: text }
				hash[:scope] = scope if scope
				@array.push(hash)
			end

			def delete(type, text)
				@array.delete(type: type, text: text)
			end

			def select(**options)
				@array.select do |hash|
					options.reject { |key, val| hash[key] == val || val.nil? }.empty?
				end
			end

			def concat(array)
				array.each do |hash|
					push(hash[:type], hash[:text], scope: hash[:scope])
				end
			end

			def merge(hash)
				hash.each { |type, text| self[type] = text }
			end

			def to_a
				@array
			end
		end

		private_constant :FlashArray
	end
end
