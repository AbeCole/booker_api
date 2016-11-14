# Booker Ruby Client

Client for the Booker v4 API. See http://apidoc.booker.com for method-level documentation.

Currently this gem is a diversion from the strategy used by https://github.com/HireFrederick/booker_ruby

## Setup

Add the gem to your Gemfile:

`gem 'booker_api'`

Configuration may be specified via the environment or when initializing Booker::Client:

Configuring via environment variables:
```
BOOKER_CLIENT_ID = YOUR_CLIENT_ID
BOOKER_CLIENT_SECRET = YOUR_CLIENT_SECRET
BOOKER_BUSINESS_SERVICE_URL = https://app.secure-booker.com/webservice4/json/BusinessService.svc
BOOKER_CUSTOMER_SERVICE_URL = https://app.secure-booker.com/webservice4/json/CustomerService.svc
BOOKER_DEFAULT_PAGE_SIZE = 10
BOOKER_API_DEBUG = false # Set to true to print request details to the log
```

To ease development, **the gem points to Booker's API Sandbox at apicurrent-app.booker.ninja by default**. For production, you must specify the service urls via the environment or when initializing Booker::Client.

## Using Booker::Client

There are two client classes. **Booker::CustomerClient** is used to interact with the v4 CustomerService. **Booker::BusinessClient** is used to interact with the v4 BusinessService.

The client handles authorization and requesting new access tokens as needed.

```
# Use BusinessClient to interact with the v4 BusinessService on behalf of a merchant

business_client = Booker::BusinessClient.new(
  booker_account_name: 'accountname',
  booker_username: 'myusername',
  booker_password: 'secret'
)

logged_in_user = business_client.get_logged_in_user
location = business_client.get_location(booker_location_id: logged_in_user.LocationID)

location.ID
# => 45678

location.BusinessName
# => 'My Booker Spa'

treatments = client.find_treatments(booker_location_id: location.ID)

# Use CustomerClient to interact with the v4 CustomerService as a consumer

customer_client = Booker::CustomerClient.new

available_times = customer_client.run_multi_spa_multi_sub_category_availability(
  booker_location_ids: [location.ID],
  treatment_sub_category_ids: treatments.first.SubCategory.ID,
  start_date_time: Time.zone.tomorrow.beginning_of_day,
  end_date_time: Time.zone.tomorrow.end_of_day
)

first_result = available_times.first
first_result_treatment = first_result.Treatment
first_result_treatment.Name
# => 60 Minute Swedish Massage

first_available_time = first_result.AvailableTimes.first
first_available_time.StartDateTime
# => 2016-01-20 08:00:00 -0800
```

## Available Methods

For available methods, see:
* [common_rest.rb](lib/booker/common_rest.rb)
* [business_rest.rb](lib/booker/business_rest.rb)
* [customer_rest.rb](lib/booker/customer_rest.rb)

## Handling dates and times

Booker's API expects all timestamps to be in their server's timezone offset, which is always US Eastern Time, as the API is not timezone aware. This gem handles all of this for you and will always provide Ruby `ActiveSupport::TimeWithZone` objects in your current `Time.zone`.

ActiveSupport::TimeWithZone is a required dependency.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/HireFrederick/booker_ruby.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).


## Notable changes to this fork

CustomerRest#run_multi_service_availability
treatment_ids now accepts a Integer type object and wraps it in an array
employee_id (optional) parameter moved to 5th parameter position
BEFORE: booker_location_id, treatment_ids, employee_id = nil, start_date_time, end_date_time, options: {}
AFTER: booker_location_id, treatment_ids, start_date_time, end_date_time, employee_id = nil, options: {}

CustomerRest#create_incomplete_appointment
Added function to reach 'appointment/createincomplete' booker endpoint. Data structure has not been refined, it is simply one that works with Booker and could be reduced.

CustomerRest#find_treatments
Added to reach '/treatments'. Expects booker_location_id and optionally a category_id

CustomerRest#get_treatment_categories
Added to reach '/treatment_categories'. Expects booker_location_id

CustomerRest#get_locations
Added to reach '/locations'

CustomerRest#find_employees
Added to reach '/employees'

CustomerRest#get_customer
Added to reach '/customer/#{customer_id}'. Expects customer_id and optionally custom_access_token.

CustomerRest#create_customer
Added to reach '/customer/account'. Expects booker_location_id and a customer_data hash with keys: email, password, first_name, last_name & cell_phone.

CustomerRest#update_customer
Added to reach '/customer/#{customer_id}'. Expects customer_id, a customer_data hash and optionally custom_access_token.

CustomerRest#login
Added to reach '/customer/login'. Expects booker_location_id, email & password.

CustomerRest#forgot_password
Added to reach '/forgot_password/custom'. Expects booker_location_id, email, first_name & base_url (callback URL).

CustomerRest#reset_password
Added to reach '/password/reset'. Expects key & password.

CustomerRest#create_appointment
Modified to accept booker_location_id, start_time, treatment_ids, incomplete_appoinment_id, customer_id, credit_card, custom_access_token = {}

Client#handle_errors!
Commented out attempt to get new access token

Errors#initialize
Altered to handle Booker errors that provide a "Fault" root attribute.
