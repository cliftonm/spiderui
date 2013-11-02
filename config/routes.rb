DatabaseSpider::Application.routes.draw do
  get "table_viewer/index"
  get "clear_session" => "table_viewer#clear_session"
  root to: "table_viewer#index"
  get "table_viewer" => "table_viewer#view_table"

  get "dynamic_tables" => "table_viewer#index"
  post "dynamic_tables" => "table_viewer#post"

  get "navigate_back" => "table_viewer#nav_back"


end
