# SAP ABAP Cloud – Employee Leave Request Management

A cloud-ready employee leave request management application developed using
SAP ABAP Cloud, RAP (RESTful Application Programming Model), CDS, OData V4,
and SAP Fiori Elements.

## Project Overview

The application manages employee leave requests through a RAP-based business
object exposed as an OData V4 UI service.

Employees and leave requests are stored in custom database tables.
The RAP business object provides transactional processing, validation,
draft handling, and approval/rejection actions.

A separate analytical summary provides leave-request counts by employee.

## Business Problem

Manual leave-request processing can make it difficult to track:

- Employee leave requests
- Request status
- Pending approvals
- Approved requests
- Rejected requests
- Overall request counts by employee

This application provides a centralized leave-request management process
with a Fiori Elements user interface.

## Main Features

### Leave Request Management

The application supports:

- Create leave request
- Read leave request
- Update leave request
- Delete leave request
- Draft handling
- Leave request validation
- Approve leave request
- Reject leave request
- Automatic initial status

### Validation

The RAP validation checks:

- Employee ID is mandatory
- Employee ID must exist in the employee master table
- Leave type is mandatory
- Start date is mandatory
- End date is mandatory
- End date cannot be before start date
- Reason is mandatory

### Approval Workflow

A newly created leave request receives:

`PENDING`

A pending request can be:

`PENDING → APPROVED`

or:

`PENDING → REJECTED`

Approve and Reject actions are restricted to pending requests.

Already approved or rejected requests cannot be approved or rejected again.

## Leave Request Data

The main leave request contains:

- Leave Request ID
- Employee ID
- Leave Type
- Start Date
- End Date
- Reason
- Status
- Last Changed At

## Leave Summary

The application provides an employee-level leave summary containing:

- Employee ID
- Total Requests
- Approved
- Pending
- Rejected

The summary is calculated from leave-request data.

An AMDP table function is used to calculate the summary data.

## Technology Stack

- SAP ABAP Cloud
- ABAP RESTful Application Programming Model (RAP)
- Core Data Services (CDS)
- ABAP Managed Database Procedures (AMDP)
- SQLScript
- OData V4
- SAP Fiori Elements
- Eclipse / ABAP Development Tools (ADT)
- SAP HANA Cloud

## Architecture

```text
Database Tables
       |
       v
CDS Data Model
       |
       v
RAP Behavior Definition
       |
       v
Behavior Implementation
       |
       v
Projection / Transactional Query
       |
       v
Service Definition
       |
       v
OData V4 UI Service Binding
       |
       v
SAP Fiori Elements
