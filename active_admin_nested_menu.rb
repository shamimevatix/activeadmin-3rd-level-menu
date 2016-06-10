module ActiveAdmin

  # Each Namespace builds up it's own menu as the global navigation
  #
  # To build a new menu:
  #
  #   menu = Menu.new do |m|
  #     m.add label: 'Dashboard', url: '/'
  #     m.add label: 'Users',     url: '/users'
  #   end
  #
  # If you're interested in configuring a menu item, take a look at the
  # options available in `ActiveAdmin::MenuItem`
  #
  class Menu
    module MenuNode
      alias_method :original_active_admin_menu_item_add, :_add unless method_defined?(:original_active_admin_menu_item_add)
      # The method that actually adds new menu items. Called by the public method.
      # If this ID is already taken, transfer the children of the existing item to the new item.
      def _add(options)
        item = ActiveAdmin::MenuItem.new(options)
        item.send :children=, self[item.id].children if self[item.id]
        self[item.id] = item
      end
    end
  end
end




module ActiveAdmin
  module Views
    class TabbedNavigation < Component

      alias_method :original_active_admin_build_step0, :build unless method_defined?(:original_active_admin_build_step0)
      alias_method :original_active_admin_build_menu_item, :build_menu_item unless method_defined?(:original_active_admin_build_menu_item)
      alias_method :original_active_admin_build_menu, :build_menu unless method_defined?(:original_active_admin_build_menu)
      alias_method :original_active_admin_default_options, :default_options unless method_defined?(:original_active_admin_default_options)

      def build(menu, options = {})
        puts "bild #{options}"
        @menu = menu
        @is_utility = options[:id].eql?("utility_nav")
        super(default_options.merge(options))
        build_menu
      end

      def build_menu
        @menu_tree ||= {}
        @menu_tree_lookup ||= {}

        if @is_utility
          menu_items.each do |item|
            build_menu_item(item)
          end
        else
          rearrange_menu_items
          @menu_tree_lookup.each do |menu_item_id, menu_item|
            build_menu_tree_item(menu_item)
          end
        end
      end

      def rearrange_menu_items
        menu_items.each do |item|
          rearrange_menu_item(item)
        end
        @menu_tree_lookup = @menu_tree.dup
        @menu_tree.each do |key, hash_item|
          found = false
          @menu_tree_lookup.each do |key2, hash_item2|
            if hash_item2[:children].count > 0
              # puts "Oh crap\n\n"
              hash_item2[:children].each do |c_item|
                if c_item[:item].to_s.eql?(key.to_s)
                  found = true
                  c_item[:children] += hash_item[:children].dup
                  break
                end
              end
            end
            if found
              break
            end
          end
          if found
            @menu_tree_lookup.delete(key)
          end
        end
      end

      def rearrange_menu_item(item)
        if children = item.items(self).presence
          @menu_tree[item.id] = Hash.new
          @menu_tree[item.id][:item] = item.id
          @menu_tree[item.id][:url] = item.url(self)
          @menu_tree[item.id][:label] = item.label(self)
          @menu_tree[item.id][:is_current_item] = item.current? assigns[:current_tab]
          @menu_tree[item.id][:html_options] = item.html_options
          @menu_tree[item.id][:children] = []

          children.each{ |child|
            @menu_tree[item.id][:children].push({:item => child.id, :url => child.url(self), :label => child.label(self), :is_current_item => child.current?(assigns[:current_tab]), :html_options => child.html_options, children: []})
          }

        else
          @menu_tree[item.id] = {:item => item.id, :url => item.url(self), :label => item.label(self), :is_current_item => item.current?(assigns[:current_tab]), :html_options => item.html_options, children: []}
        end
      end

      def build_menu_item(item)
        li id: item.id do |li|
          li.add_class "current test" if item.current? assigns[:current_tab]

          if url = item.url(self)
            text_node link_to item.label(self), url, item.html_options
          else
            span item.label(self), item.html_options
          end

          if children = item.items(self).presence
            li.add_class "has_nested"
            ul do
              children.each{ |child| build_menu_item child }
            end
          end
        end
      end

      def build_menu_tree_item(menu_item)
        li id: menu_item[:item] do |level0_li|
          level0_li.add_class "current" if menu_item[:is_current_item]
          if url = menu_item[:url]
            text_node link_to menu_item[:label], menu_item[:url] , menu_item[:html_options]
          else
            span menu_item[:label], menu_item[:html_options]
          end
          if menu_item[:children].count > 0
            level0_li.add_class "has_nested"
            ul do
              menu_item[:children].each do |child_menu_item|
                build_menu_tree_item(child_menu_item)
              end
            end
          end
        end
      end

      def default_options
        { id: "tabs", class: "" }
      end

    end
  end
end