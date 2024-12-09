#!/usr/bin/env ruby

class Track

  attr_reader :name, :segments

  def initialize(segments, name=nil)
    @name = name
    segment_objects = []
    segments.each do |segment|
      segment_objects.append(TrackSegment.new(segment))
    end
    # set segments to segment_objects
    @segments = segment_objects
  end
end

class TrackSegment
  attr_reader :coordinates
  def initialize(coordinates)
    @coordinates = coordinates
  end
end

class Point
  attr_reader :lat, :lon, :ele
  def initialize(lon, lat, ele=nil)
    @lon = lon
    @lat = lat
    @ele = ele
  end
end

class Waypoint  
  attr_reader :lat, :lon, :ele, :name, :icon

  def initialize(lon, lat, ele=nil, name=nil, icon=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @icon = icon
  end

end

class World
  def initialize(name, things)
    @name = name
    @features = things
  end

  def add_feature(new_feature)
    @features.append(new_feature)
  end

  # Formats all
  def to_geojson(indent=0)
    json = '{"type": "FeatureCollection","features": ['
    @features.each_with_index do |feature, i|

      if i != 0
        json += ","
      end

      json += feature

    end
    json + "]}"
  end
  
end

# ------------------------------------------------------------------------------------------------
class Formatting

  attr_reader :lat, :lon, :ele, :name, :icon

  def initialize(name=nil, lat=nil, lon=nil, ele=nil, icon=nil, segments=nil)
    @lat = lat
    @lon = lon
    @ele = ele
    @name = name
    @icon = icon
    @segments = segments
  end

  def get_properties_json()
    if name != nil or icon != nil
      json = '"properties": {'
      if name != nil
        json += '"title": "' + @name + '"'
      end

      # if its a waypoint, and has an icon
      if icon != nil  # if icon is not nil
        if name != nil
          json += ','
        end
        json += '"icon": "' + @icon + '"'
      end
      json += '}'
    end
  end

  def get_geometry_json()
    json = '"geometry": {'

    # if its a waypoint, do this
    if lon != nil
      json += '"type": "Point","coordinates": '
      json += "[#{@lon},#{@lat}"
      if ele != nil
        json += ",#{@ele}"
      end

    # if its a track, do this
    elsif @segments != nil
      json += '"type": "MultiLineString",'
      json +='"coordinates": ['

      @segments.each_with_index do |segment, index|
        if index > 0
          json += ","
        end
        json += '['
        
        # Loop through all the coordinates in the segment
        cordjson = ''
        segment.coordinates.each do |coordinate|
          if cordjson != ''
            cordjson += ','
          end

          # Add the coordinate
          cordjson += '['
          cordjson += "#{coordinate.lon},#{coordinate.lat}"
          
          if coordinate.ele != nil
            cordjson += ",#{coordinate.ele}"
          end
          cordjson += ']'
        end
        json += cordjson
        json += ']'
      end
    end
    json += ']}}'
  end

  def get_json(indent=0)
    json = '{"type": "Feature",'

    properties = self.get_properties_json
    json += properties + ","
    
    geometry = self.get_geometry_json
    json += geometry
  end

end

def main()
  w = Waypoint.new(-121.5, 45.5, 30, "home", "flag")
  w2 = Waypoint.new(-121.5, 45.6, nil, "store", "dot")
  
  ts1 = [
  Point.new(-122, 45),
  Point.new(-122, 46),
  Point.new(-121, 46),
  ]

  ts2 = [ 
  Point.new(-121, 45), 
  Point.new(-121, 46), 
  ]

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


  world = World.new("My Data", [f1.get_json, f2.get_json, f3.get_json, f4.get_json])

  puts world.to_geojson()
end

if File.identical?(__FILE__, $0)
  main()
end

