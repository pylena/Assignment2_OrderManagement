# Amazon.sa Order Management System

## Part 1:
### Database Structure:
- The schema is well-structured, eliminating redundancy and ensuring data integrity.
- Foreign keys enforce referential integrity (e.g., if a User is deleted, their Orders are also removed).

### ✅ 1NF Applied:
- All attributes in each table are atomic (e.g., Email in Users is a single value, not multiple).
- A Primary Key uniquely identifies each row in every table.

### ✅ 2NF Applied:
- `OrderDetails` was created to eliminate partial dependency between Orders and Products.

### ✅ 3NF Applied:
- No transitive dependency:  
  - **Users table:** Email depends only on UserID.  
  - **Orders table:** Status depends only on OrderID, avoiding unnecessary dependency.  
  - **OrderDetails:** SubTotal is stored for quick access but can be derived as `Quantity * Price`.

## Part 2:
[Visit this repo](https://github.com/pylena/Amazon_Java.git)

### Part 3:
[Visit this repo](#)


