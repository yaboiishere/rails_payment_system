# Payment Platform – Ruby on Rails 8

A secure and extensible payment processing system built with Rails 8.

This platform supports:

- Admin and Merchant roles (STI-based)
- Four types of transactions: Authorize, Charge, Refund, Reversal
- Trailblazer operations for business logic
- JWT-secured API
- Bootstrap + Slim UI
- RSpec + Capybara test suite
- Redis and Sidekiq for background jobs

---

## Use Case

This platform is suited for real-time or short-term payment flows such as:

- **One-time purchases**
- **Digital content access**
- **Time-limited reservations**
- **Microtransactions**

### Supported Transaction Lifecycle:

- **Authorize**: Temporarily holds funds to verify the payment.
- **Charge**: Captures the authorized funds if the product or service is delivered.
- **Refund**: Returns funds if the delivery is canceled or fails within 1 hour.
- **Reversal**: Cancels an unused authorization (e.g., user cancels or times out).

Because transactions **are auto-pruned after an hour**, this model is great for use cases where:

---

## Setup

### Requirements (Non-Docker)

Make sure you have the following:

- Ruby 3.2+
- Rails 8
- **PostgreSQL** (for the database)
- **Redis** (optional: for jobs or ActionCable)
- Chrome (for Capybara system tests)

### 1. Install dependencies

```bash
bundle install
```

### 2. Install JavaScript dependencies

```bash
yarn install
```

### 3. Create and migrate the database

```bash
rails db:setup
```

### 4. Run the server

```bash
bin/dev
# or
rails server
```

The application will be available at `http://localhost:3000`.

### 5. Run Sidekiq

In another terminal, start Sidekiq to process background jobs:

```bash
bundle exec sidekiq
```

---

## Docker Setup

### Requirements (Docker)

Make sure you have Docker and Docker Compose installed.

### 1. Run docker-compose

```bash
docker-compose up
```

This will start the application, database, and Redis in containers.

### 2. Run migrations

```bash
docker-compose run web rails db:setup
```

The application will be available on `http://localhost:3000`.

---

## User Roles

| Role     | Description                                 |
|----------|---------------------------------------------|
| Admin    | Manages the merchants                       |
| Merchant | Create transactions and edit their profiles |

Implemented using Single Table Inheritance (STI), both roles inherit from the `User` model.

--- 

## Transaction Types

All transaction types inherit from Transaction and support parent/child relationships:

| Type      | Description                                  | Parent Type |
|-----------|----------------------------------------------|-------------|
| Authorize | Authorizes a payment method without charging | None        |
| Charge    | Captures funds from an authorization         | Authorize   |
| Refund    | Returns funds from a charge                  | Charge      |
| Reversal  | Cancels an authorization                     | Authorize   |

Transactions auto-expire after 1 hour and can have one of four statuses: approved, error, refunded, or reversed.

---

## Authentication

The system can be pre-seeded with test users:

- **Email**: `admin@payemnt.com`
- **Password**: `Password@123`

And a few merchants:

- **Email**: `merchant<id>@payemnt.com`
- **Password**: `Password@123`

## Testing

To run all tests, use:

```bash
bundle exec rspec
```

To run just the system tests with Capybara, ensure you have a Chrome browser installed and run:

```bash
bundle exec rspec spec/system
```

If using Docker, you can run tests inside the container, keeping in mind that the system tests require a browser:

```bash
docker-compose run web bundle exec rspec
```

Tests include:

- Unit tests for models and operations
- System tests for user interface interactions with Capybara
- Requests andJWT authentication for API endpoints
- CSV import with rollback on failure

## API Documentation

Swagger docs are available at:

```
http://localhost:3000/api-docs
```

Includes full request/response formats, schemas, auth requirements, and status codes.

## API Usage

### Authentication

```http request
POST /api/v1/session
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "Secret123@"
}
```

##### Response

```http response
HTTP/1.1 200 OK
{
  "token": "your.jwt.token"
}
```

### Create a Transaction

> All POST requests require an Idempotency-Key header.

```http request
POST /api/v1/transactions
Authorization: Bearer your.jwt.token
Content-Type: application/json
Idempotency-Key: UUID

{
  "type": "charge",
  "merchant_id": 1,
  "parent_transaction_uuid": "UUID",
  "amount": 100.0,
  "customer_email": "client@example.com",
  "customer_phone": "1234567890"
}
```

##### Response

```http response
HTTP/1.1 201 Created
{
    "uuid": "UUID",
    "parent_transaction_uuid": "UUID",
    "type": "charge",
    "amount": 100.0,
    "status": "pending",
    "customer_email": "client@example.com",
    "customer_phone": "1234567890",
    "merchant_id": 1,
    "created_at": "2023-10-01T12:00:00Z"
}
```

### CSV Import

The following headers are expected:

```csv
email,name,status,type,password
```

Run import:

```bash
rake users:import:csv[users.csv]
```

Or if you are using zsh (which requires escaping the square brackets) this is also valid:

```bash
rake users:import:csv -- -f users.csv
```

The import will rollback if any row fails, ensuring data integrity.

## Architecture

The application follows a modular architecture with the following key components:

- `app/models`: ActiveRecord models for database interactions.
- `app/concepts`: Trailblazer operations for business logic.
- `app/services`: Service objects for encapsulating business logic.
- `app/controllers`: Controllers for handling web requests and API endpoints.
- `app/views`: Slim templates for rendering HTML views.
- `app/forms`: Form objects for handling form submissions.
- `app/presenters`: Presenters for formatting data for views.
- `app/jobs`: Background jobs for processing tasks asynchronously.
- `app/helpers`: Helper methods for views and controllers.
- `swaggger/v1`: Swagger documentation for API endpoints.
- `spec`: RSpec tests for unit and system testing.

## UI Stack

- Rails 8 + Slim for templating
- Bootstrap 5 for styling
- Turbo & Stimulus for JavaScript interactions
- Capybara for system tests

