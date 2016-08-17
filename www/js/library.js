function Library() {
  this.load = function(rawLibraryData){
    if (rawLibraryData.type == 'node') {
      this.lat = rawLibraryData.lat
      this.lon = rawLibraryData.lon
    } else {
      this.lat = rawLibraryData.center.lat
      this.lon = rawLibraryData.center.lon      
    }

    this.type = rawLibraryData.type
    this.osmID = rawLibraryData.id
    this.name = rawLibraryData.tags.name || 'N/A'
    this.openingHours = rawLibraryData.tags.opening_hours
  }

  this.createMarker = function(){
    var openingHoursColor = this._openingHoursColor()

    this.marker =  new LibraryMarker()
    this.marker.initialize(this.lat, this.lon, openingHoursColor, this.name)

    return this.marker
  }

  this._openingHoursColor = function(){
    try {
      var oh = new opening_hours(this.openingHours);
      if (oh.getState(new Date()))
        return 'green'
      else
        return 'red'
    } catch (e) {
      // console.log('failed to parse opening hours: ' + openingHours)
      return 'grey'
    }
  }
}