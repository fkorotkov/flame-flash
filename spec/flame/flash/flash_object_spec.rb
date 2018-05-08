# frozen_string_literal: true

describe Flame::Flash::FlashObject do
	let(:session) { nil }
	let(:parent) { described_class.new(session) }
	let(:scope) { nil }

	subject { parent.scope(scope) }

	describe '#initialize' do
		context 'with existing session' do
			let(:session) do
				[{ type: :notice, text: 'Done' }, { type: :error, text: 'But wrong' }]
			end

			it 'writes session in `now`' do
				expect(subject.now).to eq(session)
			end
		end

		context 'without session' do
			let(:session) { nil }

			it 'writes empty Array in `now`' do
				expect(subject.now).to eq([])
			end
		end

		context 'with Array of texts' do
			let(:session) do
				[type: :error, text: ['invalid email', 'invalid password']]
			end

			it 'unwraps Array into separate elements' do
				expect(subject.now).to eq([
					{ type: :error, text: 'invalid email' },
					{ type: :error, text: 'invalid password' }
				])
			end
		end

		it 'initializes `next` as empty Array' do
			expect(subject.next).to eq([])
		end
	end

	describe '#scope' do
		let(:session) do
			[
				{ type: :error, text: 'Failed' },
				{ type: :notice, text: 'Done', scope: :one },
				{ type: :error, text: 'Failed at one', scope: :one },
				{ type: :warning, text: 'Something wrong', scope: :two }
			]
		end

		context 'without argument' do
			it 'returns self' do
				expect(subject.scope).to eq(subject)
			end
		end

		context 'with argument' do
			it 'returns only from received scope' do
				expect(subject.scope(:one)).to be_instance_of described_class

				expect(subject.scope(:one).now).to eq([
					{ type: :notice, text: 'Done', scope: :one },
					{ type: :error, text: 'Failed at one', scope: :one }
				])
			end
		end
	end

	describe '#[]=' do
		context 'without scope and parent' do
			it 'writes to itself `next`' do
				subject[:error] = 'Failed'

				expect(subject.next).to eq([
					type: :error, text: 'Failed'
				])
			end
		end

		context 'with scope and parent' do
			let(:parent) { described_class.new([]) }
			let(:scope) { :one }

			it "writes to parent's `next`" do
				subject[:error] = 'Failed'

				expect(subject.next).to eq([])

				expect(parent.next).to eq([
					type: :error, text: 'Failed', scope: :one
				])
			end
		end

		it 'unwraps Array of texts' do
			subject[:error] = ['invalid email', 'invalid password']

			expect(subject.next).to eq([
				{ type: :error, text: 'invalid email' },
				{ type: :error, text: 'invalid password' }
			])
		end
	end

	describe '#[]' do
		context 'without scope and parent' do
			let(:session) do
				[
					{ type: :error, text: 'invalid email' },
					{ type: :error, text: 'invalid password' },
					{ type: :notice, text: 'Done' }
				]
			end

			it 'returns Array of texts from received type' do
				expect(subject[:error]).to eq([
					'invalid email', 'invalid password'
				])
			end
		end

		context 'with scope and parent' do
			let(:session) do
				[
					{ type: :error, text: 'Failed' },
					{ type: :notice, text: 'Done', scope: :one },
					{ type: :error, text: 'Failed at one', scope: :one },
					{ type: :warning, text: 'Something wrong', scope: :two }
				]
			end
			let(:scope) { :one }

			it 'returns Array of texts from received type' do
				expect(subject[:error]).to eq([
					'Failed at one'
				])
			end
		end
	end

	describe '#merge' do
		it 'merges received Hash into `next`' do
			subject[:error] = 'Failed'

			subject.merge(notice: 'Done')

			expect(subject.next).to eq([
				{ type: :error, text: 'Failed' },
				{ type: :notice, text: 'Done' }
			])
		end
	end
end
