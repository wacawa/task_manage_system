class Task < ApplicationRecord
  belongs_to :user

  validates :start_time, presence: true
  validates :finish_time, presence: true
  validates :title, presence: true
  validates :start_datetime, presence: true

  validate :finish_time_is_later_than_start_time
  validate :time_range_cannot_overlap_others

  def finish_time_is_later_than_start_time
    errors.add(:finish_time, "：終了時間は開始時間より遅くしてください。") if start_time && finish_time && finish_time <= start_time
  end

  def time_range_cannot_overlap_others
    user = User.find(user_id)
    timerangeset = user.tasks.where(start_datetime: start_datetime).pluck(:start_time, :finish_time)
    booleans = []
    timerangeset.each do |s, f|
      if s.is_a?(Time) && f.is_a?(Time) && start_time.is_a?(Time) && finish_time.is_a?(Time) && start_datetime.is_a?(Time)
        now = start_time < start_datetime
        start = start_time >= s && start_time < f
        finish = finish_time > s && finish_time <= f
        sandf = start_time <= s && finish_time >= f
        final = finish_time > start_datetime.tomorrow
        equal = start_time.beginning_of_minute == finish_time.beginning_of_minute
        # if start || finish || sandf
        if now || start || finish || sandf || final || equal
          booleans << false
        end
      end
    end
    errors.add(:title, "：時間範囲が重複しています。") unless booleans.all?
  end

end
