module Admin

  class ContactUsController < ApplicationController

    layout "admin"
    before_filter :verify_admin

    # GET /contact_us
    # GET /contact_us.xml
    def index
      @contact_us = ContactU.all

      respond_to do |format|
        format.html # index.html.erb
        format.xml  { render :xml => @contact_us }
      end
    end

    # GET /contact_us/1
    # GET /contact_us/1.xml
    def show
      @contact_u = ContactU.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @contact_u }
      end
    end


    # GET /contact_us/1/edit
    def edit
      @contact_u = ContactU.find(params[:id])
    end

    # PUT /contact_us/1
    # PUT /contact_us/1.xml
    def update
      @contact_u = ContactU.find(params[:id])

      respond_to do |format|
        if @contact_u.update_attributes(params[:contact_u])
          format.html { redirect_to([:admin,@contact_u], :notice => 'Contact u was successfully updated.') }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @contact_u.errors, :status => :unprocessable_entity }
        end
      end
    end

    # DELETE /contact_us/1
    # DELETE /contact_us/1.xml
    def destroy
      @contact_u = ContactU.find(params[:id])
      @contact_u.destroy

      respond_to do |format|
        format.html { redirect_to(admin_contact_us_url) }
        format.xml  { head :ok }
      end
    end
  end

end