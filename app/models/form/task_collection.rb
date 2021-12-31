class Form::TaskCollection < Form::Base
  DEFAULT_ITEM_COUNT = 50
  attr_accessor :tasks

  def initialize(attributes = {})
    super attributes
    self.tasks = DEFAULT_ITEM_COUNT.times.map { Form::Task.new } unless tasks.present?
  end

  def tasks_attributes=(attributes)
    plus = []
    attributes = attributes.select {|_, task_attributes| task_attributes[:start_time].present? && task_attributes[:finish_time].present?}
    self.tasks = attributes.map do |_, task_attributes|
      # if task_attributes[:start_time].present? && task_attributes[:finish_time].present? && task_attributes[:start_datetime].present?
        Form::Task.new(task_attributes).tap do |val|
          val.memo = val.memo.gsub(/(\r\n)*$/, "") if val.memo.present?
          if val.start_time.is_a?(Time) && val.finish_time.is_a?(Time) && val.start_datetime.is_a?(Time)
            val.start_time = val.start_time.beginning_of_minute
            val.finish_time = val.finish_time.beginning_of_minute
            range = val.finish_time - val.start_time
            range1 = val.finish_time.tomorrow - val.start_time
            if range.negative? && range1 >= range.abs
              val.start_time = nil
              val.finish_time = nil
            else
              range = range >= 0 ? range : range1
              d_boolean = val.start_datetime.day == Time.now.day
              start_datetime = d_boolean ? val.start_datetime : val.start_datetime.tomorrow
              s_boolean = val.start_time < start_datetime
              finish_time = val.start_time + range
              sf_boolean = s_boolean && finish_time > start_datetime
              ds_boolean = d_boolean && s_boolean
              z_boolean = start_datetime.hour == 0 && range.abs > range1
              range = range.abs > range1 ? range1 : range
              if sf_boolean || z_boolean
                start_datetime = z_boolean ? start_datetime.tomorrow : start_datetime
                range = finish_time - start_datetime
                plus << Form::Task.new(task_attributes)
                t = plus.last
                t.start_datetime = t.start_datetime.tomorrow
                t.start_time = t.start_datetime
                t.finish_time = t.start_time + range
                range = start_datetime - val.start_time
              end
              val.start_time = ds_boolean ? val.start_time.tomorrow : val.start_time
              val.finish_time = val.start_time + range
            end
          end
          # debugger if _ == "3"
        end
      # end
    end
    self.tasks.concat(plus)
  end

  def valid?
    valid_tasks = target_tasks.map(&:valid?).all?
    super && valid_tasks
  end

  def save
    booleans = []
    Task.transaction { target_tasks.each{|v| booleans << v.save} }
    booleans.all?
  end

  def target_tasks
    self.tasks.select { |v| v.finish_time.present? }
  end
end