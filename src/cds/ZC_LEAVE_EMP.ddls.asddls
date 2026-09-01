@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employee Master CDS View'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZC_LEAVE_EMP
  as select from zemp_leave_emp
{
  key employee_id,
      employee_name,
      email,
      manager_id,
      department
}
