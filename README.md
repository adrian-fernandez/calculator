# README

Small web-services offering two functionalities: Calculator and Name guesser

## Setup
  1. Use ruby 3.2.2 and install bundler gem
  2. Run `setup` script `sh setup.sh`. This script automatizes the following tasks:
	  1. Install gems `bundle install`
	  2. Setup database: `rails db:setup`
	  3. Run migrations: `rails db:migrate`
	  4. Run seed task to populate DB with sample data: `rails db:seed`

       This step will output the generated token that could be used for testing
```
Created sample user with token <TOKEN>
```
  3. Run docker-compose to launch Redis instances `docker-compose up`
  4. Run rails server `rails s`
  5. Test app: `curl -s -H "Authorization: Bearer <TOKEN>" http://localhost:3000/up`


It should return the Rails sample page:

```
<!DOCTYPE html><html><body style="background-color: green"></body></html>%

```

* Usage

### Calculator
Allowed operations are `+`, `-`, `*`, and `/` given in the `expression` query parameter

When the request is successful it returns status 200 and payload `{ expression: 'requested_expression', result: 'calculated_result' }`

When the request is unsuccessful it returns status 422 and payload `{ payload: 'error_message', valid: false }`

Sample request

```
$ curl -s -w '\nstatus:%{http_code}' -H "Authorization: Bearer <TOKEN>" http://localhost:3000/api/v1/services/calc\?expression\=10\*5+1

{"result":51,"expression":'10*5+1}
status:200%
```

It returns `result` with the result, `expression` with the expression requested by user and status 200

Example of an invalid request
```
$ curl -s -w '\nstatus:%{http_code}' -H "Authorization: Bearer <TOKEN>" http://localhost:3000/api/v1/services/calc\?expression\=10\*5+

{"payload":"Invalid mathematical expression format","valid":false}
status:422%

```
It returns the error message, valid = false, and the status 422:

If a division by zero is found while evaluating the expression it returns a specific error for this case:

```
$ curl -s -w '\nstatus:%{http_code}' -H "Authorization: Bearer <TOKEN>" http://localhost:3000/api/v1/services/calc\?expression\=10\*5/0

{"payload":"Division by zero found in the expression","valid":false}
status:422%
```


### Country Guesser
This service expects a `name` query parameter and returns the guessed country for that last name.

When the request is successful it returns status 200 and payload `{ guessed_country: 'country_code', requested_name: 'requested_name', time_processed: 'time_in_ms_to_complete_the_request' }`

When the request is unsuccessful it returns status 422 and payload `{ payload: 'error_message', valid: false }`

Sample request

```
$ curl -s -w '\nstatus:%{http_code}' -H "Authorization: Bearer <TOKEN>" http://localhost:3000/api/v1/services/country_guess\?name\=fernandez

{"guessed_country":"ESP","requested_name":"fernandez","time_processed":0.0008540153503417969}
status:200%
```

Example of an invalid request
```
$ curl -s -w '\nstatus:%{http_code}' -H "Authorization: Bearer <TOKEN>" http://localhost:3000/api/v1/services/country_guess\?name\=

{"payload":"Error fetching data from FamilySearch","valid":false}
status:422%
```

##   Design decisions

- Used SQLite to simplify the app architecture since for this example is not needed to set a PostgreSQL instance
- No user management, just a seed task to create a valid User with a token for testing. The token is valid for 1 month for testing reasons (to avoid having to refresh it), in a real scenario this value should be decreased
- There are two Redis servers, one is used for cache and the other one for security to handle connection requests. This is to not break security if the cache fills available memory and to not run out of cache when the request number is huge
- There are some values like error messages, API endpoint, and params names hardcoded in constants, they could be extracted to I18n translations, ENV vars, or configurable fields but for this small demo it was not considered necessarily
- To split responsibilities of the classes each service consists on two services:
  - <name>Service: Performs the action and returns the result
  - <name>Presenter: Builds the JSON payload from the result object to the user
- There is an auxiliary service `TimeMeter` that executes the given block and returns a hash with the result of evaluating the block and time consumed to easily track the processing time for any service or request.

##   Performance & Cache

- Calculator is an internal service, since the logic is simple it performs the calculus each time a user requests it and returns the result.
- Country Guesser uses [external service](familysearch.org), to improve the performance the app implements a caching system in two levels. When a request is received it tries to find a similar request on the Redis instance, if there is no result then it tries to find it on DB. In the worst scenario, it fetches the value from the real API server and stores the request and results in Redis, this way next time the user requests the same value it will be provided from Redis.
- When Redis cache hits the threshold of 100 keys (configurable via `CACHE_THRESHOLD` ENV var) it schedules a background task to move all Redis cache to the database and clean Redis.
- If the payloads become bigger a good serializing gem like `Oj` would be useful, but for now they are pretty simple so the performance increase wouldn't be significant

##	 Security

- Used Rack-Attack gem to filter rack requests (ban users trying to access WordPress routes) and limit the maximum rate of allowed requests per second for the same IP (the values are random, in a real scenario that should be adjusted)

- Doorkeeper gem for user authentication, all unauthenticated requests will return a 401 error

```
$ curl -s -w '\nstatus:%{http_code}' -H "Authorization: Bearer wrong_token" http://localhost:3000/api/v1/services/calc\?expression\=10\*5

{"error":"unauthorized","error_description":"You are not authorized to access this resource."}
status:401%
```

##   Auxiliar gems

- `simplecov` to track testing code coverage (report available at `coverage/index.html`)
- `VCR` to record real requests to API server and use the saved response in tests instead of mocking data that could contain typos
- `rubocop` + `rubocop-performance` + `rubocop-rails` for code linting
- `brakeman` for security checks

##   Author

Adrián Fernández ([adrianfernandez85@gmail.com](mailto:adrianfernandez85@gmail.com))
