@EndUserText.label: 'Leave Request Summary'
@AccessControl.authorizationCheck: #NOT_REQUIRED

@UI.headerInfo: {
  typeName: 'Leave Request Summary',
  typeNamePlural: 'Leave Request Summaries',
  title: {
    type: #STANDARD,
    value: 'employee_id'
  }
}

@UI.presentationVariant: [{
  sortOrder: [{
    by: 'employee_id',
    direction: #ASC
  }]
}]

define view entity ZC_LEAVE_SUMMARY
  as select from zemp_leave_req
{
  @EndUserText.label: 'Employee ID'
  @UI.selectionField: [{ position: 10 }]
  @UI.lineItem: [{ position: 10 }]
  @UI.identification: [{ position: 10 }]
  key employee_id,

  @EndUserText.label: 'Total Requests'
  @UI.selectionField: [{ position: 20 }]
  @UI.lineItem: [{ position: 20 }]
  @UI.identification: [{ position: 20 }]
  count( * ) as total_count,

  @EndUserText.label: 'Approved'
  @UI.selectionField: [{ position: 30 }]
  @UI.lineItem: [{ position: 30 }]
  @UI.identification: [{ position: 30 }]
  sum(
    case
      when status = 'APPROVED' then 1
      else 0
    end
  ) as approved,

  @EndUserText.label: 'Pending'
  @UI.selectionField: [{ position: 40 }]
  @UI.lineItem: [{ position: 40 }]
  @UI.identification: [{ position: 40 }]
  sum(
    case
      when status = 'PENDING' then 1
      else 0
    end
  ) as pending,

  @EndUserText.label: 'Rejected'
  @UI.selectionField: [{ position: 50 }]
  @UI.lineItem: [{ position: 50 }]
  @UI.identification: [{ position: 50 }]
  sum(
    case
      when status = 'REJECTED' then 1
      else 0
    end
  ) as rejected

}
group by employee_id;
