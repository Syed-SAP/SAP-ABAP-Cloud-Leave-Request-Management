@EndUserText.label: 'Leave Request Summary AMDP'

@AccessControl.authorizationCheck: #NOT_REQUIRED

@ClientHandling.type: #CLIENT_DEPENDENT

@ClientHandling.algorithm: #SESSION_VARIABLE

define table function ZTF_LEAVE_SUMMARY

  returns
  {
    mandt      : abap.clnt;
    employee_id : abap.char(10);
    total_count : abap.int4;
    approved    : abap.int4;
    pending     : abap.int4;
    rejected    : abap.int4;
  }

  implemented by method
    ZCL_LEAVE_AMDP=>GET_LEAVE_SUMMARY;
