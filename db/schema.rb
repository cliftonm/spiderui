# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131028201429) do

  create_table "AWBuildVersion", :primary_key => "SystemInformationID", :force => true do |t|
    t.string   "Database Version", :limit => 25, :null => false
    t.datetime "VersionDate",                    :null => false
    t.datetime "ModifiedDate",                   :null => false
  end

  create_table "Address", :id => false, :force => true do |t|
  end

  create_table "AddressType", :id => false, :force => true do |t|
  end

  create_table "BillOfMaterials", :id => false, :force => true do |t|
  end

  create_table "BusinessEntity", :id => false, :force => true do |t|
  end

  create_table "BusinessEntityAddress", :id => false, :force => true do |t|
  end

  create_table "BusinessEntityContact", :id => false, :force => true do |t|
  end

  create_table "ContactType", :id => false, :force => true do |t|
  end

  create_table "CountryRegion", :id => false, :force => true do |t|
  end

  create_table "CountryRegionCurrency", :id => false, :force => true do |t|
  end

  create_table "CreditCard", :id => false, :force => true do |t|
  end

  create_table "Culture", :id => false, :force => true do |t|
  end

  create_table "Currency", :id => false, :force => true do |t|
  end

  create_table "CurrencyRate", :id => false, :force => true do |t|
  end

  create_table "Customer", :id => false, :force => true do |t|
  end

# Could not dump table "DatabaseLog" because of following StandardError
#   Unknown type 'xml' for column 'XmlEvent'

  create_table "Department", :id => false, :force => true do |t|
  end

  create_table "Document", :id => false, :force => true do |t|
  end

  create_table "EmailAddress", :id => false, :force => true do |t|
  end

  create_table "Employee", :id => false, :force => true do |t|
  end

  create_table "EmployeeDepartmentHistory", :id => false, :force => true do |t|
  end

  create_table "EmployeePayHistory", :id => false, :force => true do |t|
  end

  create_table "ErrorLog", :primary_key => "ErrorLogID", :force => true do |t|
    t.datetime "ErrorTime",                      :null => false
    t.string   "UserName",       :limit => 128,  :null => false
    t.integer  "ErrorNumber",                    :null => false
    t.integer  "ErrorSeverity"
    t.integer  "ErrorState"
    t.string   "ErrorProcedure", :limit => 126
    t.integer  "ErrorLine"
    t.string   "ErrorMessage",   :limit => 4000, :null => false
  end

  create_table "Illustration", :id => false, :force => true do |t|
  end

  create_table "JobCandidate", :id => false, :force => true do |t|
  end

  create_table "Location", :id => false, :force => true do |t|
  end

  create_table "Password", :id => false, :force => true do |t|
  end

  create_table "Person", :id => false, :force => true do |t|
  end

  create_table "PersonCreditCard", :id => false, :force => true do |t|
  end

  create_table "PersonPhone", :id => false, :force => true do |t|
  end

  create_table "PhoneNumberType", :id => false, :force => true do |t|
  end

  create_table "Product", :id => false, :force => true do |t|
  end

  create_table "ProductCategory", :id => false, :force => true do |t|
  end

  create_table "ProductCostHistory", :id => false, :force => true do |t|
  end

  create_table "ProductDescription", :id => false, :force => true do |t|
  end

  create_table "ProductDocument", :id => false, :force => true do |t|
  end

  create_table "ProductInventory", :id => false, :force => true do |t|
  end

  create_table "ProductListPriceHistory", :id => false, :force => true do |t|
  end

  create_table "ProductModel", :id => false, :force => true do |t|
  end

  create_table "ProductModelIllustration", :id => false, :force => true do |t|
  end

  create_table "ProductModelProductDescriptionCulture", :id => false, :force => true do |t|
  end

  create_table "ProductPhoto", :id => false, :force => true do |t|
  end

  create_table "ProductProductPhoto", :id => false, :force => true do |t|
  end

  create_table "ProductReview", :id => false, :force => true do |t|
  end

  create_table "ProductSubcategory", :id => false, :force => true do |t|
  end

  create_table "ProductVendor", :id => false, :force => true do |t|
  end

  create_table "PurchaseOrderDetail", :id => false, :force => true do |t|
  end

  create_table "PurchaseOrderHeader", :id => false, :force => true do |t|
  end

  create_table "SalesOrderDetail", :id => false, :force => true do |t|
  end

  create_table "SalesOrderHeader", :id => false, :force => true do |t|
  end

  create_table "SalesOrderHeaderSalesReason", :id => false, :force => true do |t|
  end

  create_table "SalesPerson", :id => false, :force => true do |t|
  end

  create_table "SalesPersonQuotaHistory", :id => false, :force => true do |t|
  end

  create_table "SalesReason", :id => false, :force => true do |t|
  end

  create_table "SalesTaxRate", :id => false, :force => true do |t|
  end

  create_table "SalesTerritory", :id => false, :force => true do |t|
  end

  create_table "SalesTerritoryHistory", :id => false, :force => true do |t|
  end

  create_table "ScrapReason", :id => false, :force => true do |t|
  end

  create_table "Shift", :id => false, :force => true do |t|
  end

  create_table "ShipMethod", :id => false, :force => true do |t|
  end

  create_table "ShoppingCartItem", :id => false, :force => true do |t|
  end

  create_table "SpecialOffer", :id => false, :force => true do |t|
  end

  create_table "SpecialOfferProduct", :id => false, :force => true do |t|
  end

  create_table "StateProvince", :id => false, :force => true do |t|
  end

  create_table "Store", :id => false, :force => true do |t|
  end

  create_table "TransactionHistory", :id => false, :force => true do |t|
  end

  create_table "TransactionHistoryArchive", :id => false, :force => true do |t|
  end

  create_table "UnitMeasure", :id => false, :force => true do |t|
  end

  create_table "Vendor", :id => false, :force => true do |t|
  end

  create_table "WorkOrder", :id => false, :force => true do |t|
  end

  create_table "WorkOrderRouting", :id => false, :force => true do |t|
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

end
