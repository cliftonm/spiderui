class ApplicationController < ActionController::Base
  protect_from_forgery


  private

end


# Also, for curiosity:

=begin
Encoding.list.each{|enc|
  begin
    print "%-10s\t" % [enc]
    print "\t\xC2".force_encoding(enc)
    print "\t\xC2".force_encoding(enc).encode('utf-8')
  rescue => err
    print "\t#{err}"
  end
  print "\n"
=end