defmodule Tradewinds.EventsTest do
  use Tradewinds.DataCase

  alias Tradewinds.Events
  alias Tradewinds.Fixtures.Event, as: EventFixture

  describe "events" do
    alias Tradewinds.Events.Event

    @update_attrs %{
      description: "some updated description",
      end: "2011-05-18T15:01:01Z",
      hosting_kennel: "some updated hosting_kennel",
      latitude: 456.7,
      location: "some updated location",
      longitude: 456.7,
      name: "some updated name",
      start: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{
      description: nil,
      end: nil,
      hosting_kennel: nil,
      latitude: nil,
      location: nil,
      longitude: nil,
      name: nil,
      start: nil
    }

    test "list_events/0 returns all events" do
      {:ok, event: event} = EventFixture.fixture(:event, %{}, true)
      assert Events.list_events() == [event]
    end

    test "get_event!/1 returns the event with given id" do
      {:ok, event: event} = EventFixture.fixture(:event, %{}, true)
      assert Events.get_event!(event.id) == event
    end

    test "create_event/1 with valid data creates a event" do
      assert {:ok, %Event{} = event} = Events.create_event(EventFixture.create_attrs())
      assert event.description == "some description"
      assert event.end == DateTime.from_naive!(~N[2100-04-19T14:00:00Z], "Etc/UTC")
      assert event.hosting_kennel == "some kennel"
      assert event.latitude == 0
      assert event.location == "a location"
      assert event.longitude == 0
      assert event.name == "some name"
      assert event.start == DateTime.from_naive!(~N[2100-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_event/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(@invalid_attrs)
    end

    test "update_event/2 with valid data updates the event" do
      {:ok, event: event} = EventFixture.fixture(:event, %{}, true)
      assert {:ok, %Event{} = event} = Events.update_event(event, @update_attrs)
      assert event.description == "some updated description"
      assert event.end == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert event.hosting_kennel == "some updated hosting_kennel"
      assert event.latitude == 456.7
      assert event.location == "some updated location"
      assert event.longitude == 456.7
      assert event.name == "some updated name"
      assert event.start == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_event/2 with invalid data returns error changeset" do
      {:ok, event: event} = EventFixture.fixture(:event, %{}, true)
      assert {:error, %Ecto.Changeset{}} = Events.update_event(event, @invalid_attrs)
      assert event == Events.get_event!(event.id)
    end

    test "delete_event/1 deletes the event" do
      {:ok, event: event} = EventFixture.fixture(:event, %{}, true)
      assert {:ok, %Event{}} = Events.delete_event(event)
      assert_raise Ecto.NoResultsError, fn -> Events.get_event!(event.id) end
    end

    test "change_event/1 returns a event changeset" do
      {:ok, event: event} = EventFixture.fixture(:event, %{}, true)
      assert %Ecto.Changeset{} = Events.change_event(event)
    end
  end
end
