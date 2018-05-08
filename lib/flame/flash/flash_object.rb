# frozen_string_literal: true

require_relative 'flash_array'

module Flame
	## https://github.com/bbatsov/rubocop/issues/5831
	module Flash
		## Contains info about current and next flashes
		class FlashObject
			attr_reader :now, :next

			def initialize(session, parent = nil, scope = nil)
				@now = FlashArray.new(session.to_a)
				@next = FlashArray.new
				@parent = parent || self
				@scope = scope
			end

			def scope(key = nil)
				return self unless key
				self.class.new(now.select(scope: key), self, key)
			end

			def []=(type, text)
				@parent.next.push type, text, scope: (@scope if @parent != self)
			end

			def [](type = nil)
				now.select(type: type).map { |hash| hash[:text] }
			end

			## Mass adding to next
			def merge(hash)
				hash.each { |type, text| self[type] = text }
			end
		end
	end
end
