ActiveAdmin.register_page "Frontends" do

  menu parent: 'Applications', priority: 6

  page_action :add, method: :post do

    required=[:app_id,:backend,:frontend_uri]
    flash[:errors]= required.select { |x| params[x].strip=='' }
    if flash[:errors].count>0
      flash[:errors]="Required fields: #{flash[:errors].join(', ')}"
      redirect_to admin_frontends_path + "?app_id=#{params[:app_id]}"
    else
      flash.delete(:errors)
      application=OauthApplication.find(params[:app_id])
      company_id = params[:company_id]
      company_id=nil if company_id.strip==''
      application.add_frontend backend_host: params[:backend], frontend_url: params[:frontend_uri], company_id: company_id
      redirect_to admin_frontends_path + "?app_id=#{params[:app_id]}", notice: "Frontend added!"
    end

  end

  page_action :delete, method: :get do
    application=OauthApplication.find(params[:app_id])
    application.delete_frontend params[:frontend_url]
    redirect_to admin_frontends_path + "?app_id=#{params[:app_id]}", notice: "Frontend #{params[:frontend_url]} was deleted!"
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
