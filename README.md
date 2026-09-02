
# SAP ABAP Cloud – Employee Leave Request Management

A transactional employee leave management application built using **SAP ABAP Cloud, RAP, CDS, OData V4, and SAP Fiori Elements**.

The application allows leave requests to be created, validated, edited through draft handling, approved or rejected, and analyzed through an employee-level leave summary.

---

## Project Overview

The project demonstrates how to build a complete transactional business application using the **ABAP RESTful Application Programming Model (RAP)**.

The application models an employee leave-request process:

```text
Employee
   |
   | Create Leave Request
   v
Leave Request
   |
   | Validation
   v
PENDING
   |
   +----> APPROVED
   |
   +----> REJECTED
````

The transactional business object is exposed through an **OData V4 UI service** and consumed using **SAP Fiori Elements**.

A separate analytical summary provides leave-request counts by employee.

---

# Business Problem

Manual leave-request processing can make it difficult to:

* Maintain employee leave requests consistently
* Validate employee information
* Prevent invalid date ranges
* Track request status
* Control approval and rejection operations
* Maintain requests while they are still being edited
* Obtain an employee-level overview of leave statistics

This project provides a small RAP-based application to demonstrate how these requirements can be implemented in SAP ABAP Cloud.

---

# Solution

The application provides two main areas:

### 1. Leave Request Management

A transactional Fiori Elements application for:

* Creating leave requests
* Updating leave requests
* Deleting leave requests
* Draft editing
* Validating request data
* Automatically assigning leave request IDs
* Automatically setting new requests to `PENDING`
* Approving pending requests
* Rejecting pending requests
* Preventing approval/rejection of already processed requests

### 2. Leave Request Summary

An employee-level analytical view showing:

* Employee ID
* Total Requests
* Approved Requests
* Pending Requests
* Rejected Requests

The summary is calculated from the leave-request data.

---

# Key Technologies

| Technology                                       | Usage                            |
| ------------------------------------------------ | -------------------------------- |
| SAP ABAP Cloud                                   | Development platform             |
| ABAP RESTful Application Programming Model (RAP) | Transactional business object    |
| Core Data Services (CDS)                         | Data modeling and semantic views |
| Managed RAP BO                                   | Transactional processing         |
| Draft Handling                                   | Editing transactional data       |
| OData V4                                         | Service exposure                 |
| SAP Fiori Elements                               | UI                               |
| ABAP SQL                                         | Validation and database access   |
| SQLScript / AMDP                                 | Analytical table function        |
| Eclipse ADT                                      | Development environment          |
| SAP HANA                                         | Database platform                |

---

# Architecture

```text
                    SAP Fiori Elements
                           |
                           v
                     OData V4 UI
                           |
                           v
                    ZUI_LEAVE_O4
                           |
                           v
                       ZUI_LEAVE
                    Service Definition
                           |
                           v
                     ZC_LEAVE_REQ_P
                  Projection / UI Layer
                           |
                           v
                      ZC_LEAVE_REQ
                  Transactional CDS View
                           |
                           v
                  RAP Behavior Definition
                           |
                           v
                 Behavior Implementation
                  ZBP_C_LEAVE_REQ
                           |
                           v
                    Database Tables
                           |
              +------------+------------+
              |                         |
              v                         v
       ZEMP_LEAVE_EMP             ZEMP_LEAVE_REQ
       Employee Master            Leave Requests
```

Analytical path:

```text
ZEMP_LEAVE_REQ
       |
       v
ZCL_LEAVE_AMDP
       |
       v
ZTF_LEAVE_SUMMARY
       |
       v
ZC_LEAVE_SUMMARY
       |
       v
