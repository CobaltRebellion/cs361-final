require_relative 'gis.rb'
require 'json'
require 'test/unit'

class TestGis < Test::Unit::TestCase

  def test_waypoints
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}}')
    f1 = Formatting.new(w.name, w.lat, w.lon, w.ele, w.icon)
    result = JSON.parse(f1.get_json)
    assert_equal(result, expected)

    w = Waypoint.new(-121.5, 45.5, nil, nil, "flag")
    expected = JSON.parse('{"type": "Feature","properties": {"icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    f1 = Formatting.new(w.name, w.lat, w.lon, w.ele, w.icon)
    result = JSON.parse(f1.get_json)
    assert_equal(result, expected)

    w = Waypoint.new(-121.5, 45.5, nil, "store", nil)
    expected = JSON.parse('{"type": "Feature","properties": {"title": "store"},"geometry": {"type": "Point","coordinates": [-121.5,45.5]}}')
    f1 = Formatting.new(w.name, w.lat, w.lon, w.ele, w.icon)
    result = JSON.parse(f1.get_json)
    assert_equal(result, expected)
  end

  def test_tracks
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

    ts3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]

    t = Track.new([ts1, ts2], "track 1")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}}')
    f1 = Formatting.new(t.name, nil, nil, nil, nil, t.segments)
    result = JSON.parse(f1.get_json)
    assert_equal(expected, result)

    t = Track.new([ts3], "track 2")
    expected = JSON.parse('{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}')
    f1 = Formatting.new(t.name, nil, nil, nil, nil, t.segments)
    result = JSON.parse(f1.get_json)
    assert_equal(expected, result)
  end

  def test_world
    w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
    w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
    ts1 = [
      Point.new(-122, 45),
      Point.new(-122, 46),
      Point.new(-121, 46),
    ]

    ts2 = [ Point.new(-121, 45), Point.new(-121, 46), ]

    ts3 = [
      Point.new(-121, 45.5),
      Point.new(-122, 45.5),
    ]

    t = Track.new([ts1, ts2], "track 1")
    t2 = Track.new([ts3], "track 2")

    f1 = Formatting.new(w.name, w.lat, w.lon, w.ele, w.icon)
    f2 = Formatting.new(w2.name, w2.lat, w2.lon, w2.ele, w2.icon)
    f3 = Formatting.new(t.name, nil, nil, nil, nil, t.segments)
    f4 = Formatting.new(t2.name, nil, nil, nil, nil, t2.segments)

    w = World.new("My Data", [f1.get_json, f2.get_json, f3.get_json, f4.get_json])

    expected = JSON.parse('{"type": "FeatureCollection","features": [{"type": "Feature","properties": {"title": "home","icon": "flag"},"geometry": {"type": "Point","coordinates": [-121.5,45.5,30]}},{"type": "Feature","properties": {"title": "store","icon": "dot"},"geometry": {"type": "Point","coordinates": [-121.5,45.6]}},{"type": "Feature", "properties": {"title": "track 1"},"geometry": {"type": "MultiLineString","coordinates": [[[-122,45],[-122,46],[-121,46]],[[-121,45],[-121,46]]]}},{"type": "Feature", "properties": {"title": "track 2"},"geometry": {"type": "MultiLineString","coordinates": [[[-121,45.5],[-122,45.5]]]}}]}')
    result = JSON.parse(w.to_geojson)
    assert_equal(expected, result)
  end

end
