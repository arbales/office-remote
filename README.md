# Office Remote

A little remote control for the office.

`cd /path/to/office-remote && bundle && bundle exec rackup`

## API


**Volume**

* `POST /volume/increment` - increments volume
* `DELETE /volume/increment` - decrements volume
* `PUT /volume?volume=50` - sets the volume

**Spotify**

`PUT /spotify?action=[…]` - executes a Spotify action.   

* `play`, `pause`, `play pause` - Duh.
* `next`, `previous` - Crossfades and then skips tracks.
* `open` - Combined with the `url` param, crossfades and plays a given track.

