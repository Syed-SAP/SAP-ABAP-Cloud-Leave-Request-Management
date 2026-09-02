CLASS zcl_leave_test_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun.

    CLASS-METHODS insert_data.

ENDCLASS.


CLASS zcl_leave_test_data IMPLEMENTATION.

  METHOD insert_data.

    INSERT zleave_req FROM TABLE @(
      VALUE #(

        ( request_id = 'REQ001'
          emp_id     = '100001'
          leave_type = 'Annual'
          start_date = '20260901'
          end_date   = '20260903'
          reason     = 'Personal work'
          status     = 'PENDING' )

        ( request_id = 'REQ002'
          emp_id     = '100002'
          leave_type = 'Sick'
          start_date = '20260905'
          end_date   = '20260906'
          reason     = 'Not feeling well'
          status     = 'PENDING' )

        ( request_id = 'REQ003'
          emp_id     = '100003'
          leave_type = 'Casual'
          start_date = '20260910'
          end_date   = '20260908'
          reason     = 'Personal work'
          status     = 'PENDING' )

      )
    ).

    COMMIT WORK.

  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.

    insert_data( ).

    out->write( 'Test leave data inserted successfully.' ).

  ENDMETHOD.

ENDCLASS.
