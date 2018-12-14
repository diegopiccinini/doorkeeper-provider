ActiveAdmin.register_page "Sites Tags" do

  menu parent: 'Sites', priority: 2

  page_action :add_tag, method: :get do
    site=Site.find params[:site_id]
    tag=ActsAsTaggableOn::Tag.find params[:tag_id]
    site.tags << tag
    site.save
    redirect_to admin_sites_tags_path, notice: "Tag #{tag.name} was added to #{site.host}"
  end

  page_action :remove_tag, method: :get do
    site=Site.find params[:site_id]
    tag=ActsAsTaggableOn::Tag.find params[:tag_id]
    site.tag_list.remove tag.name
    site.save
    redirect_to admin_sites_tags_path, notice: "Tag #{tag.name} was removed to #{site.host}"
  end

  page_action :filter, method: :post do

    if params[:application_name].size>0
      session[:app_name_filter]=params[:application_name]
      notice_text= "Filter by application name #{params[:application_name]}"
    else
      session.delete(:app_name_filter)
    end

    if params[:host].size>0
      session[:host]=params[:host]
      notice_text= "Filter by host name #{params[:host]}"
    else
      session.delete(:host)
    end

    redirect_to admin_sites_tags_path, notice: notice_text
  end

  page_action :filter_add_tag, method: :get do
    session[:filter_by_tag]<< params[:tag].to_i
    redirect_to admin_sites_tags_path
  end

  page_action :filter_remove_tag, method: :get do
    session[:filter_by_tag].delete(params[:tag].to_i)
    redirect_to admin_sites_tags_path
  end

  page_action :filter_clear, method: :get do
    session[:filter_by_tag]=[]
    session.delete(:app_name_filter)
    session.delete(:host)
    redirect_to admin_sites_tags_path
  end

  content do
    session[:filter_by_tag]||=[]
    session[:filter_by_tag]=session[:filter_by_tag].uniq

    sites=Site.where(excluded: false)
    tags=ActsAsTaggableOn::Tag.where(id: session[:filter_by_tag]).all
    sites=sites.tagged_with(tags, has_all: false) unless tags.empty?

    if session[:app_name_filter]
      applications=OauthApplication.name_contains(session[:app_name_filter])
      site_ids=OauthApplicationsSite.where( oauth_application_id: applications.ids).map { |x| x.site_id }.uniq
      sites=sites.where(id: site_ids)
    end

    if session[:host]
      sites=sites.url_contains( session[:host])
    end

    render partial: 'tags', locals: { sites: sites.order(:url).limit(30).all }
  end

  sidebar :filters, partial: 'filters'
end
