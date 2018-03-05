# Flame Flash

[Flashes](http://guides.rubyonrails.org/action_controller_overview.html#the-flash)
for [Flame](https://github.com/AlexWayfer/flame)

## Using

```ruby
# Gemfile
gem 'flame-flash'

# config.ru
require 'flame-flash' # or `Bundler.require`

# _controller.rb
include Flame::Flash
```

```erb
<!-- layout.html.erb -->

<%
  %i[error warning notice].each do |type|
    flash[type].each do |text|
%>
      <p class="flash <%= type %>">
        <%= text %>
      </p>
<%
    end
  end
%>
```

## Examples

```ruby
class PostsController < Flame::Controller
  def update
    flash[:error] = "You don't have permissions"
    redirect :show
  end

  def delete
    redirect :show, notice: 'Deleted'
  end

  def move
    redirect :index, flash: { success: 'Moved' }
  end

  def create
    halt redirect :index, error: 'Not enought permissions'
  end
end
```

### Reserved keys

*   `error`
*   `warning`
*   `notice`
