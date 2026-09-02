@EndUserText.label: 'Employee Leave Management Service'
define service ZUI_LEAVE {
  expose ZC_LEAVE_REQ_P   as LeaveRequest;
  expose ZC_LEAVE_SUMMARY as LeaveSummary;
}
