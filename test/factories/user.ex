defmodule Tradewinds.Factory do
  use ExMachina.Ecto

  def user_factory do
    %Tradewinds.User{
      email: sequence(:email, &"email-#{&1}@example.com"),
      name: "Test User",
      avatar_link: "http://somelink.com/a.jpg",
      auth0_id: "auth0|aaaabbbbccccdddd",
      permissions: %{}
    }
  end
end
