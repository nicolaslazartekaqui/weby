class MenusController < ApplicationController
  layout :choose_layout
  before_filter :require_user, :except => :show
  before_filter :check_authorization, :except => :show
  respond_to :html, :xml, :js

  def index
  end

  def show
    @menu = Menu.find(params[:id])
    respond_with(@menu)
  end

  def new 
    @menu_parent = SitesMenu.find(params[:parent_id]) if params[:parent_id]
    @menu = Menu.new
    @menu.sites_menus.build
    @pages = @site.pages.page(params[:page]).per(params[:per_page])

    respond_with do |format|
      format.js { 
        render :update do |page|
          page.call "$('#div_link').html", render(:partial => 'formPages', :locals => { :f => SemanticFormBuilder.new(:menu, @menu, self, {}, proc{}) })
          page.call "$('#link_form_pages').html", (params[:type] == "internal") ? "#{t("internal")} | #{(link_to t("external"), new_site_menu_path(@site, :type => "external"), :update => "div_link", :remote => true, :onclick => "var img = new Image; img.src = '/images/spinner.gif'; $(this).parent().html('').append(function(){return img})")}" : "#{(link_to t("internal"), new_site_menu_path(@site, :type => "internal"), :update => "div_link", :remote => true, :onclick => "var img = new Image; img.src = '/images/spinner.gif'; $(this).parent().html('').append(function(){return img})")} | #{t("external")}"
        end
      }
      format.html
    end
  end

  def edit
    @menu = Menu.find(params[:id])
    @pages = @site.pages.page(params[:page]).per(params[:per_page])

    respond_with do |format|
      format.js { 
        render :update do |page|
          page.call "$('#div_link').html", render(:partial => 'formPages', :locals => { :f => SemanticFormBuilder.new(:menu, @menu, self, {}, proc{}) })
          page.call "$('#link_form_pages').html", (params[:type] == "internal") ? "#{t("internal")} | #{(link_to t("external"), edit_site_menu_path(@site, :type => "external"), :update => "div_link", :remote => true, :onclick => "var img = new Image; img.src = '/images/spinner.gif'; $(this).parent().html('').append(function(){return img})")}" : "#{(link_to t("internal"), edit_site_menu_path(@site, :type => "internal"), :update => "div_link", :remote => true, :onclick => "var img = new Image; img.src = '/images/spinner.gif'; $(this).parent().html('').append(function(){return img})")} | #{t("external")}"
        end
      }
      format.html
    end
  end

  def create
    @menu = Menu.new(params[:menu])
    if @menu.save 
      flash[:notice] = t("successfully_created")
      redirect_back_or_default site_menus_path(@site, :category => @menu.sites_menus[0].category)
    else
      respond_with(@site, @menu)
    end
  end

  def update
    @menu = Menu.find(params[:id])
    if @menu.update_attributes(params[:menu])
      flash[:notice] = t("successfully_updated")
      redirect_back_or_default site_menus_path(@site, :category => @menu.sites_menus[0].category)
    else
      respond_with(@site, @menu)
    end 
  end

  def destroy
    @menu = Menu.find(params[:id])
    @menu.destroy
    respond_with(@menu)
  end
  # Altera a ordenação do menu
  def change_position
    @ch_pos_new = SitesMenu.find(params[:id])
    @ch_pos_old = SitesMenu.find(:first, :conditions => ["parent_id = ? and category = ? and position = ?", @ch_pos_new.parent_id, @ch_pos_new.category, params[:position]])
    if @ch_pos_old
      @ch_pos_new.position,@ch_pos_old.position = @ch_pos_old.position,@ch_pos_new.position
      @ch_pos_new.save
      @ch_pos_old.save
      flash[:notice] = t"successfully_updated"
    elsif params[:position]
      @ch_pos_new.position = params[:position]
      @ch_pos_new.save
    else
      flash[:error] = t"error_updating_object"
    end
    redirect_back_or_default site_menus_path(@site, :category => @ch_pos_new.category)
  end

  # Remove iten(s) do menu
  def rm_menu
    @rm_menu = SitesMenu.find(params[:id])
    if @rm_menu  
        ary_for_del = del_deep(@menus[@rm_menu.category], @rm_menu.id)
        ary_for_del.each do |item|
          item.destroy
      end
    end
    @rm_menu.destroy
    redirect_to :back, :notice => t("successfully_deleted")
  end

  private
  def del_deep(obj, pos)
    res ||= []
    unless obj[pos].nil?
      obj[pos].each do |child|
        del_deep_entry(obj, child, res)
      end
      res.flatten
    end
    res
  end
  def del_deep_entry(obj, child, res)
    res << child
    if obj[child.id].class.to_s == "Array"
      obj[child.id].each do |sub_child|
        del_deep_entry(obj, sub_child, res)
      end
    end
    res
  end
end
