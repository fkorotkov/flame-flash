# frozen_string_literal: true

describe Flame::Flash do
	require 'rack/test'
	include Rack::Test::Methods

	module FlashTest
		class Controller < Flame::Controller
			include Flame::Flash

			private

			def server_error(exception)
				p exception
			end
		end

		class IndexController < Controller
			def index
				"params: #{params}, flashes: #{flash.now.to_a}"
			end

			def show(id)
				"id: #{id}, flashes: #{flash.now.to_a}"
			end

			def redirect_set_as_regular
				flash[:error] = 'Regular'
				redirect :index
			end

			def redirect_set_as_argument
				redirect :index, notice: 'Argument', params: params
			end

			def redirect_set_as_argument_with_parameters
				redirect :show, id: 2, notice: 'Argument'
			end

			def redirect_set_as_argument_with_params
				redirect :index, params: { foo: 'bar' }, notice: 'Argument'
			end

			def redirect_set_as_argument_for_string
				redirect '/', notice: 'Argument'
			end

			def redirect_set_as_flash_key
				redirect :index, flash: { foo: 'bar' }
			end

			def view_set_as_regular
				flash.now[:error] = 'Regular'
				view :index
			end

			def view_set_as_argument
				view :index, notice: 'Argument'
			end

			def view_set_as_flash_key
				view :index, flash: { foo: 'bar' }
			end

			def view_without_parameters
				view
			end

			def halt_with_flashes
				halt redirect :index, notice: 'Halted'
			end

			protected

			def execute(action)
				flash.now.delete :notice, 'Argument' if params[:delete]
				super
			end
		end

		class ControllerWithParameter < Controller
			def index
				"params: #{params}, flashes: #{flash.now.to_a}"
			end

			def redirect_set_as_argument
				redirect :index, foo: 'bar', notice: 'Argument'
			end
		end

		class Application < Flame::Application
			mount IndexController, '/'
			mount ControllerWithParameter, '/controller_with_parameter/:?foo'
		end
	end

	def app
		FlashTest::Application
	end

	describe '#execute' do
		it 'writes flashes in after-hook' do
			get '/redirect_set_as_regular'
			follow_redirect!
			expect(last_response.body).to eq(
				'params: {}, flashes: [{:type=>:error, :text=>"Regular"}]'
			)
		end
	end

	describe '#redirect' do
		context 'without parameters for action' do
			it 'extract flashes from Hash argument' do
				get '/redirect_set_as_argument'
				follow_redirect!
				expect(last_response.body).to eq(
					'params: {}, flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end

		context 'with parameters for action' do
			it 'extract flashes from Hash argument' do
				get '/redirect_set_as_argument_with_parameters'
				follow_redirect!
				expect(last_response.body).to eq(
					'id: 2, flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end

		context 'with parameters for controllers' do
			it "doesn't extract controller's parameters as flashes" do
				get '/controller_with_parameter/redirect_set_as_argument'
				follow_redirect!
				expect(last_response.body).to eq(
					'params: {:foo=>"bar"},' \
					' flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end

		context 'with params' do
			it 'extract flashes from Hash argument' do
				get '/redirect_set_as_argument_with_params'
				follow_redirect!
				expect(last_response.body).to eq(
					'params: {:foo=>"bar"},' \
					' flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end

		context 'first argument is a String' do
			it 'extract flashes from all keys of Hash argument' do
				get '/redirect_set_as_argument_for_string'
				follow_redirect!
				expect(last_response.body).to eq(
					'params: {}, flashes: [{:type=>:notice, :text=>"Argument"}]'
				)
			end
		end

		it 'extract flashes from Hash at `flash` key' do
			get '/redirect_set_as_flash_key'
			follow_redirect!
			expect(last_response.body).to eq(
				'params: {}, flashes: [{:type=>:foo, :text=>"bar"}]'
			)
		end
	end

	describe '#view' do
		after do
			expect(last_response.status).to eq 200
		end

		context 'with writing current flashes as regular' do
			it 'renders view with flashes' do
				get '/view_set_as_regular'
				expect(last_response.body).to eq(
					'[{:type=>:error, :text=>"Regular"}]'
				)
			end
		end

		it 'extract flashes from Hash argument' do
			get '/view_set_as_argument'
			expect(last_response.body).to eq(
				'[{:type=>:notice, :text=>"Argument"}]'
			)
		end

		it 'extract flashes from Hash at `flash` key' do
			get '/view_set_as_flash_key'
			expect(last_response.body).to eq(
				'[{:type=>:foo, :text=>"bar"}]'
			)
		end

		it "doesn't break Flame::Controller#view without parameters" do
			get '/view_without_parameters'
			expect(last_response.body).to eq("I'm still alive!\n")
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

	describe 'flash.now.delete' do
		it 'deletes flashes by type and text' do
			get '/redirect_set_as_argument?delete=true'
			follow_redirect!
			expect(last_response.body).to eq(
				'params: {:delete=>"true"}, flashes: []'
			)
		end
	end
end
