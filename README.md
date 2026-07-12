# Hospital Management System

This is a database project built using Python (Flask), MySQL, and SQLAlchemy to manage a hospital's bookings, billing, and system audit logs.

## Core Features

- **User Accounts:** Users can sign up and log in as either a Doctor or a Patient.
- **Appointment Booking:** Patients can book slots with specific departments.
- **Database Constraints & Triggers:** 
  - **No Overbooking:** A trigger limits each department to a maximum of 5 bookings per slot, per day.
  - **Date Check:** Appointments cannot be booked on past dates.
  - **Data Validation:** Checks phone numbers (must be exactly 10 digits) and email formats before saving.
  - **Auto-Billing:** A database trigger automatically generates a $100 invoice for every new booking.
  - **Audit Logs:** Log tables keep track of patient profile updates, inserts, and deletions.
- **Search:** Search for doctor availability by name or department.


## User Accounts

You can register your own account on the **Signup** page of the web application, or use these pre-created accounts for testing:

- **Doctor Account:**
  - Email: `anees@gmail.com`
  - Password: `1234`
- **Patient Accounts:**
  - Email: `khushi@gmail.com`
  - Password: `1234`
  - Email: `aneeqah@gmail.com`
  - Password: `1234`
