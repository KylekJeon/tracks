# Tracks - A Model-View-Controller Framework built with Ruby

Tracks is a framework that provides the necessary tools to create web applications following the Model-View-Controller Pattern.

## Setup

* Clone Tracks repository
* Run bundle install
* Create models in app/models, controllers in app/controllers and views in app/views

```
# app/models/users.rb

class User

end
```

```
# app/controllers/users_controller.rb

require_relative 'lib/otr_controller'
require_relative '../models/user'

class UsersController < ControllerBase
  def index

  end
end
```

```
# app/views/users/show.html.erb

  <% @user.first_name %>

```

* Create Routes using controller names, method names, and regex

```
# config/routes.rb

OTR_ROUTER.draw do
  get Regexp.new("^/users$"), UsersController, :index
  get Regexp.new("^/users/new$"), UsersController, :new
  post Regexp.new("^/users$"), UsersController, :create
  get Regexp.new("^/users/(?<id>\\d+)$"), UsersController, :show
end
```

* Run on your localhost with bundle exec rackup config/link.ru
