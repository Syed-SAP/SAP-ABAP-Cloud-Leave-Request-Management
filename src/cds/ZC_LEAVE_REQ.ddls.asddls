@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Leave Request CDS View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZC_LEAVE_REQ
  as select from zemp_leave_req
{
  key leave_request_id,
      employee_id,
      leave_type,
      start_date,
      end_date,
      reason,
      status,

      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at
}
