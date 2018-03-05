# frozen_string_literal: true

describe Flame::Flash do
	require 'rack/test'
	include Rack::Test::Methods

	module FlashTest
		class Controller < Flame::Controller
			include Flame::Flash
		end

		class IndexController < Controller
			def index
				"params: #{params}, flashes: #{flash.now}"
			end

			def show(id)
				"id: #{id}, flashes: #{flash.now}"
			end

			def set_as_regular
				flash[:error] = 'Regular'
				redirect :index
			end

			def set_as_argument
				redirect :index, notice: 'Argument'
			end

			def set_as_argument_with_parameters
				redirect :show, id: 2, notice: 'Argument'
			end

			def set_as_argument_with_params
				redirect :index, params: { foo: 'bar' }, notice: 'Argument'
			end

			def set_as_argument_for_string
				redirect '/', notice: 'Argument'
			end

			def halt_with_flashes
				halt redirect :index, notice: 'Halted'
			end
		end

		class Application < Flame::Application
			mount IndexController, '/'
		end
	end

	def app
		FlashTest::Application
	end

	describe '#execute' do
		it 'writes flashes in after-hook' do
			get '/set_as_regular'
			follow_redirect!
			expect(last_response.body).to eq(
				'params: {}, flashes: [{:type=>:error, :text=>"Regular"}]'
			)
		end
	end

	describe '#redirect' do
		context 'without parameters for action' do
			it 'extract flashes from Hash argument' do
				get '/set_as_argument'
				follow_redirect!
				expect(last_response.body).to eq(
					'params: {}, flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end

		context 'with parameters for action' do
			it 'extract flashes from Hash argument' do
				get '/set_as_argument_with_parameters'
				follow_redirect!
				expect(last_response.body).to eq(
					'id: 2, flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end

		context 'with params' do
			it 'extract flashes from Hash argument' do
				get '/set_as_argument_with_params'
				follow_redirect!
				expect(last_response.body).to eq(
					'params: {:foo=>"bar"},' \
					' flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end

		context 'first argument is a String' do
			it 'extract flashes from all keys of Hash argument' do
				get '/set_as_argument_for_string'
				follow_redirect!
				expect(last_response.body).to eq(
					'params: {}, flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end
	end

	describe '#halt' do
		it 'writes flashes before halting' do
			get '/halt_with_flashes'
			follow_redirect!
			expect(last_response.body).to eq(
				'params: {}, flashes: [{:type=>:notice, :text=>"Halted"}]'
			)
		end
	end
end
