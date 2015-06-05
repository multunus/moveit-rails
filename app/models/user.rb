class User < ActiveRecord::Base
  include Gravtastic
  gravtastic
  has_many :entries

  validates_presence_of :name
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i

  def activity_status
    last_activity = self.entries.order(created_at: :desc).limit(1).first
    time_difference = TimeDifference.between(last_activity.created_at, Time.now).in_hours
    activity_rule = {
      0...48 => "active",
      48...Float::INFINITY => "inactive"
    }
    activity_rule.select{ |rule| rule.include?(time_difference) }.values.first
  end
  
  def interaction_for(to_user)
    unless interacted_for_last_activity?(to_user)
      if to_user.interactable?
        to_user.activity_status
      end
    end
  end

  def active?
    activity_status == "active"
  end

  def inactive?
    activity_status == "inactive"
  end

  def interactable?
      bumpable? || nudgeable?
  end
  
  def nudgeable?
    inactive?
  end

  def bumpable?
    active?
  end
  
  def interacted_for_last_activity?(to_user)
    latest_interaction = UserInteraction.where(from_user: self, to_user: to_user, created_at:  to_user.entries.last.updated_at...Time.now).last
    unless latest_interaction.blank?
      return nudge_non_interactable?(latest_interaction)
    end
    return false
  end

  def nudge_non_interactable?(latest_interaction)
    # TODO. Needs refactoring since the behaviour is specific to type nudge
    # A duck may be?
    # nudge is interactable if last nudge was 24 hours ago
    return false if latest_interaction.nudge? and latest_interaction.not_in_last_24_hours?
    return true
  end
end
