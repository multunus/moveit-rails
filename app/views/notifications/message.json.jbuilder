if @user.active? && @unread_bumps_count > 0
	json.short t('notification_messages.bumps.short', name: @user.name, count: @unread_bumps_count)
	json.long t('notification_messages.bumps.long')
	json.activity UserInteraction::BUMP
elsif @user.inactive? && @unread_nudges_count > 0
    json.short t('notification_messages.nudges.short', name: @user.name)
	json.long t('notification_messages.nudges.long', count: @unread_nudges_count)
	json.activity UserInteraction::NUDGE
else
	json.short t("notification_messages.default.#{@time}.short")
	json.long t("notification_messages.default.#{@time}.long")
	json.activity ""
end