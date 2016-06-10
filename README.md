<snippet>
  <content><![CDATA[
# ${1:Project Name}
TODO: Write a project description
## Installation
Does not need any additional package. 
Put the active_admin_nested_menu.rb file from here to config/initializers folder.
## Usage
The level 0 menu item(topmost) needs to added from the config/initializers/active_admin.rb file. e.g.
```
config.namespace :admin do |admin|
	admin.build_menu do |menu|
	  menu.add :label => "Settings", if: proc{ check permission list or something else } -> level 0
	  menu.add :label => I18n.t('site_settings'), parent: "settings", if: proc{ check permission list or 
	  something else } -> level 1
	end
end
```
In the resource file, if it is a 3rd level menu item. Just assign the parent to the 2nd level menu above here. e.g.
```
ActiveAdmin.register Post do
  menu parent: I18n.t('site_settings')
end
```
And you are done. Also Need to add the css here in the active_admin.scss like 
```
@import "nested_menu";
```
Now, you are done.
## Contributing
1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D
## History
TODO: Write history
## Credits
TODO: Write credits
## License
TODO: Write license
]]></content>
  <tabTrigger>readme</tabTrigger>
</snippet>