Leave Request Summary
```

---

# Data Model

## Employee Master

Database table:

```text
ZEMP_LEAVE_EMP
```

Stores employee master information used during leave-request validation.

Main fields:

```text
employee_id
employee_name
email
manager_id
department
```

---

## Leave Request

Database table:

```text
ZEMP_LEAVE_REQ
```

Stores transactional leave-request data.

Main fields:

```text
leave_request_id
employee_id
leave_type
start_date
end_date
reason
status
last_changed_at
```

Example status values:

```text
PENDING
APPROVED
REJECTED
```

---

## Draft Leave Request

Database table:

```text
ZEMP_LEAVE_REQ_D
```

Used for RAP draft handling of the leave-request business object.

---

# CDS Data Model

## Employee CDS View

```text
ZC_LEAVE_EMP
```

Provides the employee master data for consumption by the application.

---

## Transactional CDS View

```text
ZC_LEAVE_REQ
```

Root CDS view entity for the leave-request business object.

It is based on:

```text
ZEMP_LEAVE_REQ
```

The view exposes:

```text
leave_request_id
employee_id
leave_type
start_date
end_date
reason
status
last_changed_at
```

---

## Projection CDS View

```text
ZC_LEAVE_REQ_P
```

Projection layer for the transactional application.

It provides:

* UI metadata
* List fields
* Identification fields
* Approve action
* Reject action
* Transactional projection

The projection uses:

```text
provider contract transactional_query
```

---

## Leave Summary CDS View

```text
ZC_LEAVE_SUMMARY
```

Provides employee-level leave statistics.

The view calculates:

```text
Total Requests
Approved
Pending
Rejected
```

using aggregation and conditional expressions.

Example calculation concept:

```text
COUNT(*)                         -> Total Requests

status = 'APPROVED'              -> Approved

status = 'PENDING'               -> Pending

status = 'REJECTED'              -> Rejected
```

The data is grouped by:

```text
employee_id
```

---

## Table Function

```text
ZTF_LEAVE_SUMMARY
```

Defines the result structure for the AMDP-based analytical calculation.

It returns:

```text
mandt
employee_id
total_count
approved
pending
rejected
```

---

# RAP Behavior

## Behavior Definition

```text
ZC_LEAVE_REQ
```

The business object uses:

```text
managed implementation
strict ( 2 )
with draft
```

The RAP behavior supports:

```text
create
update
delete
```

and the following custom actions:

```text
Approve
Reject
```

---

# Draft Handling

The application uses RAP draft processing.

Draft handling allows users to work on a leave request before activating the final transaction.

The projection behavior enables draft operations such as:

```text
Activate
Discard
Edit
Resume
Prepare
```

This demonstrates the RAP draft lifecycle rather than treating every UI change as an immediate database transaction.

---

# Business Logic

The behavior implementation is:

```text
ZBP_C_LEAVE_REQ
```

The local handler implements the following logic.

---

## 1. Early Numbering

Method:

```text
earlynumbering_create
```

Automatically generates leave-request IDs when a new request is created.

The generated ID follows the format:

```text
LR001
LR002
LR003
...
```

The implementation checks existing leave-request IDs and determines the next available numeric value.

Example:

```text
Existing:
LR001
LR002
LR003

Next:
LR004
```

---

# 2. Initial Status Determination

Method:

```text
set_initial_status
```

New leave requests are automatically assigned:

```text
PENDING
```

This prevents newly created requests from appearing as already approved or rejected.

---

# 3. Leave Request Validation

Method:

```text
validate_leave_request
```

The application validates the following conditions.

### Employee ID

Employee ID is mandatory.

If supplied, the employee is checked against:

```text
ZEMP_LEAVE_EMP
```

If the employee does not exist, the request is rejected with an error message.

---

### Leave Type

Leave type is mandatory.

---

### Start Date

Start date is mandatory.

---

### End Date

End date is mandatory.

---

### Date Range

The application checks:

```text
End Date >= Start Date
```

An invalid request such as:

```text
Start Date: 10-Sep-2026
End Date:   08-Sep-2026
```

is rejected.

---

### Reason

Leave reason is mandatory.

---

# 4. Instance Authorization

The behavior implementation checks the current leave-request status before allowing actions.

Approve and Reject are allowed only when:

```text
status = PENDING
```

For example:

```text
PENDING   -> Approve allowed
PENDING   -> Reject allowed

APPROVED  -> Approve not allowed
APPROVED  -> Reject not allowed

REJECTED  -> Approve not allowed
REJECTED  -> Reject not allowed
```

This prevents a processed leave request from being processed again through the exposed actions.

---

# 5. Approve Action

Action:

```text
Approve
```

The action:

1. Reads the current request status
2. Checks whether the request is `PENDING`
3. Rejects the operation if it is already processed
4. Updates the status to:

```text
APPROVED
```

5. Reads the updated request
6. Returns the updated business-object instance

---

# 6. Reject Action

Action:

```text
Reject
```

The action follows the same controlled process.

A request can be rejected only when:

```text
status = PENDING
```

The status is then changed to:

```text
REJECTED
```

---

# Authorization Design

The current implementation contains instance-level action authorization based on the leave-request status.

The important rule is:

```text
Only PENDING requests can be approved or rejected.
```

Global authorization currently does not implement additional business restrictions.

Therefore, this project should **not** be described as a complete enterprise role-based authorization solution.

---

# Analytical Processing

The analytical summary uses an AMDP table function.

Class:

```text
ZCL_LEAVE_AMDP
```

The class implements:

```text
IF_AMDP_MARKER_HDB
```

and provides the table-function implementation for:

```text
ZTF_LEAVE_SUMMARY
```

The calculation is performed using SQLScript.

The result is grouped by:

```text
employee_id
```

and calculates:

```text
COUNT(*)                         -> total_count

