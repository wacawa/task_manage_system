class Form::Task < Task
  REGISTRABLE_ATTRIBUTES = %i(start_time finish_time title memo start_datetime user_id)
end