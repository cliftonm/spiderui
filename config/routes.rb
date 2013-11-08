DatabaseSpider::Application.routes.draw do
  get "metadata/index"
  get "metadata"  => "metadata#index"
  get "metadata_table" => "metadata#select_table"
  get "metadata_field" => "metadata#select_field"

  get "table_viewer/index"
  get "table_viewer" => "table_viewer#view_table"

  get "dynamic_tables" => "table_viewer#index"
  post "dynamic_tables" => "table_viewer#post"
  get "navigate_back" => "table_viewer#nav_back"

  get "clear_session" => "table_viewer#clear_session"

  root to: "table_viewer#index"
end
