ActiveAdmin.register_page "Frontends" do

  page_action :add, method: :post do

    required=[:backend,:frontend_uri,:frontend_app_id]
    flash[:errors]= required.select { |x| params[x].strip=='' }
    if flash[:errors].count>0
      flash[:errors]="Required fields: #{flash[:errors].join(', ')}"
      redirect_to admin_frontends_path + "?app_id=#{params[:app_id]}"
    else
      redirect_to admin_frontends_path + "?app_id=#{params[:app_id]}", notice: "Frontend added!"
    end

  end

  content do

    application=OauthApplication.last

    if params.has_key?(:app_id)
      application=OauthApplication.find params[:app_id]
    end

    render partial: 'frontends', locals: { application: application }
    render partial: 'form', locals: { application: application }
    flash.delete(:errors)
  end

end
