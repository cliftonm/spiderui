DatabaseSpider::Application.routes.draw do
  get "table_viewer/index"
  root to: "table_viewer#index"
  get "table_viewer" => "table_viewer#view_table"

  get "dynamic_tables" => "table_viewer#index"
  post "dynamic_tables" => "table_viewer#post"


end
