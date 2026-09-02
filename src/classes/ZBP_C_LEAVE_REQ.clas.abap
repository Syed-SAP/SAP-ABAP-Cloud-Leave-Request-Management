CLASS lhc_zc_leave_req DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_create
      FOR NUMBERING
      IMPORTING entities FOR CREATE LeaveRequest.

    METHODS set_initial_status
      FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LeaveRequest~set_initial_status.

    METHODS validate_leave_request
      FOR VALIDATE ON SAVE
      IMPORTING keys FOR LeaveRequest~validate_leave_request.

    METHODS get_instance_authorizations
      FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR LeaveRequest
      RESULT result.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR LeaveRequest
      RESULT result.

    METHODS approve
      FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~Approve
      RESULT result.

    METHODS reject
      FOR MODIFY
      IMPORTING keys FOR ACTION LeaveRequest~Reject
      RESULT result.

ENDCLASS.

CLASS lhc_zc_leave_req IMPLEMENTATION.


  METHOD earlynumbering_create.

    DATA:
      lv_max_number TYPE i VALUE 0,
      lv_number     TYPE i,
      lv_id         TYPE zemp_leave_req-leave_request_id.


    "----------------------------------------------------------
    " Get existing Leave Request IDs
    "----------------------------------------------------------

    SELECT leave_request_id
      FROM zemp_leave_req
      INTO TABLE @DATA(lt_existing).


    "----------------------------------------------------------
    " Find highest existing LR number
    "----------------------------------------------------------

    LOOP AT lt_existing INTO DATA(ls_existing).

      IF ls_existing-leave_request_id IS INITIAL.
        CONTINUE.
      ENDIF.

      IF strlen( ls_existing-leave_request_id ) <= 2.
        CONTINUE.
      ENDIF.

      TRY.

          DATA(lv_existing_number) =
            CONV i(
              substring(
                val = ls_existing-leave_request_id
                off = 2
              )
            ).

          IF lv_existing_number > lv_max_number.
            lv_max_number = lv_existing_number.
          ENDIF.

        CATCH cx_sy_conversion_no_number.
          CONTINUE.

      ENDTRY.

    ENDLOOP.


    "----------------------------------------------------------
    " Start with next number
    "----------------------------------------------------------

    lv_number = lv_max_number + 1.


    "----------------------------------------------------------
    " Assign number to every CREATE entity
    "----------------------------------------------------------

    LOOP AT entities INTO DATA(ls_entity).

      IF ls_entity-leave_request_id IS INITIAL.

        lv_id =
          |LR{ lv_number WIDTH = 3 ALIGN = RIGHT PAD = '0' }|.

        APPEND VALUE #(

          %cid             = ls_entity-%cid
          %is_draft        = ls_entity-%is_draft
          leave_request_id = lv_id

        ) TO mapped-leaverequest.

        lv_number = lv_number + 1.

      ELSE.

        APPEND VALUE #(

          %cid             = ls_entity-%cid
          %is_draft        = ls_entity-%is_draft
          leave_request_id = ls_entity-leave_request_id

        ) TO mapped-leaverequest.

      ENDIF.

    ENDLOOP.

  ENDMETHOD.

    METHOD set_initial_status.

     MODIFY ENTITIES OF zc_leave_req IN LOCAL MODE
      ENTITY LeaveRequest
      UPDATE FIELDS ( status )
      WITH VALUE #(
        FOR key IN keys
        (
          %tky   = key-%tky
          status = 'PENDING'
        )
      )
      FAILED DATA(failed_status)
      REPORTED DATA(reported_status).

    ENDMETHOD.

  METHOD validate_leave_request.

    "----------------------------------------------------------
    " Read Leave Request data
    "----------------------------------------------------------

    READ ENTITIES OF zc_leave_req IN LOCAL MODE

      ENTITY LeaveRequest

      FIELDS (
        employee_id
        leave_type
        start_date
        end_date
        reason
      )

      WITH CORRESPONDING #( keys )

      RESULT DATA(leave_requests).


    "----------------------------------------------------------
    " Validate every Leave Request
    "----------------------------------------------------------

    LOOP AT leave_requests INTO DATA(leave_request).


      "--------------------------------------------------------
      " Employee ID - Mandatory
      "--------------------------------------------------------

      IF leave_request-employee_id IS INITIAL.

        APPEND VALUE #(

          %tky = leave_request-%tky

          %msg = new_message_with_text(

            severity = if_abap_behv_message=>severity-error

            text = 'Employee ID is mandatory'

          )

          %element-employee_id = if_abap_behv=>mk-on

        ) TO reported-leaverequest.

      ELSE.


        "------------------------------------------------------
        " Employee ID - Must Exist
        "------------------------------------------------------

        SELECT SINGLE employee_id

          FROM zemp_leave_emp

          WHERE employee_id = @leave_request-employee_id

          INTO @DATA(lv_employee_id).


        IF sy-subrc <> 0.

          APPEND VALUE #(

            %tky = leave_request-%tky

            %msg = new_message_with_text(

              severity = if_abap_behv_message=>severity-error

              text = 'Employee ID does not exist'

            )

            %element-employee_id = if_abap_behv=>mk-on

          ) TO reported-leaverequest.

        ENDIF.

      ENDIF.


      "--------------------------------------------------------
      " Leave Type - Mandatory
      "--------------------------------------------------------

      IF leave_request-leave_type IS INITIAL.

        APPEND VALUE #(

          %tky = leave_request-%tky

          %msg = new_message_with_text(

            severity = if_abap_behv_message=>severity-error

            text = 'Leave Type is mandatory'

          )

          %element-leave_type = if_abap_behv=>mk-on

        ) TO reported-leaverequest.

      ENDIF.


      "--------------------------------------------------------
      " Start Date - Mandatory
      "--------------------------------------------------------

      IF leave_request-start_date IS INITIAL.

        APPEND VALUE #(

          %tky = leave_request-%tky

          %msg = new_message_with_text(

            severity = if_abap_behv_message=>severity-error

            text = 'Start Date is mandatory'

          )

          %element-start_date = if_abap_behv=>mk-on

        ) TO reported-leaverequest.

      ENDIF.


      "--------------------------------------------------------
      " End Date - Mandatory
      "--------------------------------------------------------

      IF leave_request-end_date IS INITIAL.

        APPEND VALUE #(

          %tky = leave_request-%tky

          %msg = new_message_with_text(

            severity = if_abap_behv_message=>severity-error

            text = 'End Date is mandatory'

          )

          %element-end_date = if_abap_behv=>mk-on

        ) TO reported-leaverequest.

      ENDIF.


      "--------------------------------------------------------
      " Date Range Validation
      "--------------------------------------------------------

      IF leave_request-start_date IS NOT INITIAL
         AND leave_request-end_date IS NOT INITIAL.

        IF leave_request-end_date < leave_request-start_date.

          APPEND VALUE #(

            %tky = leave_request-%tky

            %msg = new_message_with_text(

              severity = if_abap_behv_message=>severity-error

              text = 'End Date cannot be before Start Date'

            )

            %element-end_date = if_abap_behv=>mk-on

          ) TO reported-leaverequest.

        ENDIF.

      ENDIF.


      "--------------------------------------------------------
      " Reason - Mandatory
      "--------------------------------------------------------

      IF leave_request-reason IS INITIAL.

        APPEND VALUE #(

          %tky = leave_request-%tky

          %msg = new_message_with_text(

            severity = if_abap_behv_message=>severity-error

            text = 'Reason is mandatory'

          )

          %element-reason = if_abap_behv=>mk-on

        ) TO reported-leaverequest.

      ENDIF.


    ENDLOOP.

  ENDMETHOD.



  METHOD get_instance_authorizations.

    "----------------------------------------------------------
    " Read current status
    "----------------------------------------------------------

    READ ENTITIES OF zc_leave_req IN LOCAL MODE

      ENTITY LeaveRequest

      FIELDS ( status )

      WITH CORRESPONDING #( keys )

      RESULT DATA(leave_requests).


    "----------------------------------------------------------
    " Approve / Reject only when PENDING
    "----------------------------------------------------------

    result = VALUE #(

      FOR leave_request IN leave_requests

      (

        %tky = leave_request-%tky

        %action-Approve =

          COND #(

            WHEN leave_request-status = 'PENDING'

            THEN if_abap_behv=>auth-allowed

            ELSE if_abap_behv=>auth-unauthorized

          )

        %action-Reject =

          COND #(

            WHEN leave_request-status = 'PENDING'

            THEN if_abap_behv=>auth-allowed

            ELSE if_abap_behv=>auth-unauthorized

          )

      )

    ).

  ENDMETHOD.



  METHOD get_global_authorizations.

    "----------------------------------------------------------
    " No global authorization rules
    "----------------------------------------------------------

    result = VALUE #( ).

  ENDMETHOD.



  METHOD approve.

    "----------------------------------------------------------
    " Read current status
    "----------------------------------------------------------

    READ ENTITIES OF zc_leave_req IN LOCAL MODE

      ENTITY LeaveRequest

      FIELDS ( status )

      WITH CORRESPONDING #( keys )

      RESULT DATA(leave_requests).


    "----------------------------------------------------------
    " Keep only PENDING requests
    "----------------------------------------------------------

    DATA(lt_valid_keys) = keys.

    CLEAR lt_valid_keys.


    LOOP AT leave_requests INTO DATA(leave_request).

      IF leave_request-status = 'PENDING'.

        APPEND VALUE #(

          %tky = leave_request-%tky

        ) TO lt_valid_keys.

      ELSE.

        "------------------------------------------------------
        " Request is already APPROVED or REJECTED
        "------------------------------------------------------

        APPEND VALUE #(

          %tky = leave_request-%tky

        ) TO failed-leaverequest.


        APPEND VALUE #(

          %tky = leave_request-%tky

          %msg = new_message_with_text(

            severity = if_abap_behv_message=>severity-error

            text = 'Only PENDING leave requests can be approved'

          )

        ) TO reported-leaverequest.

      ENDIF.

    ENDLOOP.


    "----------------------------------------------------------
    " Approve only PENDING requests
    "----------------------------------------------------------

    IF lt_valid_keys IS NOT INITIAL.

      MODIFY ENTITIES OF zc_leave_req IN LOCAL MODE

        ENTITY LeaveRequest

        UPDATE FIELDS ( status )

        WITH VALUE #(

          FOR key IN lt_valid_keys

          (

            %tky = key-%tky

            status = 'APPROVED'

          )

        )

        FAILED failed

        REPORTED reported.

    ENDIF.


    "----------------------------------------------------------
    " Read updated request
    "----------------------------------------------------------

    READ ENTITIES OF zc_leave_req IN LOCAL MODE

      ENTITY LeaveRequest

      ALL FIELDS

      WITH CORRESPONDING #( keys )

      RESULT DATA(updated_leave_requests).


    "----------------------------------------------------------
    " Return result
    "----------------------------------------------------------

    result = VALUE #(

      FOR ls_updated_request IN updated_leave_requests

      (

        %tky   = ls_updated_request-%tky
        %param = ls_updated_request

      )

    ).

  ENDMETHOD.



  METHOD reject.

    "----------------------------------------------------------
    " Read current status
    "----------------------------------------------------------

    READ ENTITIES OF zc_leave_req IN LOCAL MODE

      ENTITY LeaveRequest

      FIELDS ( status )

      WITH CORRESPONDING #( keys )

      RESULT DATA(leave_requests).


    "----------------------------------------------------------
    " Keep only PENDING requests
    "----------------------------------------------------------

    DATA(lt_valid_keys) = keys.

    CLEAR lt_valid_keys.


    LOOP AT leave_requests INTO DATA(leave_request).

      IF leave_request-status = 'PENDING'.

        APPEND VALUE #(

          %tky = leave_request-%tky

        ) TO lt_valid_keys.

      ELSE.

        "------------------------------------------------------
        " Request is already APPROVED or REJECTED
        "------------------------------------------------------

        APPEND VALUE #(

          %tky = leave_request-%tky

        ) TO failed-leaverequest.


        APPEND VALUE #(

          %tky = leave_request-%tky

          %msg = new_message_with_text(

            severity = if_abap_behv_message=>severity-error

            text = 'Only PENDING leave requests can be rejected'

          )

        ) TO reported-leaverequest.

      ENDIF.

    ENDLOOP.


    "----------------------------------------------------------
    " Reject only PENDING requests
    "----------------------------------------------------------

    IF lt_valid_keys IS NOT INITIAL.

      MODIFY ENTITIES OF zc_leave_req IN LOCAL MODE

        ENTITY LeaveRequest

        UPDATE FIELDS ( status )

        WITH VALUE #(

          FOR key IN lt_valid_keys

          (

            %tky = key-%tky

            status = 'REJECTED'

          )

        )

        FAILED failed

        REPORTED reported.

    ENDIF.


    "----------------------------------------------------------
    " Read updated request
    "----------------------------------------------------------

    READ ENTITIES OF zc_leave_req IN LOCAL MODE

      ENTITY LeaveRequest

      ALL FIELDS

      WITH CORRESPONDING #( keys )

      RESULT DATA(updated_leave_requests).


    "----------------------------------------------------------
    " Return result
    "----------------------------------------------------------

    result = VALUE #(

      FOR ls_updated_request IN updated_leave_requests

      (

        %tky   = ls_updated_request-%tky

        %param = ls_updated_request
      )

    ).

  ENDMETHOD.


ENDCLASS.
