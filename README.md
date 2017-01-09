# Tracks

Tracks is an ORM (Object Relational Mappig) / MVC (Model View Controller) Framework written in Ruby. `TracksrecordBase` provides the ORM functionality, while `TracksController` provides an inheritable controller class, and `Router` provides the routing capabilities.

## TracksrecordBase

### Key Features

Classes that inherit from TracksrecordBase inherits a number of features:


- the `TracksrecordBase#save` method will insert or update the related row in the database based on the id that is provided.  
- the `TracksrecordBase#destroy` method will delete the related row from the database.
- parameters should be passed in as a hash, (e.g Kitten.new( name: "Cleo", color: "silver", breed: "Abyssinian")). The table name is created by applying the tableize method from ActiveSupport Inflector method to the class name.
- In certain situations, the tableize method will malfunction (i.e human -> humen instead of humans). In these instances you must configure the table name yourself.
- By calling `self.finalize!` at the end of your class definition, attribute accessors corresponding to the columns in the associated database tables are created.

### Demo

classes should be located in `app/models`

```ruby
require_relative '../db.rb'
require_relative './lib/tracksrecord_base'

class Kitten < TracksrecordBase
  finalize!
end
```

require db.rb and tracksrecord_base to automatically initialize the database table for the class.

## TracksController

### Key Features

Custom controller classes that inherit TracksController have the following methods available to them:

- `render(template)`: Render a template located in `app/views/<controller_name>/` folder.
- `render_content(content, content_type)`: Renders custom ontent with the specificed content_type
- `session`: a key/value pair saved to the session hash, saved as cookies.
- `flash/flash.now`: key/value pairs saved to this will persist for only the next session, or current session respectively
- `redirect_to(url)`: Redirects to the url being passed in
- add `protect_from_forgery` to custom controllers to check for authenticity token in any submitted data.


```ruby
<input
  type="hidden"
  name="authenticity_token"
  value="<%= form_authenticity_token %>" />
```

### Demo

Controllers should be placed in app/controllers folder. Naming convention is pluralized and snake case for file name, and pluralized and camel case for class name.


```ruby
require_relative './lib/tracks_controller'
require_relative '../models/kitten'

class KittensController < TracksController

  protect_from_forgery

  def index
    @kittens = Kitten.all

    render :index
  end

  def new
    render :new
  end

  def create
    @kitten = Kitten.new(
      name: params['kitten']['name'],
      color: params['kitten']['color'],
      breed: params['kitten']['breed'],
    )

    @kitten.save
    redirect_to "/kittens/#{@kitten.id}"
  end

end
```


## Router

The `Router` allows you to map routes to your controllers.

```ruby
router = Router.new
router.draw do
  get Regexp.new("^/kittens/new$"), KittensController, :new
  get Regexp.new("^/$"), KittensController, :index
  get Regexp.new("^/kittens/(?<kitten_id>\\d+)$"), KittensController, :show
  post Regexp.new("^/kittens$"), KittensController, :create
  delete Regexp.new("^/kittens/(?<kitten_id>\\d+)$"), KittensController, :destroy
end
```

## Database Access/Setup

TracksrecordBase uses a helper class, DBConnection, which runs SQLite3.
the file can be found in app/db.rb

```ruby
require_relative './models/lib/db_connection'

DBConnection.set_db_file('kittens.db')
DBConnection.reset('kittens.sql') unless DBConnection.db_file_exists?
```

Create a sql file, and place inside db, and a database file will be automatically created for you. If you wish to reseed the database, simply update the sql file, and delete the .db file of the associated sql file.


## Rack Middleware

- StaticAssets allows you to serve static assets in the `/public` folder.
- Exceptions provides error messages for any ruby errors

## Running the App

Ensure that Ruby and Bundler are installed.

1. `git clone https://github.com/KylekJeon/tracks`
2. `bundle install`
3. `ruby config/routes.rb`
4. `open localhost:3000 in browser`
