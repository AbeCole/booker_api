module Booker
  module CustomerREST
    include CommonREST

    def get_customer_appointments(customer_id, custom_access_token, options = {})
      get "/customer/#{customer_id}/appointments", build_params(options, custom_access_token)
    end
    
    def create_appointment(booker_location_id, start_time, treatment_ids, incomplete_appoinment_id, customer, credit_card, coupon_code = nil, notes = nil, custom_access_token = {}, options: {})
      post "/appointment/create", build_params({
        "LocationID" => booker_location_id,
        "ItineraryTimeSlotList" => [
          "StartDateTime" => start_time,
          "TreatmentTimeSlots" => treatment_ids.map { |id|
            {
              "StartDateTime" => start_time,
              "TreatmentID" => id
            }
          }
        ],
        "AppointmentPayment" => {
          "PaymentItem" => {
            "CreditCard" => credit_card,
            "Method" => {
              "ID" => 1
            }
          },
          "CouponCode" => coupon_code
        },
        "Notes" => notes,
        "IncompleteAppointmentID" => incomplete_appoinment_id,
        "Customer" => customer
      }, custom_access_token.merge(options)), Booker::Models::Appointment
    end

    def create_incomplete_appointment(booker_location_id, start_time, treatment_ids, options = {})
      post '/appointment/createincomplete', build_params({
        'LocationID' => booker_location_id,
        'ItineraryTimeSlot' => {
          'StartDateTime' => start_time,
          'TreatmentTimeSlots' => treatment_ids.map { |id| { 'StartDateTime' => start_time, 'TreatmentID' => id } }
        }
      }, options)
    end

    def create_class_appointment(booker_location_id, class_instance_id, customer, options = {})
      post '/class_appointment/create', build_params({
            'LocationID' => booker_location_id,
            'ClassInstanceID' => class_instance_id,
            'Customer' => customer
          }, options), Booker::Models::Appointment
    end

    def calculate_appointment_cost(booker_location_id, appointment_id, coupon_code, options = {})
      post '/appointment/prebooking/totalcost', build_params({
        'LocationID' => booker_location_id,
        'AppointmentID' => appointment_id,
        'CouponCode' => coupon_code,
        'AppointmentDate' => DateTime.now,
        'AppointmentTreatmentDTOs' => []
      }, options)
    end

    def run_multi_spa_multi_sub_category_availability(booker_location_ids, treatment_sub_category_ids, start_date_time, end_date_time, options = {})
      post '/availability/multispamultisubcategory', build_params({
            'LocationIDs' => booker_location_ids,
            'TreatmentSubCategoryIDs' => treatment_sub_category_ids,
            'StartDateTime' => start_date_time,
            'EndDateTime' => end_date_time,
            'MaxTimesPerTreatment' => 1000
          }, options), Booker::Models::SpaEmployeeAvailabilitySearchItem
    end

    def run_multi_service_availability(booker_location_id, treatment_ids, start_date_time, end_date_time, employee_id = nil, options = {})
      treatment_ids = [treatment_ids] unless treatment_ids.respond_to?(:map)
      post '/availability/multiservice', build_params(
        {
          'LocationID' => booker_location_id,
          'StartDateTime' => start_date_time,
          'EndDateTime' => end_date_time,
          'MaxTimesPerDay' => 100,
          'Itineraries' => treatment_ids.map { |id| { 'Treatments' => [{ 'TreatmentID' => id, 'EmployeeID' => employee_id }] } }
        }, options
      ), Booker::Models::MultiServiceAvailabilityResult
    end

    def run_class_availability(booker_location_id, from_start_date_time, to_start_date_time, options = {})
      post '/availability/class', build_params({
          'FromStartDateTime' => from_start_date_time,
          'LocationID' => booker_location_id,
          'OnlyIfAvailable' => true,
          'ToStartDateTime' => to_start_date_time,
          'ExcludeClosedDates' => true
        }, options), Booker::Models::ClassInstance
    end

    def find_treatments(booker_location_id, category_id = nil)
      post '/treatments', build_params({
        'LocationID' => booker_location_id,
        'CategoryID' => category_id
      })
    end

    def get_treatment_categories(booker_location_id)
      get '/treatment_categories', build_params({
        'location_id' => booker_location_id
      })
    end

    def get_locations
      post '/locations', build_params
    end
    
    def find_employees(booker_location_id)
      post '/employees', build_params({
        'LocationID' => booker_location_id
      })
    end

    def get_customer(customer_id, custom_access_token, options = {})
      get "/customer/#{customer_id}", build_params(options, custom_access_token)
    end

    def create_customer(booker_location_id, customer_data, options: {})
      post '/customer/account', build_params({
        'LocationID' => booker_location_id,
        'Email' => customer_data[:email],
        'Password' => customer_data[:password],
        'FirstName' => customer_data[:first_name],
        'LastName' => customer_data[:last_name],
        'HomePhone' => customer_data[:HomePhone],
        'CellPhone' => customer_data[:CellPhone],
        'AllowReceiveEmails' => customer_data[:AllowReceiveEmails],
        'AllowReceiveSMS' => customer_data[:AllowReceiveSMS]
      }, options)
    end

    def update_customer(customer_id, customer_data, custom_access_token = {})
      put "/customer/#{customer_id}", build_params(customer_data, custom_access_token)
    end

    def login(booker_location_id, email, password, options: {})
      post '/customer/login', build_params({
        'LocationID' => booker_location_id,
        'Email' => email,
        'Password' => password
      }, options.merge({
        client_id: self.client_id,
        client_secret: self.client_secret
      }))
    end

    def forgot_password(booker_location_id, email, first_name, base_url, options: {})
      post '/forgot_password/custom', build_params({
        'LocationID' => booker_location_id,
        'Email' => email,
        'Firstname' => first_name,
        'BaseUrlOfHost' => base_url
      }, options)
    end

    def reset_password(key, password, options: {})
      post '/password/reset', build_params({
        'Key' => key,
        'Password' => password
      }, options)
    end
  end
end
