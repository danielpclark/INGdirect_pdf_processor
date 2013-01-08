#!/usr/bin/ruby

# INGdirect_pdf_processor
# by: Daniel P. Clark
# Give yourself usable bank data for your records and applications.

VERSION = 0.1
# Version 0.1 functions well for collecting from all PDFs and dumping the output to STDOUT
# Example usage: ruby ing.rb > output.txt

require 'open-uri'
require 'pdf-reader'


def processING_Month(inPDF, globalDB)
  reader = PDF::Reader.new(inPDF)

  regpattern = Regexp.new('(.*)\s+(\d{2}\/\d{2}\/\d{4})\s*(\(?\$.\d+\.\d+\)?)\s+(\(?\$.\d+\.\d+\)?)')

  marker = "off"

  reader.pages.each do |page|
    begin
      page.text.split("\n").each do |line|
        if !!line["(Subject to F.C.)"]
          marker = "on"
        elsif !!line["Your Overdraft Line of Credit Activity"]
          marker = "off"
        end

        if marker == "on"
          matched = regpattern.match(line)
          if not matched.nil? 
            values = line.scan(regpattern)[0].map(&:strip) #.join(" - ")
            if not globalDB.key?(values[0])
              globalDB[values[0]] = [values[1..-2]]
            else
              globalDB[values[0]] << values[1..-2]
            end
          end
        end
      end
    rescue
      puts " -- E.O.F. REACHED -- "
    end
  end
end


def printDB(inDB)
    inDB.keys.each do |item|
      puts item
      inDB[item].each do |ticket|
        puts ticket.join(" - ")
      end
      puts
    end
end

ingDB = {}

Dir.glob("./*.pdf") do |f|
  processING_Month(f, ingDB)
end

printDB(ingDB)