APPROVED records                 -> approved

PENDING records                  -> pending

REJECTED records                 -> rejected
```

The client is obtained using:

```text
session_context( 'CLIENT' )
```

---

# OData V4 Service

## Service Definition

```text
ZUI_LEAVE
```

The service definition exposes the application entities for service consumption.

---

## Service Binding

```text
ZUI_LEAVE_O4
```

Binding type:

```text
OData V4 - UI
```

The service binding was published from SAP ABAP Development Tools (ADT).

Exposed application entities include:

```text
LeaveRequest
LeaveSummary
```

The service was tested using the Fiori Elements preview available from ADT.

---

# SAP Fiori Elements

The application uses metadata-driven SAP Fiori Elements instead of implementing a custom frontend from scratch.

UI annotations are used to control:

* List columns
* Identification fields
* Labels
* Header information
* Sorting
* Selection fields
* Actions

The transactional list provides actions such as:

```text
Create
Delete
Approve
Reject
```

depending on the current business-object state and authorization.

---

# Application Screens

## Leave Request List

The transactional application displays:

```text
Leave Request ID
Employee ID
Leave Type
Start Date
End Date
Reason
Status
```

Example application functionality:

* Create a request
* Edit a request
* Delete a request
* Approve a pending request
* Reject a pending request
* Work with drafts
* Display validation errors

![Leave Request List](docs/screenshots/leave-request-list.png)

---

## Leave Request Summary

The summary application displays employee-level statistics:

```text
Employee ID
Total Requests
Approved
Pending
Rejected
```

![Leave Request Summary](docs/screenshots/leave-request-summary.png)

---

# Repository Structure

```text
SAP-ABAP-Cloud-Leave-Request-Management/
│
├── README.md
│
├── leave-request-list.png
|   leave-request-summary.png
│
└── src/
    │
    ├── behavior/
    │   ├── ZC_LEAVE_REQ.bdef.abap
    │   └── ZC_LEAVE_REQ_P.bdef.abap
    │
    ├── cds/
    │   ├── ZC_LEAVE_EMP.ddls.abap
    │   ├── ZC_LEAVE_REQ.ddls.abap
    │   ├── ZC_LEAVE_REQ_P.ddls.abap
    │   ├── ZC_LEAVE_SUMMARY.ddls.abap
    │   └── ZTF_LEAVE_SUMMARY.ddls.abap
    │
    ├── classes/
    │   ├── ZBP_C_LEAVE_REQ.abap
    │   ├── ZCL_LEAVE_AMDP.abap
    │   └── ZCL_LEAVE_TEST_DATA.abap
    │
    ├── database/
    │   ├── ZEMP_LEAVE_EMP.ddls.asddls
    │   ├── ZEMP_LEAVE_REQ.ddls.asddls
    │   └── ZEMP_LEAVE_REQ_D.ddls.asddls
    │
    └── services/
        └── service-definition/
            └── ZUI_LEAVE.srvd.abap
```

The actual ADT service binding:

```text
ZUI_LEAVE_O4
```

is created and published in the SAP ABAP Cloud system.

Its configuration is documented under:

```text
src/services/service-binding/
```

---

# Test Data

Test data is inserted using:

```text
ZCL_LEAVE_TEST_DATA
```

The class implements:

```text
IF_OO_ADT_CLASSRUN
```

and can be executed from ADT to insert sample leave-request data.

The test data covers different employees, leave types, dates, reasons, and statuses.

It also includes an invalid date-range example to support validation testing.

---

# Validation Scenarios Tested

The application was designed to validate scenarios such as:

| Scenario                   | Expected Result |
| -------------------------- | --------------- |
| Missing Employee ID        | Error           |
| Unknown Employee ID        | Error           |
| Missing Leave Type         | Error           |
| Missing Start Date         | Error           |
| Missing End Date           | Error           |
| End Date before Start Date | Error           |
| Missing Reason             | Error           |
| Valid Leave Request        | Accepted        |
| New Request                | PENDING         |
| Approve PENDING request    | APPROVED        |
| Reject PENDING request     | REJECTED        |
| Approve APPROVED request   | Not allowed     |
| Reject REJECTED request    | Not allowed     |

---

# RAP Object Flow

The transactional request follows this flow:

```text
Fiori Elements
      |
      v
