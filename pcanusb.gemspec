# -*- ruby -*-

Gem::Specification.new do |s|
  s.name = %q{pcanusb}
  s.version = "1.0.1"

  s.authors = ["Bryan Ash"]
  s.date = %q{2009-04-19}
  s.description = %q{PCAN is a Controller Area Network (CAN) device that connects to a PC via USB. It ships with a DLL and documented API. This is a Ruby wrapper for that API allowing CAN messages to be sent and received from Ruby.}
  s.email = %q{bryan.a.ash@gmail.com}
  s.files =
    [ "rakefile",
      "README.rdoc",
      "lib/Pcan_usb.dll",
      "lib/pcanusb.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://bryan-ash.github.com/pcanusb}
  s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{pcanusb}
  s.rubygems_version = %q{1.3.1}
  s.summary = s.description
end
