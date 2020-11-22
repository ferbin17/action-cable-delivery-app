class MerchantChannel < ApplicationCable::Channel
  def subscribed
    stream_from "merchant_channel_#{current_user.id}"
    # stream_from "some_channel"
  end

  def unsubscribed
    if current_user
      current_user.update(last_signed_out_at: Time.now, dont_validate_password: false)
    end
    # Any cleanup needed when channel is unsubscribed
  end
end
