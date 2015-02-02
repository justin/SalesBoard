#!/usr/bin/env ruby
startTime = Time.now
require 'rubygems'
require 'httparty'
require 'base64'
require 'date'
require 'json'
require 'action_view'
require 'terminal-notifier'
include ActionView::Helpers::DateHelper

# SalesBoard - An AppFigures script for Status Board
# Created by Justin Williams
# http://twitter.com/justin
# http://carpeaqua.com
#
# If you find this script useful, please consider purchasing one of my two products to show your support:
#
# * Elements for iOS : http://bit.ly/elements20
# * Committed for OS X : http://bit.ly/committed10
#
# The README has more instructions on how to use this thing.

########################################
# Configuration
########################################

salesDays = 10 # Number of days you want to see.
userName = ""  # Your AppFigures username
password = "" # Your App Figures password
clientKey =  "" # Your API Key from https://appfigures.com/account/api
currency = "GBP" # The selected currency under your AppFigures account settings
graphTitle = "" # The title for the graph
graphType = "bar" # This can be 'bar' or 'line'
displayTotal = true # Set to true if you want a total revenue listed at the end of the graph.
hideTotals = false # If you want to see the sales total for each day on the y-axis set this to true
refreshInterval = 120 # Set as seconds. Min 5, default 120
scaleTo = 1 # Set scale size i.e. 1000 to show 8 as 8000

# This array contains a hash for each product. The :title should be your product name.
# The :id is the App Figures product ID. You can fetch this at https://api.appfigures.com/v2/products/mine
# The :color can be red, blue, green, yellow, orange, purple, aqua, or pink
products = [
    { :title => "App 1", :id => 12345677, :color => "green" },
    { :title => "App 2", :id => 12345678, :color => "blue" }
]

# Where you want to output the file on your computer. I recommend Dropbox since it can be publicly accessible.
outputFile = "/Users/myname/Dropbox/Public/statusboard_data/salesboard.json"

########################################
# The Guts
########################################

# http://www.misuse.org/science/2008/03/27/converting-numbers-or-currency-to-comma-delimited-format-with-ruby-regex/
def comma_numbers(number, delimiter = ',')
  number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
end

startDate = (Date.today - salesDays).strftime("%Y-%m-%d")
endDate = (Date.today - 1).strftime("%Y-%m-%d")
months = {
    "1" => "Jan",
    "2" => "Feb",
    "3" => "Mar",
    "4" => "Apr",
    "5" => "May",
    "6" => "Jun",
    "7" => "Jul",
    "8" => "Aug",
    "9" => "Sep",
    "10" => "Oct",
    "11" => "Nov",
    "12" => "Dec"
}
datasequences = []
minTotal = 0
maxTotal = 1
puts "--> Fetching AppFigures Data"
lastDate = []

# Iterate through each product listed above.
products.each do |p|
    salesData = []
    puts "--> Retrieving data for #{p[:title]}"
    response = HTTParty.get("https://api.appfigures.com/v2/sales/products+dates/?start_date=#{startDate}&end_date=#{endDate}&granularity=daily&products=#{p[:id]}", :headers => { "X-Client-Key" => "#{clientKey}"}, :basic_auth => {:username => userName, :password => password })
        response.parsed_response.each.sort.each do |day|
            day_hash = day[1]
            day_hash.each do |data|
                # Parse the date into something nicely readable.
                newDate = Date.parse(data[1]['date'])
                dateString = "#{newDate.day} #{months["#{newDate.month}"]}"
                # We're rounding the sales data.

                # Uncomment these lines for sales revenue
                # revenue = comma_numbers(day[1]["revenue"].to_i)
                # maxTotal = revenue.to_i if revenue.to_i > maxTotal
                # minTotal = revenue.to_i if revenue.to_i < minTotal || minTotal == 1
                # salesData << { :title => dateString, :value => revenue }

                # Uncomment these lines for downloads
                downloads = comma_numbers(data[1]["downloads"].to_i)
                maxTotal = downloads.to_i if downloads.to_i > maxTotal
                minTotal = downloads.to_i if downloads.to_i < minTotal || minTotal == 1
                salesData << { :title => dateString, :value => downloads }
                lastDate = dateString
            end
        end
        # Add the product to the data sequences.
        datasequences << { :title => p[:title], :color => p[:color], :datapoints => salesData }
    end
    puts "--> Generating Graphs"
    # This is where the graph is generated.
    salesGraph = {
        :graph =>  {
            :title => graphTitle,
            :total => displayTotal,
            :refresh => refreshInterval,
            :type => graphType,
            :yAxis => {
                :hide => hideTotals,
                # :units => { :prefix => "Total " },
                :minValue => minTotal,
                :maxValue => maxTotal,
                :scaleTo => scaleTo
            },
            :datasequences => datasequences
        }
    }
    puts "--> Updating Files"
    File.open(outputFile, "w") do |f|
      f.write(salesGraph.to_json)
      puts "--> Saved"
end

endTime = Time.now
puts "--> Publishing date upto #{lastDate}"
puts "--> Completed in #{((endTime - startTime)*1000.0).to_int}ms"

# Send Notification
# Comment this out if you don't want a desktop notification
message = ARGV[0] ||  "Salesboard Updated up to #{lastDate}"
activate = 'com.googlecode.iterm2'
# TerminalNotifier.notify(message, :activate => activate, :title => "Salesboard}")
%x{/usr/bin/terminal-notifier -message "#{message}" -title "Salesboard" -activate #{activate}}
