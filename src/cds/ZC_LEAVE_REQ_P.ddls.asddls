@EndUserText.label: 'Leave Request Projection'

@UI.headerInfo: {
  typeName: 'Leave Request',
  typeNamePlural: 'Leave Requests',
  title: {
    type: #STANDARD,
    value: 'leave_request_id'
  }
}

@UI.presentationVariant: [{
  sortOrder: [{
    by: 'leave_request_id',
    direction: #ASC
  }]
}]

define root view entity ZC_LEAVE_REQ_P
  provider contract transactional_query
  as projection on ZC_LEAVE_REQ
{
  @UI.facet: [{
    id: 'LeaveRequest',
    purpose: #STANDARD,
    type: #IDENTIFICATION_REFERENCE,
    label: 'Leave Request',
    position: 10
  }]

  @UI.lineItem: [{ position: 10 }]
  @UI.identification: [{
    position: 10,
    label: 'Leave Request ID'
  }]
  key leave_request_id,

  @UI.lineItem: [{ position: 20 }]
  @UI.identification: [{
    position: 20,
    label: 'Employee ID'
  }]
  employee_id,

  @UI.lineItem: [{ position: 30 }]
  @UI.identification: [{
    position: 30,
    label: 'Leave Type'
  }]
  leave_type,

  @UI.lineItem: [{ position: 40 }]
  @UI.identification: [{
    position: 40,
    label: 'Start Date'
  }]
  start_date,

  @UI.lineItem: [{ position: 50 }]
  @UI.identification: [{
    position: 50,
    label: 'End Date'
  }]
  end_date,

  @UI.lineItem: [{ position: 60 }]
  @UI.identification: [{
    position: 60,
    label: 'Reason'
  }]
  reason,

  @UI.lineItem: [
    { position: 70 },
    {
      type: #FOR_ACTION,
      dataAction: 'Approve',
      label: 'Approve',
      position: 90
    },
    {
      type: #FOR_ACTION,
      dataAction: 'Reject',
      label: 'Reject',
      position: 100
    }
  ]

  @UI.identification: [
    {
      position: 70,
      label: 'Status'
    },
    {
      type: #FOR_ACTION,
      dataAction: 'Approve',
      label: 'Approve',
      position: 90
    },
    {
      type: #FOR_ACTION,
      dataAction: 'Reject',
      label: 'Reject',
      position: 100
    }
  ]
  status,

  @UI.lineItem: [{ position: 80 }]
  @UI.identification: [{
    position: 80,
    label: 'Last Changed At'
  }]
  last_changed_at
}
