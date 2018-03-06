# frozen_string_literal: true

describe 'README' do
	subject { File.read File.join(__dir__, '..', 'README.md') }

	it 'includes reserved flash keys' do
		expect(subject).to include(
			*Flame::Flash::RESERVED_FLASH_KEYS.map { |key| "*   `#{key}`" }
		)
	end
end
