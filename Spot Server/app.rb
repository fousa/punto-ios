require "sinatra"
require 'json'
require "time"

get "/message.json" do
  content_type :json

  {
    response: {
      feedMessageResponse: {
        feed: {
          id: "12345",
          name: "Frank Sinatra's Spot."
        },
        messages: {
          message: [
            { dateTime: "#{Time.now.iso8601.slice(0..-4)}00", messengerId: "123", messengerName: "Discus 2ax", latitude: 50.51899, longitude: 5.08139 },
            { dateTime: "#{Time.now.iso8601.slice(0..-4)}00", messengerId: "123", messengerName: "Discus 2ax", latitude: 50.46499, longitude: 5.07862 }
          ]
        }
      }
    }
  }.to_json
end
