class Form::TaskCollection < Form::Base
  DEFAULT_ITEM_COUNT = 50
  attr_accessor :tasks

  def initialize(attributes = {})
    super attributes
    self.tasks = DEFAULT_ITEM_COUNT.times.map { Form::Task.new } unless tasks.present?
  end

  def tasks_attributes=(attributes)
    plus = []
    attributes = attributes.select {|_, task_attributes| task_attributes[:start_time].present? && task_attributes[:title].present?}
    self.tasks = attributes.map do |_, task_attributes|
      # if task_attributes[:start_time].present? && task_attributes[:finish_time].present? && task_attributes[:start_datetime].present?
        Form::Task.new(task_attributes).tap do |val|
          val.memo = val.memo.gsub(/(\r\n)*$/, "") if val.memo.present?
          if val.start_time.is_a?(Time) && val.finish_time.is_a?(Time) && val.start_datetime.is_a?(Time)
            date = "#{val.start_datetime.year}-#{val.start_datetime.month}-#{val.start_datetime.day}"
            val.start_time = (date + " " + val.start_time.hour.to_s + ":" + val.start_time.min.to_s).to_time
            val.start_time = val.start_time.tomorrow if val.start_time < val.start_datetime
            val.finish_time = (date + " " + val.finish_time.hour.to_s + ":" + val.finish_time.min.to_s).to_time
            val.finish_time = val.finish_time.tomorrow if val.finish_time < val.start_datetime
            range = val.finish_time - val.start_time
            if range.zero?
              val.start_time = nil
              val.finish_time = nil
            elsif range.negative? && range >= -12 * 60 * 60
              val.start_time = nil
              val.finish_time = nil
            elsif range.negative?
              val.finish_time = val.finish_time.tomorrow
              if val.start_time < val.start_datetime.tomorrow && val.start_datetime.tomorrow < val.finish_time
                date = val.start_datetime.tomorrow
                finish_time = val.finish_time
                val.finish_time = date
                plus << Form::Task.new(task_attributes)
                t = plus.last
                t.start_datetime = date
                t.start_time = date
                t.finish_time = finish_time
                t.title = val.title
                debugger
              end
            end
          end
          # debugger if _ == "3"
        end
      # end
    end
    self.tasks.concat(plus)
    debugger
  end

  def save
    booleans = []
    Task.transaction { target_tasks.each{|v| booleans << v.save} }
    booleans.present? && booleans.all?
  end

  def target_tasks
    self.tasks.select { |v| v.finish_time.present? }
  end

  def valid?
    valid_tasks = target_tasks.map(&:valid?)
    # .all?
    super && valid_tasks
  end

end