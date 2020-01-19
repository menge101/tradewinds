defmodule DocTest do
  use ExUnit.Case
  alias Tradewinds.Accounts.User
  alias Tradewinds.Events.Event
  alias Tradewinds.Trails.Trail
  doctest Mix.Tasks.Auth0.Client.Common
  doctest Tradewinds.Abilities.Common
  doctest Tradewinds.Events.Event.Abilities
  doctest Tradewinds.Trails.Trail.Abilities
  doctest Tradewinds.Accounts.User.Abilities
  doctest Tradewinds.Accounts.User
  doctest Tradewinds.Accounts.Registration.Abilities
  doctest Tradewinds.Fixtures.Registration
end
