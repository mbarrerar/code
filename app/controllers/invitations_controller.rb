class InvitationsController < ApplicationController
  before_filter(:set_user)

  
  def new()
    render("new", :layout => false) if request.xhr?
  end

  def create()
    @invitation = Invitation.new(params[:invitation])
    @invitation.from = current_user
    @invitation.site_url = request.host()

    if @invitation.valid?
      InvitationMailer.deliver_invitation_email(@invitation)
      InvitationMailer.deliver_inviter_email(@invitation)
      
      @msg_success = Invitation.msg_success(@invitation)
      respond_to do |format|
        format.html { (flash[:notice] = @msg_success) && redirect_to(new_invitation_url) }
        format.js { render("success.rjs") }
      end
    else
      @msg_error = Invitation.msg_error(@invitation)
      respond_to do |format|
        format.html { (flash[:error] = @msg_error) && render("new") }
        format.js { render("error.rjs") }
      end
    end
  end
end
