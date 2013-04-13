#!/usr/bin/env ruby

require 'rubygems'
require 'httparty'
require 'json/pure'

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

salesDays = 30 # Number of days you want to see.
userName = "justinbieber@gmail.com"  # Your AppFigures username 
password = "neversaynever" # Your App Figures password 
graphTitle = "My Company's Sales" # The title for the graph
graphType = "line" # This can be 'bar' or 'line'
displayTotal = false # Set to true if you want a total revenue listed at the end of the graph.
hideTotals = true # If you want to see the sales total for each day on the y-axis set this to true

# This array contains a hash for each product. The :title should be your product name. 
# The :id is the App Figures product ID. You can fetch this at https://api.appfigures.com/v1.1/products/mine
# The :color can be red, blue, green, yellow, orange, purple, aqua, or pink
products = [ 
    { :title => "Product 1", :id => 0000, :color => "green" }, 
    { :title => "Product 2", :id => 0000, :color => "blue" } 
]

# Where you want to output the file on your computer. I recommend Dropbox since it can be publicly accessible.
outputFile = "/Users/justin/Dropbox/Status\ Board/salesboard.json"

########################################
# The Guts
########################################

# http://www.misuse.org/science/2008/03/27/converting-numbers-or-currency-to-comma-delimited-format-with-ruby-regex/
def comma_numbers(number, delimiter = ',')
  number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1#{delimiter}").reverse
end

startDate = (Date.today - salesDays).strftime("%Y-%m-%d")
endDate = Time.now.strftime("%Y-%m-%d")
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

options = { :basic_auth => { :username => userName , :password => password } }
datasequences = []
minTotal = 0
maxTotal = 0

# Iterate through each product listed above. 
products.each do |p|
salesData = []
response = HTTParty.get("https://api.appfigures.com/v1.1/sales/dates/#{startDate}/#{endDate}/?data_source=daily&products=#{p[:id]}", options)
    response.parsed_response.each.sort.each do |day| 
        # Parse the date into something nicely readable.
        date = Date.parse(day[1]["date"])
        dateString = "#{months["#{date.month}"]} #{date.day}"        

        # We're rounding the sales data.
        revenue = comma_numbers(day[1]["revenue"].to_i)        
        maxTotal = revenue.to_i if revenue.to_i > maxTotal
        minTotal = revenue.to_i if revenue.to_i < minTotal || minTotal == 0

        salesData << { :title => dateString, :value => revenue } 
    end

    # Add the product to the data sequences.
    datasequences << { :title => p[:title], :color => p[:color], :datapoints => salesData }
end 

# This is where the graph is generated.
salesGraph = { 
    :graph =>  {
        :title => graphTitle,
        :total => displayTotal,
        :type => graphType,
        :yAxis => {
            "hide" => hideTotals,
            :units => { :prefix => "$"},
            :minValue => minTotal,
            :maxValue => maxTotal
        },        
        :datasequences => datasequences
    }
}

File.open(outputFile, "w") do |f|
  f.write(salesGraph.to_json)
end
