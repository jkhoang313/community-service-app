class Event < ApplicationRecord
  has_many :users, through: :attendees
  has_many :attendees
  has_many :comments
  belongs_to :creator, :class_name => "User", optional: true
  validates :title, :description, :start_date, :end_date, presence: true
  validate :no_past_events, :invalid_end_date

  def no_past_events
    if start_date < current_datetime
      errors.add(:start_date, "cannot be in the past")
    elsif end_date < current_datetime
      errors.add(:end_date, "cannot be in the past")
    end
  end

  def invalid_end_date
    if end_date < start_date
      errors.add(:end_date, "cannot be before start date")
    end
  end

  def date_format
    if start_date.strftime('%B %d, %Y') == end_date.strftime('%B %d, %Y')
      start_date.strftime('%B %d, %Y')
    else
      "#{start_date.strftime('%B %d, %Y')} - #{end_date.strftime('%B %d, %Y')}"
    end
  end

  def time_format
    start_hour = start_date.strftime('%I').to_i < 10 ? start_date.strftime('%I')[1] : start_date.strftime('%I')

    end_hour = end_date.strftime('%I').to_i < 10 ? end_date.strftime('%I')[1] : end_date.strftime('%I')

    start_hour + start_date.strftime(':%M %p') + " - " + end_hour + end_date.strftime(':%M %p')
  end

  def past_event?
    end_date < current_datetime
  end

  def self.past_events
    self.where("end_date < ?", current_datetime).order(:start_date)
  end

  def self.upcoming_events
    self.where("start_date > ?", current_datetime).order(:start_date)
  end

  def self.ongoing_events
    self.where("start_date < ? AND end_date > ?", current_datetime, current_datetime).order(:start_date)
  end

  def self.active_organizers
    self.group(:creator_id).order("COUNT(creator_id) DESC").limit(3).count
  end
end