OData V4
      |
      v
Projection View
ZC_LEAVE_REQ_P
      |
      v
Root View
ZC_LEAVE_REQ
      |
      v
Behavior Definition
      |
      v
ZBP_C_LEAVE_REQ
      |
      +----------------------+
      |                      |
      v                      v
Validation             Actions
      |                Approve / Reject
      |                      |
      +----------+-----------+
                 |
                 v
          ZEMP_LEAVE_REQ
```

---

# What This Project Demonstrates

This project demonstrates practical knowledge of:

### ABAP Cloud

* Cloud-compatible ABAP development
* Eclipse ADT development
* ABAP SQL
* ABAP Objects

### RAP

* Managed RAP
* Behavior definitions
* Behavior implementations
* Business object lifecycle
* Draft handling
* Determinations
* Validations
* Actions
* Instance authorization
* Early numbering
* Transactional projections

### CDS

* CDS view entities
* Root view entities
* Projection views
* CDS annotations
* UI annotations
* Aggregation
* Conditional aggregation
* Table functions

### OData

* OData V4 service definition
* OData V4 UI service binding
* Service exposure

### Fiori Elements

* Metadata-driven UI
* List report
* Object-page style transactional processing
* UI annotations
* Actions

### HANA / SQLScript

* AMDP
* SQLScript
* Table functions
* Aggregation
* `CASE` expressions
* Client handling

---

# Project Scope

## Included

* Employee master data
* Leave-request management
* RAP transactional processing
* Draft handling
* Request validation
* Automatic request numbering
* Status determination
* Approve action
* Reject action
* Instance action authorization
* Employee-level summary
* AMDP analytical processing
* OData V4 UI service
* Fiori Elements UI
* Test data class

## Not Included

The current version does **not** implement:

* Email notifications
* SAP Business Workflow
* Multi-level approval hierarchy
* Manager-specific authorization
* Integration with SuccessFactors
* Integration with SAP HCM
* Calendar integration
* Leave balance calculation
* Payroll integration
* Production-grade role design
* External REST API integrations
* Mobile-specific application development

These are outside the current project scope.

---

# Limitations

This is a portfolio/learning implementation rather than a production HR system.

The current authorization logic primarily controls whether Approve and Reject actions are permitted based on request status.

It does not implement a complete organizational authorization model where a manager can approve only employees assigned to that manager.

The application also does not calculate actual employee leave balances.

---

# Development Environment

Developed using:

```text
SAP ABAP Cloud
Eclipse
ABAP Development Tools (ADT)
SAP HANA Cloud / SAP HANA database environment
SAP Fiori Elements
```

---

# Project Objective

The primary objective was to build a complete end-to-end SAP ABAP Cloud application rather than isolated ABAP examples.

The project covers the flow from:

```text
Database
    ↓
CDS
    ↓
RAP Behavior
    ↓
ABAP Behavior Implementation
    ↓
OData V4
    ↓
Fiori Elements
```

It also demonstrates a separate analytical path using:

```text
Database
    ↓
AMDP / SQLScript
    ↓
Table Function
    ↓
CDS Summary View
    ↓
Fiori Elements
```

---

# Key Learning Outcomes

Through this project, the following practical concepts were implemented:

1. Designing database tables for a business scenario
2. Building CDS view entities
3. Creating a managed RAP business object
4. Implementing draft handling
5. Implementing RAP validations
6. Implementing determinations
7. Implementing custom actions
8. Implementing instance authorization
9. Implementing early numbering
10. Exposing RAP through OData V4
11. Building a Fiori Elements UI through annotations
12. Implementing analytical processing with AMDP
13. Creating an ABAP Cloud test-data utility
14. Organizing the project into a maintainable source structure


---

# Status

```text
Development Status: Completed functional prototype
Platform: SAP ABAP Cloud
UI: SAP Fiori Elements
Service: OData V4
Architecture: RAP
```


