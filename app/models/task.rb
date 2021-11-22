class Task < ApplicationRecord
  belongs_to :user

  validates :date, presence: true
  validates :start_time, presence: true
  validates :finish_time, presence: true

  validate :time_range_cannot_overlap_others

  def time_range_cannot_overlap_others
    timerangeset = Tasks.where(date: date).pluck(:start_time, :finish_time)
    timerangeset.each do |r|
      start = start_time > r[0] && start_time < r[1]
      finish = finish_time > r[0] && finish_time < r[1]
      sandf = start_time < r[0] && finish_time > r[1]
      if start || finish || sandf
        errors.add("時間範囲の重複")
      end
    end
  end

end
