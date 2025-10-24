# Shop-Verse API

## Overview
Shop-Verse API is a backend service for an e-commerce platform that supports multiple user roles including customers, brand owners, and super admins. It provides RESTful endpoints for product browsing, order management, user authentication, and administrative functions. The API uses JWT-based authentication with Devise and role-based authorization with Pundit (though custom role checks are primarily used).

## Ruby and Rails Versions
- Ruby: 3.2.4
- Rails: ~> 7.1.3

## System Dependencies
- PostgreSQL as the primary database
- Redis or other services for caching and job queues (configured via solid_cache, solid_queue, solid_cable gems)
- Docker for containerized deployment (optional)

## Configuration
- Database connection configured in `config/database.yml`
- CORS configured in `config/initializers/cors.rb`
- Devise configured with JWT in `config/initializers/devise.rb`
- Pundit included for authorization but custom role checks are used in controllers

## Database Setup
- Run migrations with `rails db:migrate`
- Seed initial data with `rails db:seed`
- `rails db:seed` To run the seed file

## Authentication and Authorization
- Authentication via Devise with JWT tokens (`devise-jwt` gem)
- Users have roles: `super_admin`, `brand_owner`, `customer`
- Authorization primarily via custom role checks in controllers (e.g., `current_user.has_role?(:brand_owner)`)
- Pundit is included but policies are mostly placeholders

## API Endpoints

### Authentication
- Brand and customer signup and login endpoints
- OTP verification and resend endpoints for two-factor authentication

### Public Endpoints (No Authentication)
- Browse products, categories, and brands

### Customer Endpoints
- Cart management: add, update, remove items, clear cart
- Order management: create orders, view orders and order details

### Brand Owner Endpoints
- Manage products: create, update, delete, update stock and status
- View brand dashboard with metrics and recent orders
- Manage orders related to their brand products

### Super Admin Endpoints
- Manage users: list, view, update status
- View metrics on users and orders
- Manage brands

## Models and Relationships
- User: belongs to UserRole, has many OTPs, has one Brand or Customer profile
- Brand: belongs to User (brand owner), has many Products
- Customer: belongs to User, has many Orders
- Product: belongs to Brand and Category
- Order: belongs to Customer, has many OrderItems
- OrderItem: belongs to Order and Product
- UserRole: defines roles like super_admin, brand_owner, customer
- OTP: for one-time password verification

## Pagination and Serialization
- Pagination implemented with Kaminari gem for product listings
- JSON serialization handled with ActiveModelSerializers

## Mailers and Background Jobs
- OTPMailer, RegistrationMailer, UserMailer for email notifications
- Background jobs configured (app/jobs) for asynchronous processing

