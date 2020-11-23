module ApplicationCable
  class Connection < ActionCable::Connection::Base
    # Identify every conne by current_user
    identified_by :current_user
    
    # Verified and set current_user as logined use for verifing when transmitting broadcase
    def connect
      self.current_user = find_verified_user
    end

    private
      # Find user if user_id present in cookies and prevent reject unauthorized connection
      def find_verified_user
        verified_user = User.find_by_id(cookies.signed[:user_id])
        verified_user.present? ? verified_user : reject_unauthorized_connection
      end
  end
end
